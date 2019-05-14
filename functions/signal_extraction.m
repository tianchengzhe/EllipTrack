function [ signals ] = signal_extraction ( size_image, all_ellipse_info, jitter_adjusted_all_ellipse_info, all_tracks, global_setting, row_id, col_id, site_id, signal_extraction_para, cmosoffset, nuc_bias )
%SIGNAL_EXTRACTION Extract signals from panels of images
%
%   Input
%       size_image: Dimension of the image
%       all_ellipse_info: Segmentation results
%       jitter_adjusted_all_ellipse_info: Jitter adjusted segmentation
%       results
%       all_tracks: Cell tracks
%       global_setting: Parameters used by all tracker modules
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       signal_extraction_para: Parameters for signal extraction
%       cmosoffset: Information of camera dark noise
%       nuc_bias: Information of illumination bias of the nuclear channel
%   Output
%       signals: Extracted signals

% setting up basic structures
num_tracks = length(all_tracks);
if (num_tracks == 0)
    signals = [];
    return;
end
num_frames = length(global_setting.all_frames);
num_additional_markers = length(signal_extraction_para.additional_signal_names);

% aggregrate all track paths in the same matrix for simplificity
all_track_paths = nan(num_frames, num_tracks);
for i=1:num_tracks
    all_track_paths(:,i) = all_tracks{i}.current_id;
end

% get all variable names for nuclear and additional markers
nuc_marker_properties = matlab.lang.makeValidName({[global_setting.nuc_biomarker_name, '_nuc_mean'], ...
    [global_setting.nuc_biomarker_name, '_nuc_percentile']});

all_additional_marker_properties = cell(num_additional_markers, 1);
for i=1:num_additional_markers
    property_name_string = {[signal_extraction_para.additional_biomarker_names{i}, '_nuc_mean'], ...
        [signal_extraction_para.additional_biomarker_names{i}, '_nuc_percentile']}; % 
    if (signal_extraction_para.if_compute_cyto_ring(i)) % has cytoring properties
        property_name_string = cat(2, property_name_string, {[signal_extraction_para.additional_biomarker_names{i}, '_cytoring_mean'], ...
            [signal_extraction_para.additional_biomarker_names{i}, '_cytoring_percentile']});
    end
    all_additional_marker_properties{i} = matlab.lang.makeValidName(property_name_string);
end

% set up empty data structure to save data
signals = cell(num_tracks, 1);
for i=1:num_tracks
    % shared entries
    signals{i} = struct('if_multiple', NaN, ... % whether there is any duplication
        'ellipse_id', {nan(num_frames, 1)}, ...
        'num_tracks_at_ellipse', {nan(num_frames, 1)}, ... number of cells at this ellipse
        'daughters', {cell(num_frames, 1)}, ... % daughter track id
        ... If two cells co-exist in one ellipse, both cells share the same value at this frame.
        'nuc_center_x', {nan(num_frames, 1)}, 'nuc_center_y', {nan(num_frames, 1)}, ... position of ellipse center. in real coordinate, not image coordinate!
        'nuc_first_axis', {nan(num_frames, 1)}, 'nuc_second_axis', {nan(num_frames, 1)}, ... length of the axes of this ellipse.
        'nuc_area', {nan(num_frames, 1)}, ... % area of the ellipse
        'nuc_angle', {nan(num_frames, 1)}); % angle of nuclear first axis
    
    % nuclear marker
    for j=1:length(nuc_marker_properties)
        signals{i}.(nuc_marker_properties{j}) = nan(num_frames, 1);
    end
    
    % other marker
    for j=1:length(all_additional_marker_properties)
        for k=1:length(all_additional_marker_properties{j})
            signals{i}.(all_additional_marker_properties{j}{k}) = nan(num_frames, 1);
        end
    end
end

