function [ signals ] = signal_extraction ( movie_definition, signal_extraction_para, all_ellipse_info, accumulated_jitters, all_tracks, row_id, col_id, site_id, cmosoffset, all_bias )
%SIGNAL_EXTRACTION Extract signals from panels of images
%
%   Input
%       movie_definition: Parameters defining the movie
%       signal_extraction_para: Parameters for signal extraction
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_tracks: Cell tracks
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       cmosoffset: Information of camera dark noise
%       all_bias: Illumination bias
%   Output
%       signals: Extracted signals

% setting up basic structures
num_tracks = length(all_tracks);
if (num_tracks == 0)
    signals = [];
    return;
end
num_frames = length(movie_definition.frames_to_track);
num_channels = length(movie_definition.channel_names);

% aggregrate all track paths in the same matrix for simplificity
all_track_paths = nan(num_frames, num_tracks);
for i=1:num_tracks
    all_track_paths(:,i) = all_tracks{i}.current_id;
end

% get all variable names for nuclear and additional markers
channel_properties = cell(num_channels, 1);
for i=1:num_channels
    property_name_string = {[movie_definition.signal_names{i}, '_nuc_mean'], ...
        [movie_definition.signal_names{i}, '_nuc_percentile'], ...
        [movie_definition.signal_names{i}, '_nuc_variance']}; % 
    if (movie_definition.if_compute_cytoring(i)) % has cytoring properties
        property_name_string = cat(2, property_name_string, {[movie_definition.signal_names{i}, '_cytoring_mean'], ...
            [movie_definition.signal_names{i}, '_cytoring_percentile'], ...
            [movie_definition.signal_names{i}, '_cytoring_variance']});
    end
    channel_properties{i} = matlab.lang.makeValidName(property_name_string);
end

% set up empty data structure to save data
signals = cell(num_tracks, 1);
for i=1:num_tracks
    % shared entries
    signals{i} = struct('ellipse_id', {nan(num_frames, 1)}, ...
        'num_tracks_at_ellipse', {nan(num_frames, 1)}, ... number of cells at this ellipse
        'daughters', {cell(num_frames, 1)}, ... % daughter track id
        ... If two cells co-exist in one ellipse, both cells share the same value at this frame.
        'nuc_center_x', {nan(num_frames, 1)}, 'nuc_center_y', {nan(num_frames, 1)}, ... position of ellipse center. in real coordinate, not image coordinate!
        'nuc_first_axis', {nan(num_frames, 1)}, 'nuc_second_axis', {nan(num_frames, 1)}, ... length of the axes of this ellipse.
        'nuc_area', {nan(num_frames, 1)}, ... % area of the ellipse
        'nuc_angle', {nan(num_frames, 1)}); % angle of nuclear first axis
    
    % each channel
    for j=1:length(channel_properties)
        for k=1:length(channel_properties{j})
            if (mod(k, 3)==2) % percentile
                signals{i}.(channel_properties{j}{k}) = nan(num_frames, length(signal_extraction_para.intensity_percentile));
            else
                signals{i}.(channel_properties{j}{k}) = nan(num_frames, 1);
            end
        end
    end
end

