function [ handles ] = process_seg_step( handles )
%PROCESS_SEG_STEP Perform Segmentation steps in Parameter Generator GUI.
%
%   Input
%       handles: Handles before operation
%   Output
%       handles: Handles after operation

% skip if no need to calculate
step_to_run = handles.seg_curr_calculated_step+1:handles.seg_disp_step;
if (isempty(step_to_run) || isempty(handles.seg_raw_image))
    return;
end

% calculate each step
f = waitbar(0, 'Processing Image.');
if ismember(2, step_to_run) % Image Binarization
    try
        waitbar((2-min(step_to_run))/length(step_to_run), f);
        handles.seg_bgsub_raw_image = background_subtraction(handles.seg_raw_image, handles.seg_para);
        handles.seg_premask = image_binarization(handles.seg_bgsub_raw_image, handles.seg_para);
    catch
        close(f);
        waitfor(errordlg('Error at Image Binarization. Please check parameter values.','Error'));
        handles.seg_curr_calculated_step = 1;
        handles.seg_disp_step = 2;
        handles.seg_error_step = 2;
        return;
    end
end

if ismember(3, step_to_run) % Active Contour
    try
        waitbar((3-min(step_to_run))/length(step_to_run), f);
        if (handles.seg_para.active_contour_para.if_run)
            handles.seg_ac_mask = run_active_contour(handles.seg_bgsub_raw_image, handles.seg_premask, handles.seg_para);
        else
            handles.seg_ac_mask = handles.seg_premask;
        end
    catch
        close(f);
        waitfor(errordlg('Error at Active Contour. Please check parameter values.','Error'));
        handles.seg_curr_calculated_step = 2;
        handles.seg_disp_step = 3;
        handles.seg_error_step = 3;
        return;
    end
end

if ismember(4, step_to_run) % Watershed
    try
        waitbar((4-min(step_to_run))/length(step_to_run), f);
        if (handles.seg_para.watershed_para.if_run)
            handles.seg_watershed_mask = run_watershed( handles.seg_ac_mask, handles.seg_para );
        else
            handles.seg_watershed_mask = handles.seg_ac_mask;
        end
    catch
        close(f);
        waitfor(errordlg('Error at Watershed. Please check parameter values.','Error'));
        handles.seg_curr_calculated_step = 3;
        handles.seg_disp_step = 4;
        handles.seg_error_step = 4;
        return;
    end
end

if ismember(5, step_to_run) % Ellipse Fitting
    try
        waitbar((5-min(step_to_run))/length(step_to_run), f);
        contourevidence = mia_cmpcontourevidence( handles.seg_watershed_mask, handles.seg_para );
        [ all_cartesian_para, all_parametric_para, all_boundary_points, all_internal_points ] = ellipse_fitting( size(handles.seg_bgsub_raw_image), contourevidence, handles.seg_para );

        all_features = extract_features( handles.seg_bgsub_raw_image, all_parametric_para, all_boundary_points, all_internal_points );
        handles.seg_ellipse_info = struct('all_cartesian_para', {all_cartesian_para}, 'all_parametric_para', {all_parametric_para}, 'all_boundary_points', {all_boundary_points}, ...
            'all_internal_points', {all_internal_points}, 'all_features', {all_features});
    catch
        close(f);
        waitfor(errordlg('Error at Ellipse Fitting. Please check parameter values.','Error'));
        handles.seg_curr_calculated_step = 4;
        handles.seg_disp_step = 5;
        handles.seg_error_step = 5;
        return;
    end
end

if ismember(6, step_to_run) % Seg Correction
    try
        waitbar((6-min(step_to_run))/length(step_to_run), f);
        if (handles.seg_para.seg_correction_para.if_run)
            if isempty(handles.all_training_path)
                waitfor(errordlg('Training datasets are not provided.','Error'));
                error('');
            end
            morphology_training_info = [];
            for i=1:size(handles.all_training_path, 1)
                h = load(handles.all_training_path{i});
                morphology_training_info = cat(2, morphology_training_info, h.morphology_training_info);
            end
            morphology_training_features = cell2mat({morphology_training_info.features})';
            morphology_training_labels = [morphology_training_info.label]';
            [handles.seg_corr_ellipse_info, handles.id_no_cell, handles.id_two_cells] = seg_correction(handles.seg_bgsub_raw_image, ...
                handles.seg_watershed_mask, handles.seg_ellipse_info, morphology_training_features, morphology_training_labels, handles.seg_para);
        else
            handles.seg_corr_ellipse_info = handles.seg_ellipse_info;
            handles.id_no_cell = [];
            handles.id_two_cells = [];
        end
    catch
        close(f);
        waitfor(errordlg('Error at Segmentation Correction. Please check parameter values.','Error'));
        handles.seg_curr_calculated_step = 5;
        handles.seg_disp_step = 6;
        handles.seg_error_step = 6;
        return;
    end
end

close(f);
handles.seg_curr_calculated_step = handles.seg_disp_step;
handles.seg_error_step = 0;

end