additional_marker_bias = cell(num_additional_markers, 1);
for i=1:num_additional_markers
    try
        h = load(signal_extraction_para.additional_bias_paths{i}); additional_marker_bias{i} = h.bias;
    catch
        warning(['Fail to load nuclear bias. Will not correct illumination bias for the ', signal_extraction_para.additional_signal_names{i}, ' channel.']);
        additional_marker_bias{i} = 1;
    end
end

% iterate over all frames
for i=1:num_frames
    disp(['Current Progress: ', num2str(i), '/', num2str(num_frames)]);
    frame_id = global_setting.all_frames(i);
    
    %% PART 1. DETERMINE THE PIXELS FOR NUCLEUS AND CYTOPLASMIC RING
    % set up detection structures
    num_ellipses = length(all_ellipse_info{i}.all_cartesian_para);
    num_tracks_at_ellipse = histc(all_track_paths(i,:), 1:num_ellipses)';
    
    % find the independent nucleus and cytoplasmic ring pixels
    all_nuclear_pixel_idx = cell(num_ellipses, 1);
    all_cytoring_pixel_idx = cell(num_ellipses, 1);
    full_mask = zeros(size_image);
    % iterate over all ellipses to get initial nuclear and nuclear+cytoring
    % pixels
    for j=1:num_ellipses
        % re-construct the mask image with only this ellipse
        mask = false(size_image);
        mask(sub2ind(size_image, all_ellipse_info{i}.all_internal_points{j}(:,1), all_ellipse_info{i}.all_internal_points{j}(:,2))) = true;
        
        % erode to get nuclear pixel idx
        erode_mask = imerode(mask, strel('disk', signal_extraction_para.nuc_outer_size, 0));
        all_nuclear_pixel_idx{j} = find(erode_mask(:));
        
        % imdilate to get cytoplasmic ring and full intensities
        inner_border_mask = imdilate(mask, strel('disk', signal_extraction_para.cyto_ring_inner_size, 0));
        outer_border_mask = imdilate(inner_border_mask, strel('disk', signal_extraction_para.cyto_ring_outer_size - signal_extraction_para.cyto_ring_inner_size, 0));
        
        all_cytoring_pixel_idx{j} = find(outer_border_mask(:) & ~inner_border_mask(:));
        full_mask = full_mask + double(outer_border_mask);
    end
    
    % determine duplication of pixels
    % Procedure
    % 1. Find pixels that belong to at least 2 detections' cytoring+nuclear
    % 2. Use setdiff to remove those duplicated pixels
    duplicated_pixel_idx = find(full_mask(:)>1);
    for j=1:num_ellipses
        all_cytoring_pixel_idx{j} = setdiff(all_cytoring_pixel_idx{j}, duplicated_pixel_idx);
        all_nuclear_pixel_idx{j} = setdiff(all_nuclear_pixel_idx{j}, duplicated_pixel_idx);
    end
    
    % determine range for background subtraction
    foreground_pixel_mask = imdilate(full_mask > 0, strel('disk', signal_extraction_para.foreground_dilation_size, 0));
    
    %% PART 2. ANALYZE ALL THE TRACKS
    % read nuclear images
    nuc_image = background_subtraction(read_image(global_setting.nuc_raw_image_path, global_setting.nd2_frame_range, row_id, col_id, site_id, ...
        global_setting.nuc_signal_name, frame_id, cmosoffset, nuc_bias), foreground_pixel_mask, signal_extraction_para);
    
    % read other images
    additional_marker_images = cell(num_additional_markers, 1);
    for j=1:num_additional_markers
        additional_marker_images{j} = background_subtraction(read_image(signal_extraction_para.additional_raw_image_paths{j}, global_setting.nd2_frame_range, row_id, col_id, site_id, ...
            signal_extraction_para.additional_signal_names{j}, frame_id, cmosoffset, additional_marker_bias{j}), foreground_pixel_mask, signal_extraction_para);
    end
    
    % iterate over all tracks at this frame
    for j=1:num_tracks
        curr_ellipse_id = all_tracks{j}.current_id(i);
        if (isnan(curr_ellipse_id)) % not present or invalid at this stage, not processing
            continue;
        end
        curr_parametric_para = jitter_adjusted_all_ellipse_info{i}.all_parametric_para{curr_ellipse_id};
        
        % put ellipse info
        signals{j}.if_multiple = all_tracks{j}.if_multiple;
        signals{j}.ellipse_id(i) = curr_ellipse_id;
        signals{j}.num_tracks_at_ellipse(i) = num_tracks_at_ellipse(curr_ellipse_id);
        signals{j}.daughters{i} = all_tracks{j}.daughters{i};
        
        signals{j}.nuc_center_x(i) = curr_parametric_para(3);
        signals{j}.nuc_center_y(i) = curr_parametric_para(4);
        signals{j}.nuc_first_axis(i) = curr_parametric_para(1);
        signals{j}.nuc_second_axis(i) = curr_parametric_para(2);
        signals{j}.nuc_area(i) = pi*curr_parametric_para(1)*curr_parametric_para(2);
        signals{j}.nuc_angle(i) = curr_parametric_para(5);
        
        % nuclear marker properties
        selected_nuc_intensities = select_valid_intensities(nuc_image(all_nuclear_pixel_idx{curr_ellipse_id}), signal_extraction_para);
        signals{j}.(nuc_marker_properties{1})(i) = nanmean(selected_nuc_intensities); % mean
        signals{j}.(nuc_marker_properties{2})(i) = prctile(selected_nuc_intensities, signal_extraction_para.intensity_percentile); % percentile
        
        % additional markers
        for k=1:num_additional_markers
            % nucleus
            selected_nuc_intensities = select_valid_intensities(additional_marker_images{k}(all_nuclear_pixel_idx{curr_ellipse_id}), signal_extraction_para);
            signals{j}.(all_additional_marker_properties{k}{1})(i) = nanmean(selected_nuc_intensities); % mean
            signals{j}.(all_additional_marker_properties{k}{2})(i) = prctile(selected_nuc_intensities, signal_extraction_para.intensity_percentile); % percentile
        
            % cyto ring
            if (signal_extraction_para.if_compute_cyto_ring(k))
                selected_cytoring_intensities = select_valid_intensities(additional_marker_images{k}(all_cytoring_pixel_idx{curr_ellipse_id}), signal_extraction_para);
                signals{j}.(all_additional_marker_properties{k}{3})(i) = nanmean(selected_cytoring_intensities); % mean
                signals{j}.(all_additional_marker_properties{k}{4})(i) = prctile(selected_cytoring_intensities, signal_extraction_para.intensity_percentile); % percentile
            end
        end
    end