% iterate over all frames
for i=1:num_frames
    disp(['Current Progress: ', num2str(i), '/', num2str(num_frames)]);
    frame_id = movie_definition.frames_to_track(i);
    
    %% PART 1. DETERMINE THE PIXELS FOR NUCLEUS AND CYTOPLASMIC RING
    % set up detection structures
    num_ellipses = length(all_ellipse_info{i}.all_cartesian_para);
    num_tracks_at_ellipse = histc(all_track_paths(i,:), 1:num_ellipses)';
    
    % find the independent nucleus and cytoplasmic ring pixels
    all_nuclear_pixel_idx = cell(num_ellipses, 1);
    all_cytoring_pixel_idx = cell(num_ellipses, 1);
    full_mask = zeros(movie_definition.size_image);
    % iterate over all ellipses to get initial nuclear and nuclear+cytoring
    % pixels
    for j=1:num_ellipses
        % re-construct the mask image with only this ellipse
        mask = false(movie_definition.size_image);
        mask(sub2ind(movie_definition.size_image, all_ellipse_info{i}.all_internal_points{j}(:,1), all_ellipse_info{i}.all_internal_points{j}(:,2))) = true;
        
        % erode to get nuclear pixel idx
        erode_mask = imerode(mask, strel('disk', signal_extraction_para.nuc_region_dist, 0));
        all_nuclear_pixel_idx{j} = find(erode_mask(:));
        
        % imdilate to get cytoplasmic ring and full intensities
        inner_border_mask = imdilate(mask, strel('disk', signal_extraction_para.cytoring_region_dist(1), 0));
        outer_border_mask = imdilate(inner_border_mask, strel('disk', signal_extraction_para.cytoring_region_dist(2) - signal_extraction_para.cytoring_region_dist(1), 0));
        
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
    foreground_pixel_mask = imdilate(full_mask > 0, strel('disk', signal_extraction_para.background_dist, 0));
    
    %% PART 2. ANALYZE ALL THE TRACKS
    % read nuclear images
    channel_images = cell(num_channels, 1);
    for j=1:num_channels
        channel_images{j} = background_subtraction_signal( read_image(movie_definition, {row_id, col_id, site_id, j, frame_id}, cmosoffset, all_bias{j}), ...
            foreground_pixel_mask, signal_extraction_para);
    end
    
    % iterate over all tracks at this frame
    for j=1:num_tracks
        curr_ellipse_id = all_tracks{j}.current_id(i);
        if (isnan(curr_ellipse_id)) % not present or invalid at this stage, not processing
            continue;
        end
        curr_parametric_para = all_ellipse_info{i}.all_parametric_para{curr_ellipse_id};
        curr_parametric_para(3:4) = curr_parametric_para(3:4) + accumulated_jitters(i, [2,1])';
        
        % put ellipse info
        signals{j}.ellipse_id(i) = curr_ellipse_id;
        signals{j}.num_tracks_at_ellipse(i) = num_tracks_at_ellipse(curr_ellipse_id);
        signals{j}.daughters{i} = all_tracks{j}.daughters{i};
        signals{j}.intensity_percentile = signal_extraction_para.intensity_percentile;
        
        signals{j}.nuc_center_x(i) = curr_parametric_para(3);
        signals{j}.nuc_center_y(i) = curr_parametric_para(4);
        signals{j}.nuc_first_axis(i) = curr_parametric_para(1);
        signals{j}.nuc_second_axis(i) = curr_parametric_para(2);
        signals{j}.nuc_area(i) = pi*curr_parametric_para(1)*curr_parametric_para(2);
        signals{j}.nuc_angle(i) = curr_parametric_para(5);
        
        % channel properties
        for k=1:num_channels
            % nucleus
            selected_nuc_intensities = select_valid_intensities(channel_images{k}(all_nuclear_pixel_idx{curr_ellipse_id}), signal_extraction_para);
            signals{j}.(channel_properties{k}{1})(i) = nanmean(selected_nuc_intensities); % mean
            signals{j}.(channel_properties{k}{2})(i, :) = prctile(selected_nuc_intensities, signal_extraction_para.intensity_percentile); % percentile
            signals{j}.(channel_properties{k}{3})(i) = nanvar(selected_nuc_intensities); % variance
            
            % cyto ring
            if (movie_definition.if_compute_cytoring(k))
                selected_cytoring_intensities = select_valid_intensities(channel_images{k}(all_cytoring_pixel_idx{curr_ellipse_id}), signal_extraction_para);
                signals{j}.(channel_properties{k}{4})(i) = nanmean(selected_cytoring_intensities); % mean
                signals{j}.(channel_properties{k}{5})(i, :) = prctile(selected_cytoring_intensities, signal_extraction_para.intensity_percentile); % percentile
                signals{j}.(channel_properties{k}{6})(i) = nanvar(selected_cytoring_intensities); % variance
            end
        end
    end
end

end

function [ image ] = background_subtraction_signal ( image, foreground_pixel_mask, signal_extraction_para )
%BACKGROUND_SUBTRACTION_SIGNAL Perform background subtraction for an image.
%For signal extraction only.
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
selected_values = raw_values(raw_values >= prctile(raw_values, signal_extraction_para.outlier_percentile) & ...
    raw_values <= prctile(raw_values, 100-signal_extraction_para.outlier_percentile));

end
