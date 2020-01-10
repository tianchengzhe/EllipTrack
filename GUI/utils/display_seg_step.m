function [ handles ] = display_seg_step( handles )
%DISPLAY_SEG_STEP Display the result of one Segmentation step in Parameter
%Generator GUI.
%
%   Input
%       handles: Handles before operation
%   Output
%       handles: Handles after operation

if (isempty(handles.seg_raw_image))
    return;
end
min_intensity = str2double(get(handles.edit_sec3_intensity_from, 'String'));
max_intensity = str2double(get(handles.edit_sec3_intensity_to, 'String'));

if (handles.seg_error_step > 0 && handles.seg_error_step <= handles.seg_disp_step)
    if_error = 1;
    step_disp = handles.seg_error_step - 1;
else
    if_error = 0;
    step_disp = handles.seg_disp_step;
end

switch (step_disp)
    case 1 % Non-Specific
        temp = max(min(handles.seg_raw_image, max_intensity), min_intensity);
        temp = (temp-min_intensity)/(max_intensity-min_intensity);
        if (if_error)
            temp = insertText(temp, [2, 2], 'Segmentation Error', 'TextColor', [1, 1, 0], 'BoxColor', [0, 0, 0], 'FontSize', 50);
        end
        
        cla(handles.axes_sec3); axes(handles.axes_sec3);
        imshow(temp);
    case 2 % Image Binarization
        cla(handles.axes_sec3); axes(handles.axes_sec3);
        temp = handles.seg_premask;
        if (if_error)
            temp = insertText(double(temp), [2, 2], 'Segmentation Error', 'TextColor', [1, 1, 0], 'BoxColor', [0, 0, 0], 'FontSize', 50);
        end
        imshow(temp);
    case 3 % Active Contour
        cla(handles.axes_sec3); axes(handles.axes_sec3);
        temp = handles.seg_ac_mask;
        if (if_error)
            temp = insertText(double(temp), [2, 2], 'Segmentation Error', 'TextColor', [1, 1, 0], 'BoxColor', [0, 0, 0], 'FontSize', 50);
        end
        imshow(temp);
    case 4 % Watershed
        cla(handles.axes_sec3); axes(handles.axes_sec3);
        temp = handles.seg_watershed_mask;
        if (if_error)
            temp = insertText(double(temp), [2, 2], 'Segmentation Error', 'TextColor', [1, 1, 0], 'BoxColor', [0, 0, 0], 'FontSize', 50);
        end
        imshow(temp); 
    case 5 % Ellipse Fitting
        temp = max(min(handles.seg_raw_image, max_intensity), min_intensity);
        temp = (temp-min_intensity)/(max_intensity-min_intensity);
        if (if_error)
            temp = insertText(temp, [2, 2], 'Segmentation Error', 'TextColor', [1, 1, 0], 'BoxColor', [0, 0, 0], 'FontSize', 50);
        end
        
        cla(handles.axes_sec3); axes(handles.axes_sec3);
        imshow(temp); hold(handles.axes_sec3, 'on');
        for j=1:length(handles.seg_ellipse_info.all_boundary_points)
            plot(handles.seg_ellipse_info.all_boundary_points{j}(:,2), handles.seg_ellipse_info.all_boundary_points{j}(:,1), 'color', [0.8, 0.5, 0.5], 'LineWidth', 1);
        end
        hold(handles.axes_sec3, 'off');
    case 6 % Segmentation Correction
        temp = max(min(handles.seg_raw_image, max_intensity), min_intensity);
        temp = (temp-min_intensity)/(max_intensity-min_intensity);
        if (if_error)
            temp = insertText(temp, [2, 2], 'Segmentation Error', 'TextColor', [1, 1, 0], 'BoxColor', [0, 0, 0], 'FontSize', 50);
        end
            
        cla(handles.axes_sec3); axes(handles.axes_sec3);
        imshow(temp); hold(handles.axes_sec3, 'on');
        for j=1:length(handles.id_no_cell)
            plot(handles.seg_ellipse_info.all_boundary_points{handles.id_no_cell(j)}(:,2), handles.seg_ellipse_info.all_boundary_points{handles.id_no_cell(j)}(:,1), 'color', [0.5, 0.5, 0.8], 'LineWidth', 1);
        end
        num_kept = length(handles.seg_ellipse_info.all_boundary_points)-length(handles.id_no_cell)-length(handles.id_two_cells);
        for j=1:num_kept
            plot(handles.seg_corr_ellipse_info.all_boundary_points{j}(:,2), handles.seg_corr_ellipse_info.all_boundary_points{j}(:,1), 'color', [0.8, 0.5, 0.5], 'LineWidth', 1);
        end
        for j=num_kept+1:length(handles.seg_corr_ellipse_info.all_boundary_points)
            plot(handles.seg_corr_ellipse_info.all_boundary_points{j}(:,2), handles.seg_corr_ellipse_info.all_boundary_points{j}(:,1), 'color', [0.5, 0.8, 0.5], 'LineWidth', 1);
        end
        hold(handles.axes_sec3, 'off');
    otherwise
        error('display_seg_step: unknown option.');
end

set(handles.axes_sec3, 'Visible', 'off');

end