end

end

function [ image ] = background_subtraction ( image, foreground_pixel_mask, signal_extraction_para )
%BACKGROUND_SUBTRACTION Perform background subtraction for an image.
%Following Mingyu's code to be comparable
%
%   Input
%       image: image before background subtraction
%       foreground_pixel_mask: mask to show which pixel is foreground when
%       calculating background value
%       signal_extraction_para: parameters related to background
%       subtraction
%   Output
%       image: image after background subtraction

% keep background pixels
background_only_image = image; background_only_image(foreground_pixel_mask) = NaN;

% find the most populated intensity value as the background
all_values = background_only_image(:); all_values = all_values(~isnan(all_values));
selected_values = select_valid_intensities(all_values, signal_extraction_para);
background_value = median(selected_values);
image = image - background_value;
image = max(image, 1);

end

function [ selected_values ] = select_valid_intensities( raw_values, signal_extraction_para )
%SELECT_VALID_INTENSITIES Select values between lower percentile and upper
%percentiles
%
%   Input
%       raw_values: Input values
%       signal_extraction_para: parameters related to signal extraction
%   Output
%       selected_values: Value within upper and lower percentiles

raw_values = raw_values(:);
selected_values = raw_values(raw_values >= prctile(raw_values, signal_extraction_para.lower_percentile) & ...
    raw_values <= prctile(raw_values, signal_extraction_para.higher_percentile));

end
