function [ all_ellipse_info ] = segmentation( row_id, col_id, site_id, global_setting, segmentation_para, cmosoffset, nuc_bias )
%SEGMENTATION Perform the complete procedure of image segmentation and
%ellipse fitting.
%
%   Input
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       global_setting: Parameters used by all tracker modules
%       segmentation_para: Parameters for Segmentation
%       cmosoffset: Information of camera dark noise
%       nuc_bias: Information of illumination bias of the nuclear channel
%   Output
%       all_ellipse_info: segmentation results of images

% get training data if using training datasets to correct segmentation mistakes
if (segmentation_para.if_seg_correction)
    morphology_training_info = [];
    for i=1:size(segmentation_para.seg_correction_para.training_data_path, 1)
        h = load(segmentation_para.seg_correction_para.training_data_path{i});
        morphology_training_info = cat(2, morphology_training_info, h.morphology_training_info);
    end
    disp(['Loaded ', num2str(size(segmentation_para.seg_correction_para.training_data_path, 1)), ' training datasets.']);
    morphology_training_features = cell2mat({morphology_training_info.features})';
    morphology_training_labels = [morphology_training_info.label]';
end

% define structure to save all ellipse info
all_ellipse_info = cell(length(global_setting.all_frames), 1);

% iterate over all images
for i=1:length(global_setting.all_frames)
    disp([ 'Current Progress: ', num2str(i), '/', num2str(length(global_setting.all_frames)) ]);
    frame_id = global_setting.all_frames(i);
    I = read_image(global_setting.nuc_raw_image_path, global_setting.nd2_frame_range, row_id, col_id, site_id, global_setting.nuc_signal_name, frame_id, cmosoffset, nuc_bias);
    
    % Step 1. Image Binarization
    premask = image_binarization(I, segmentation_para);

    % Step 2. Active Contour
    if (segmentation_para.if_active_contour)
        ac_mask = run_active_contour(I, premask, segmentation_para);
    else
        ac_mask = premask;
    end
    
    % Step 3. Watershed
    if (segmentation_para.if_watershed)
        watershed_mask = run_watershed( ac_mask, segmentation_para );
    else
        watershed_mask = ac_mask;
    end
    
    % Step 4. Ellips Fitting
    contourevidence = mia_cmpcontourevidence( watershed_mask, segmentation_para.ellipse_para );
    [ all_cartesian_para, all_parametric_para, all_boundary_points, all_internal_points ] = ellipse_fitting( size(I), contourevidence, segmentation_para.ellipse_para );
    
    all_features = extract_features( I, all_parametric_para, all_boundary_points, all_internal_points );
    ellipse_info = struct('all_cartesian_para', {all_cartesian_para}, 'all_parametric_para', {all_parametric_para}, 'all_boundary_points', {all_boundary_points}, ...
        'all_internal_points', {all_internal_points}, 'all_features', {all_features});
    
    % Step 5. Correcting Segmentation Mistakes
    if (segmentation_para.if_seg_correction)
        ellipse_info = seg_correction(I, watershed_mask, ellipse_info, morphology_training_features, morphology_training_labels, segmentation_para.ellipse_para, segmentation_para.seg_correction_para);
    end
    
    % put into the data structure
    all_ellipse_info{i} = ellipse_info;
    
    % print stuff
    filename = [num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', global_setting.nuc_signal_name, '_', num2str(frame_id)];
    if (segmentation_para.if_print_mask)
        imwrite(watershed_mask, [segmentation_para.mask_path, filename, '.tif']);
    end
    if (segmentation_para.if_print_ellipse_movie)
        h = figure(1); imshow(mat2gray(I)); hold on;
        for j=1:length(all_ellipse_info{i}.all_boundary_points)
            plot(all_ellipse_info{i}.all_boundary_points{j}(:,2), all_ellipse_info{i}.all_boundary_points{j}(:,1), 'color', [0.8, 0.5, 0.5], 'LineWidth', 1);
        end
        h.PaperUnits = 'Points';
        h.PaperPosition = [0, 0, size(I')/2];
        h.PaperSize = size(I')/2;
        print(gcf, '-dtiff', [segmentation_para.ellipse_movie_path, filename, '.tif']);
        close(h);
    end
    
    % save segmentation info
    if (segmentation_para.if_save_seg_info)
        save([segmentation_para.seg_info_path, filename, '_segmentation.mat'], 'ellipse_info');
    end
end


end
