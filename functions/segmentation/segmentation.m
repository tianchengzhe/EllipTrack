function [ all_ellipse_info ] = segmentation( movie_definition, inout_para, segmentation_para, row_id, col_id, site_id, cmosoffset, nuc_bias )
%SEGMENTATION Perform the complete procedure of image segmentation and
%ellipse fitting.
%
%   Input
%       movie_definition: Parameters defining the movie
%       inout_para: Parameters defining inputs and outputs
%       segmentation_para: Parameters for segmentation
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       cmosoffset: Information of camera dark noise
%       nuc_bias: Information of illumination bias of the nuclear channel
%   Output
%       all_ellipse_info: segmentation results

% get training data if using training datasets to correct segmentation mistakes
if (segmentation_para.seg_correction_para.if_run)
    morphology_training_info = [];
    for i=1:size(inout_para.training_data_path, 1)
        h = load(inout_para.training_data_path{i});
        morphology_training_info = cat(2, morphology_training_info, h.morphology_training_info);
    end
    disp(['Loaded ', num2str(size(inout_para.training_data_path, 1)), ' training datasets.']);
    morphology_training_features = cell2mat({morphology_training_info.features})';
    morphology_training_labels = [morphology_training_info.label]';
end

% define structure to save all ellipse info
all_ellipse_info = cell(length(movie_definition.frames_to_track), 1);

% adjust paths
if ~isempty(inout_para.mask_path)
    inout_para.mask_path = [inout_para.mask_path, num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '/'];
    if ~exist(inout_para.mask_path, 'dir')
        mkdir(inout_para.mask_path);
    end
end
if ~isempty(inout_para.ellipse_movie_path)
    inout_para.ellipse_movie_path = [inout_para.ellipse_movie_path, num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '/'];
    if ~exist(inout_para.ellipse_movie_path, 'dir')
        mkdir(inout_para.ellipse_movie_path);
    end
end
if ~isempty(inout_para.seg_info_path)
    inout_para.seg_info_path = [inout_para.seg_info_path, num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '/'];
    if ~exist(inout_para.seg_info_path, 'dir')
        mkdir(inout_para.seg_info_path);
    end
end

% iterate over all images
for i=1:length(movie_definition.frames_to_track)
    disp([ 'Current Progress: ', num2str(i), '/', num2str(length(movie_definition.frames_to_track)) ]);
    frame_id = movie_definition.frames_to_track(i);
    I = read_image(movie_definition, {row_id, col_id, site_id, 1, frame_id}, cmosoffset, nuc_bias);
    
    % Step 1. Image Binarization
    I = background_subtraction(I, segmentation_para);
    premask = image_binarization(I, segmentation_para);

    % Step 2. Active Contour
    if (segmentation_para.active_contour_para.if_run)
        ac_mask = run_active_contour(I, premask, segmentation_para);
    else
        ac_mask = premask;
    end
    
    % Step 3. Watershed
    if (segmentation_para.watershed_para.if_run)
        watershed_mask = run_watershed( ac_mask, segmentation_para );
    else
        watershed_mask = ac_mask;
    end
    
    % Step 4. Ellips Fitting
    contourevidence = mia_cmpcontourevidence( watershed_mask, segmentation_para );
    [ all_cartesian_para, all_parametric_para, all_boundary_points, all_internal_points ] = ellipse_fitting( size(I), contourevidence, segmentation_para );
    
    [ all_features, invalid_entry ] = extract_features( I, all_parametric_para, all_boundary_points, all_internal_points );
    ellipse_info = struct('all_cartesian_para', {all_cartesian_para(~invalid_entry)}, 'all_parametric_para', {all_parametric_para(~invalid_entry)}, ...
        'all_boundary_points', {all_boundary_points(~invalid_entry)}, 'all_internal_points', {all_internal_points(~invalid_entry)}, 'all_features', {all_features(~invalid_entry)});
    
    % Step 5. Correcting Segmentation Mistakes
    if (segmentation_para.seg_correction_para.if_run)
        ellipse_info = seg_correction(I, watershed_mask, ellipse_info, morphology_training_features, morphology_training_labels, segmentation_para);
    end
    
    % print stuff
    filename = [num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', movie_definition.channel_names{1}, '_', num2str(frame_id)];
    if ~isempty(inout_para.mask_path)
        imwrite(watershed_mask, [inout_para.mask_path, filename, '.tif']);
    end
    if ~isempty(inout_para.ellipse_movie_path)
        h = figure(1); imshow(mat2gray(I)); hold on;
        for j=1:length(ellipse_info.all_boundary_points)
            plot(ellipse_info.all_boundary_points{j}(:,2), ellipse_info.all_boundary_points{j}(:,1), 'color', [0.8, 0.5, 0.5], 'LineWidth', 1);
        end
        h.PaperUnits = 'Points';
        h.PaperPosition = [0, 0, size(I')/2];
        h.PaperSize = size(I')/2;
        print(gcf, '-dtiff', [inout_para.ellipse_movie_path, filename, '.tif']);
        close(h);
    end
    
    % save segmentation info
    if ~isempty(inout_para.seg_info_path)
        save([inout_para.seg_info_path, filename, '_segmentation.mat'], 'ellipse_info');
    end
    
    % put into the data structure
    all_ellipse_info{i} = ellipse_info;
end

end
