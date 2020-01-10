function handles = paragenGUI_update_para(handles, loaded_para)
%PARAGENGUI_UPDATE_PARA Update GUI fields with loaded parameter values.
%
%   Input
%       handles: Handles before operation
%       loaded_para: loaded parameter values
%   Output
%       handles: Handles after operation

% Section 1, Page 1
% Image Type
loaded_image_path = loaded_para.movie_definition.image_path;
if ~iscell(loaded_image_path)
    loaded_image_path = {};
end
switch lower(loaded_para.movie_definition.image_type)
    case 'seq'
        set(handles.uibuttongroup_sec1_imagetype, 'SelectedObject', handles.radiobutton_sec1_imagetype_seq);
        handles.nd2_image_path = {};
        if (length(loaded_image_path) >= 2)
            handles.if_same_path = all(cellfun(@(x) isequal(x, loaded_image_path{1}), loaded_image_path));
        else
            handles.if_same_path = 0;
        end
        set(handles.uipanel_sec1_extract, 'Visible', 'off');
        
    case 'stack'
        set(handles.uibuttongroup_sec1_imagetype, 'SelectedObject', handles.radiobutton_sec1_imagetype_stack);
        handles.nd2_image_path = {};
        if (length(loaded_image_path) >= 2)
            handles.if_same_path = all(cellfun(@(x) isequal(x, loaded_image_path{1}), loaded_image_path));
        else
            handles.if_same_path = 0;
        end
        set(handles.uipanel_sec1_extract, 'Visible', 'off');
        
    case 'nd2'
        set(handles.uibuttongroup_sec1_imagetype, 'SelectedObject', handles.radiobutton_sec1_imagetype_nd2);
        handles.if_same_path = 1;
        handles.nd2_image_path = loaded_para.movie_definition.image_path;
        if ~iscell(handles.nd2_image_path)
            handles.nd2_image_path = {};
        end
        set(handles.uipanel_sec1_extract, 'Visible', 'on');
        
    otherwise
        error('Invalid value of movie_definition.image_type. Loading failed.');
end
handles.image_type = loaded_para.movie_definition.image_type;

% Number of channels
handles.num_channels = max(1, length(loaded_para.movie_definition.channel_names));
temp = matlab.lang.makeValidName(['radiobutton_sec1_numchannel_', num2str(handles.num_channels)]);
set(handles.uibuttongroup_sec1_numchannel, 'SelectedObject', handles.(temp));

% Channel Operator
handles.channel_operator = cell(6, 1);
handles.channel_operator{1} = matlab.lang.makeValidName({'edit_sec1_ch1_channel', 'edit_sec1_ch1_signal', 'edit_sec1_ch1_path', 'pushbutton_sec1_ch1_path', ...
    'edit_sec1_ch1_bias', 'pushbutton_sec1_ch1_bias_select', 'pushbutton_sec1_ch1_bias_delete', 'checkbox_sec1_ch1_cytoring'});
handles.channel_operator{2} = matlab.lang.makeValidName({'edit_sec1_ch2_channel', 'edit_sec1_ch2_signal', 'edit_sec1_ch2_path', 'pushbutton_sec1_ch2_path', ...
    'edit_sec1_ch2_bias', 'pushbutton_sec1_ch2_bias_select', 'pushbutton_sec1_ch2_bias_delete', 'checkbox_sec1_ch2_cytoring'});
handles.channel_operator{3} = matlab.lang.makeValidName({'edit_sec1_ch3_channel', 'edit_sec1_ch3_signal', 'edit_sec1_ch3_path', 'pushbutton_sec1_ch3_path', ...
    'edit_sec1_ch3_bias', 'pushbutton_sec1_ch3_bias_select', 'pushbutton_sec1_ch3_bias_delete', 'checkbox_sec1_ch3_cytoring'});
handles.channel_operator{4} = matlab.lang.makeValidName({'edit_sec1_ch4_channel', 'edit_sec1_ch4_signal', 'edit_sec1_ch4_path', 'pushbutton_sec1_ch4_path', ...
    'edit_sec1_ch4_bias', 'pushbutton_sec1_ch4_bias_select', 'pushbutton_sec1_ch4_bias_delete', 'checkbox_sec1_ch4_cytoring'});
handles.channel_operator{5} = matlab.lang.makeValidName({'edit_sec1_ch5_channel', 'edit_sec1_ch5_signal', 'edit_sec1_ch5_path', 'pushbutton_sec1_ch5_path', ...
    'edit_sec1_ch5_bias', 'pushbutton_sec1_ch5_bias_select', 'pushbutton_sec1_ch5_bias_delete', 'checkbox_sec1_ch5_cytoring'});
handles.channel_operator{6} = matlab.lang.makeValidName({'edit_sec1_ch6_channel', 'edit_sec1_ch6_signal', 'edit_sec1_ch6_path', 'pushbutton_sec1_ch6_path', ...
    'edit_sec1_ch6_bias', 'pushbutton_sec1_ch6_bias_select', 'pushbutton_sec1_ch6_bias_delete', 'checkbox_sec1_ch6_cytoring'});

% Channel Information (excl image path)
for i=1:handles.num_channels
    % channel information
    try
        set(handles.(handles.channel_operator{i}{1}), 'Enable', 'on', 'String', loaded_para.movie_definition.channel_names{i});
    catch
        set(handles.(handles.channel_operator{i}{1}), 'Enable', 'on');
    end
    
    % signal information
    try
        set(handles.(handles.channel_operator{i}{2}), 'Enable', 'on', 'String', loaded_para.movie_definition.signal_names{i});
    catch
        set(handles.(handles.channel_operator{i}{2}), 'Enable', 'on');
    end
    
    % bias information
    try
        set(handles.(handles.channel_operator{i}{5}), 'Enable', 'on', 'String', loaded_para.movie_definition.bias_paths{i});
    catch
        set(handles.(handles.channel_operator{i}{5}), 'Enable', 'on');
    end
    set(handles.(handles.channel_operator{i}{6}), 'Enable', 'on');
    set(handles.(handles.channel_operator{i}{7}), 'Enable', 'on');
    
    % cyto ring
    if (i==1)
        set(handles.(handles.channel_operator{i}{8}), 'Enable', 'off', 'Value', 0);
    else
        try
            set(handles.(handles.channel_operator{i}{8}), 'Enable', 'on', 'Value', loaded_para.movie_definition.if_compute_cytoring(i));
        catch
            set(handles.(handles.channel_operator{i}{8}), 'Enable', 'on');
        end
    end    
end

% image path
if (handles.if_same_path) % same path
    switch lower(handles.image_type)
        case {'seq', 'stack'}
            try
                set(handles.(handles.channel_operator{1}{3}), 'Enable', 'on', 'String', loaded_image_path{1});
                set(handles.checkbox_sec1_path, 'Value', 1);
            catch
                set(handles.(handles.channel_operator{1}{3}), 'Enable', 'on');
            end
        case 'nd2'
            try
                set(handles.checkbox_sec1_path, 'Value', 1, 'Enable', 'off');
                switch length(loaded_image_path)
                    case 0
                        set(handles.(handles.channel_operator{1}{3}), 'Enable', 'off', 'String', '');
                    case 1
                        set(handles.(handles.channel_operator{1}{3}), 'Enable', 'off', 'String', loaded_image_path{1});
                    otherwise
                        set(handles.(handles.channel_operator{1}{3}), 'Enable', 'off', 'String', [num2str(length(loaded_image_path)), ' Folders']);
                end
            catch
                set(handles.(handles.channel_operator{1}{3}), 'Enable', 'off');
            end
    end
    set(handles.(handles.channel_operator{1}{4}), 'Enable', 'on');
    
    for i=2:handles.num_channels
        set(handles.(handles.channel_operator{i}{3}), 'Enable', 'off', 'String', get(handles.(handles.channel_operator{1}{3}), 'String'));
        set(handles.(handles.channel_operator{i}{4}), 'Enable', 'off');
    end
else
    for i=1:handles.num_channels
        try
            set(handles.(handles.channel_operator{i}{3}), 'Enable', 'on', 'String', loaded_image_path{i});
        catch
            set(handles.(handles.channel_operator{i}{3}), 'Enable', 'on');
        end
        set(handles.(handles.channel_operator{i}{4}), 'Enable', 'on');
    end
end
for i=handles.num_channels+1:length(handles.channel_operator)
    for j=1:length(handles.channel_operator{i})
        set(handles.(handles.channel_operator{i}{j}), 'Enable', 'off');
    end
end

% filename
try
    set(handles.edit_sec1_filename, 'String', loaded_para.movie_definition.filename_format);
catch
    set(handles.edit_sec1_filename, 'String', '');
end
switch lower(handles.image_type)
    case 'stack'
        set(handles.pushbutton_sec1_filename_frame, 'Enable', 'off');
    case 'nd2'
        set(handles.pushbutton_sec1_filename_site, 'Enable', 'off');
        set(handles.pushbutton_sec1_filename_frame, 'Enable', 'off');
        set(handles.pushbutton_sec1_filename_channel, 'Enable', 'off');
end
if isempty(get(handles.edit_sec1_filename, 'String'))
    set(handles.pushbutton_sec1_filename_check, 'Enable', 'off');
end

% well ID and frame ID
try
    set(handles.edit_sec1_row_from, 'String', num2str(min(loaded_para.movie_definition.wells_to_track(:,1))));
    set(handles.edit_sec1_row_to, 'String', num2str(max(loaded_para.movie_definition.wells_to_track(:,1))));
catch
end
try
    set(handles.edit_sec1_column_from, 'String', num2str(min(loaded_para.movie_definition.wells_to_track(:,2))));
    set(handles.edit_sec1_column_to, 'String', num2str(max(loaded_para.movie_definition.wells_to_track(:,2))));
catch
end
try
    set(handles.edit_sec1_site_from, 'String', num2str(min(loaded_para.movie_definition.wells_to_track(:,3))));
    set(handles.edit_sec1_site_to, 'String', num2str(max(loaded_para.movie_definition.wells_to_track(:,3))));
catch
end
try
    set(handles.edit_sec1_frame_from, 'String', num2str(min(loaded_para.movie_definition.frames_to_track)));
    set(handles.edit_sec1_frame_to, 'String', num2str(max(loaded_para.movie_definition.frames_to_track)));
catch
end

% CMOS, Jitter, Cores
try
    set(handles.edit_sec1_cmos, 'String', loaded_para.movie_definition.cmosoffset_path)
catch
end
switch lower(loaded_para.movie_definition.jitter_correction_method)
    case 'none'
        set(handles.uibuttongroup_sec1_jitter, 'SelectedObject', handles.radiobutton_sec1_jitter_none);
    case 'local'
        set(handles.uibuttongroup_sec1_jitter, 'SelectedObject', handles.radiobutton_sec1_jitter_local);
    case 'global'
        set(handles.uibuttongroup_sec1_jitter, 'SelectedObject', handles.radiobutton_sec1_jitter_global);
    otherwise
        error('Invalid value of movie_definition.jitter_correction_method.');
end
try
    myCluster = parcluster('local'); handles.max_cores = myCluster.NumWorkers;
    set(handles.text_sec1_core, 'String', ['Detect ', num2str(handles.max_cores), ' cores in the local cluster.']);
    try
        set(handles.edit_sec1_core, 'String', num2str(min(loaded_para.movie_definition.num_cores, handles.max_cores)));
    catch
        set(handles.edit_sec1_core, 'String', '1');
    end
catch
    set(handles.text_sec1_core, 'String', 'Parallel computing is not configured.');
    set(handles.edit_sec1_core, 'String', '1', 'Enable', 'off');
    handles.max_cores = 1;
end

% Input/Output
handles.curr_training_path = [];
handles.all_training_path = loaded_para.inout_para.training_data_path;
if ~iscell(handles.all_training_path)
    handles.all_training_path = {};
end
try
    set(handles.listbox_sec2_training, 'String', handles.all_training_path);
catch
    handles.all_training_path = {};
    set(handles.listbox_sec2_training, 'String', handles.all_training_path);
end
if (~isempty(get(handles.listbox_sec2_training, 'String')))
    set(handles.pushbutton_sec2_training_delete, 'Enable', 'on');
end

% Outputs
try
    set(handles.edit_sec2_output, 'String', loaded_para.inout_para.output_path);
catch
    set(handles.edit_sec2_output, 'String', '');
end

try
    set(handles.edit_sec2_mask, 'String', loaded_para.inout_para.mask_path);
catch
    set(handles.edit_sec2_mask, 'String', '');
end
if isempty(get(handles.edit_sec2_mask, 'String'))
    set(handles.checkbox_sec2_mask, 'Value', 0);
    set(handles.edit_sec2_mask, 'Enable', 'off');
    set(handles.pushbutton_sec2_mask, 'Enable', 'off');
else
    set(handles.checkbox_sec2_mask, 'Value', 1);
end

try
    set(handles.edit_sec2_ellipse, 'String', loaded_para.inout_para.ellipse_movie_path);
catch
    set(handles.edit_sec2_ellipse, 'String', '');
end
if isempty(get(handles.edit_sec2_ellipse, 'String'))
    set(handles.checkbox_sec2_ellipse, 'Value', 0);
    set(handles.edit_sec2_ellipse, 'Enable', 'off');
    set(handles.pushbutton_sec2_ellipse, 'Enable', 'off');
else
    set(handles.checkbox_sec2_ellipse, 'Value', 1);
end

try
    set(handles.edit_sec2_seginfo, 'String', loaded_para.inout_para.seg_info_path);
catch
    set(handles.edit_sec2_seginfo, 'String', '');
end
if isempty(get(handles.edit_sec2_seginfo, 'String'))
    set(handles.checkbox_sec2_seginfo, 'Value', 0);
    set(handles.edit_sec2_seginfo, 'Enable', 'off');
    set(handles.pushbutton_sec2_seginfo, 'Enable', 'off');
else
    set(handles.checkbox_sec2_seginfo, 'Value', 1);
end

try
    set(handles.edit_sec2_vistrack, 'String', loaded_para.inout_para.vistrack_path);
catch
    set(handles.edit_sec2_vistrack, 'String', '');
end
if isempty(get(handles.edit_sec2_vistrack, 'String'))
    set(handles.checkbox_sec2_vistrack, 'Value', 0);
    set(handles.edit_sec2_vistrack, 'Enable', 'off');
    set(handles.pushbutton_sec2_vistrack, 'Enable', 'off');
else
    set(handles.checkbox_sec2_vistrack, 'Value', 1);
end

% Segmentation
set(handles.axes_sec3, 'Visible', 'off');

% define var name
handles.seg_pushbutton_name = matlab.lang.makeValidName({'pushbutton_sec3_nav_nonspec', 'pushbutton_sec3_nav_binarization', ...
    'pushbutton_sec3_nav_activecontour', 'pushbutton_sec3_nav_watershed', ...
    'pushbutton_sec3_nav_ellipse', 'pushbutton_sec3_nav_correction'});
handles.seg_uipanel_name = matlab.lang.makeValidName({'uipanel_sec3_nonspec', 'uipanel_sec3_binarization', ...
    'uipanel_sec3_activecontour', 'uipanel_sec3_watershed', ...
    'uipanel_sec3_ellipse', 'uipanel_sec3_correction'});
handles.seg_raw_image = [];
handles.seg_curr_calculated_step = 0;
handles.seg_error_step = 0;
handles.seg_disp_step = 1;
handles = switch_seg_step(handles);
handles.seg_para = loaded_para.segmentation_para;
handles.prob_para = loaded_para.prob_para;
handles.track_para = loaded_para.track_para;
handles.signal_extraction_para = loaded_para.signal_extraction_para;

% non-specific parameter
set(handles.edit_sec3_nonspec_nucradius, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.nuc_radius));
set(handles.edit_sec3_nonspec_nucarea_from, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.allowed_nuc_size(1)));
set(handles.edit_sec3_nonspec_nucarea_to, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.allowed_nuc_size(2)));
set(handles.edit_sec3_nonspec_elliparea_from, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.allowed_ellipse_size(1)));
set(handles.edit_sec3_nonspec_elliparea_to, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.allowed_ellipse_size(2)));
set(handles.edit_sec3_nonspec_aspect, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.max_ellipse_aspect_ratio));
set(handles.edit_sec3_nonspec_hole, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.max_hole_size_to_fill));
set(handles.edit_sec3_nonspec_blur, 'String', num2str(loaded_para.segmentation_para.nonspecific_para.blur_radius));

% binarization
set(handles.checkbox_sec3_binarization_log, 'Value', loaded_para.segmentation_para.image_binarization_para.if_log);
switch lower(loaded_para.segmentation_para.image_binarization_para.background_subtraction_method)
    case 'none'
        set(handles.popupmenu_sec3_binarization_bgsub, 'Value', 1);
    case 'min'
        set(handles.popupmenu_sec3_binarization_bgsub, 'Value', 2);
    case 'mean'
        set(handles.popupmenu_sec3_binarization_bgsub, 'Value', 3);
    case 'median'
        set(handles.popupmenu_sec3_binarization_bgsub, 'Value', 4);
    otherwise
        error('Invalid value of segmentation_para.image_binarization_para.background_subtraction_method.');
end
switch lower(loaded_para.segmentation_para.image_binarization_para.binarization_method)
    case 'threshold'
        set(handles.popupmenu_sec3_binarization_method, 'Value', 1);
        set(handles.edit_sec3_binarization_threshold, 'Enable', 'off');
    case 'blob'
        set(handles.popupmenu_sec3_binarization_method, 'Value', 2);
    otherwise
        error('Invalid value of segmentation_para.image_binarization_para.binarization_method.');
end
set(handles.edit_sec3_binarization_threshold, 'String', num2str(loaded_para.segmentation_para.image_binarization_para.blob_threshold));

% active contour
set(handles.checkbox_sec3_activecontour_ifrun, 'Value', loaded_para.segmentation_para.active_contour_para.if_run);
if ~loaded_para.segmentation_para.active_contour_para.if_run
    set(handles.checkbox_sec3_activecontour_log, 'Enable', 'off');
    set(handles.popupmenu_sec3_activecontour_method, 'Enable', 'off');
end
set(handles.checkbox_sec3_activecontour_log, 'Value', loaded_para.segmentation_para.active_contour_para.if_log);
switch lower(loaded_para.segmentation_para.active_contour_para.active_contour_method)
    case 'local'
        set(handles.popupmenu_sec3_activecontour_method, 'Value', 1);
    case 'global'
        set(handles.popupmenu_sec3_activecontour_method, 'Value', 2);
    otherwise
        error('Invalid value of segmentation_para.active_contour_para.active_contour_method');
end

% watershed
set(handles.checkbox_sec3_watershed_ifrun, 'Value', loaded_para.segmentation_para.watershed_para.if_run);

% ellipse
set(handles.edit_sec3_ellipse_k, 'String', num2str(loaded_para.segmentation_para.ellipse_para.k));
set(handles.edit_sec3_ellipse_thd1, 'String', num2str(loaded_para.segmentation_para.ellipse_para.thd1));
set(handles.edit_sec3_ellipse_thd2, 'String', num2str(loaded_para.segmentation_para.ellipse_para.thd2));
set(handles.edit_sec3_ellipse_thdn, 'String', num2str(loaded_para.segmentation_para.ellipse_para.thdn));
set(handles.edit_sec3_ellipse_C, 'String', num2str(loaded_para.segmentation_para.ellipse_para.C));
set(handles.edit_sec3_ellipse_Tangle, 'String', num2str(loaded_para.segmentation_para.ellipse_para.T_angle));
set(handles.edit_sec3_ellipse_sig, 'String', num2str(loaded_para.segmentation_para.ellipse_para.sig));
set(handles.edit_sec3_ellipse_endpoint, 'String', num2str(loaded_para.segmentation_para.ellipse_para.Endpoint));
set(handles.edit_sec3_ellipse_gapsize, 'String', num2str(loaded_para.segmentation_para.ellipse_para.Gap_size));

% seg correction
set(handles.checkbox_sec3_correction_ifrun, 'Value', loaded_para.segmentation_para.seg_correction_para.if_run);
if ~loaded_para.segmentation_para.seg_correction_para.if_run
    set(handles.edit_sec3_correction_minprob, 'Enable', 'off');
end
set(handles.edit_sec3_correction_minprob, 'String', num2str(loaded_para.segmentation_para.seg_correction_para.min_corr_prob));

% Section 4. Page 1.
if isnumeric(loaded_para.prob_para.migration_speed)
    handles.migration_speed = 'custom';
    set(handles.uibuttongroup_sec4_speed, 'SelectedObject', handles.radiobutton_sec4_speed_custom);
    set(handles.pushbutton_sec4_speed, 'Enable', 'off');
    set(handles.edit_sec4_inf_resolution, 'Enable', 'off');
    set(handles.edit_sec4_inf_sample, 'Enable', 'off');
    set(handles.edit_sec4_speed_custom, 'String', num2str(loaded_para.prob_para.migration_speed));
else
    switch lower(loaded_para.prob_para.migration_speed)
        case 'global'
            set(handles.edit_sec4_speed_custom, 'Enable', 'off');
            set(handles.uibuttongroup_sec4_speed, 'SelectedObject', handles.radiobutton_sec4_speed_global);
            handles.migration_speed = 'global';
            set(handles.edit_sec4_inf_resolution, 'Enable', 'off');
            set(handles.edit_sec4_inf_sample, 'Enable', 'off');
        case 'time'
            set(handles.edit_sec4_speed_custom, 'Enable', 'off');
            set(handles.uibuttongroup_sec4_speed, 'SelectedObject', handles.radiobutton_sec4_speed_time);
            handles.migration_speed = 'time';
        case 'density'
            set(handles.edit_sec4_speed_custom, 'Enable', 'off');
            set(handles.uibuttongroup_sec4_speed, 'SelectedObject', handles.radiobutton_sec4_speed_density);
            handles.migration_speed = 'density';
        otherwise
            error('Invalid value of prob_para.migration_speed.');
    end
end
set(handles.edit_sec4_migfold, 'String', num2str(loaded_para.prob_para.max_migration_dist_fold));
set(handles.edit_sec4_inf_resolution, 'String', num2str(loaded_para.prob_para.migration_inference_resolution));
set(handles.edit_sec4_inf_sample, 'String', num2str(loaded_para.prob_para.migration_inference_min_samples));
set(handles.axes_sec4_speed, 'Visible', 'off');

% Section 4. Page 2.
switch lower(loaded_para.prob_para.mitosis_inference_option)
    case {'all', 'both'}
        set(handles.uibuttongroup_sec4_mito, 'SelectedObject', handles.radiobutton_sec4_mito_all);
    case 'before'
        set(handles.uibuttongroup_sec4_mito, 'SelectedObject', handles.radiobutton_sec4_mito_before);
    case 'after'
        set(handles.uibuttongroup_sec4_mito, 'SelectedObject', handles.radiobutton_sec4_mito_after);
    case 'none'
        set(handles.uibuttongroup_sec4_mito, 'SelectedObject', handles.radiobutton_sec4_mito_none);
    otherwise
        error('Invalid value of prob_para.mitosis_inference_option');
end
switch lower(loaded_para.prob_para.migration_option)
    case 'similarity'
        set(handles.uibuttongroup_sec4_migsim, 'SelectedObject', handles.radiobutton_sec4_migsim_both);
    case 'distance'
        set(handles.uibuttongroup_sec4_migsim, 'SelectedObject', handles.radiobutton_sec4_migsim_dist);
    otherwise
        error('Invalid value of prob_para.migration_option');
end
set(handles.edit_sec4_empty, 'String', num2str(loaded_para.prob_para.empty_prob));
set(handles.edit_sec4_null, 'String', num2str(loaded_para.prob_para.prob_nonmigration));
set(handles.edit_sec4_inout, 'String', num2str(loaded_para.prob_para.min_inout_prob));
set(handles.edit_sec4_gap, 'String', num2str(loaded_para.prob_para.max_migration_time-1));
if (loaded_para.prob_para.max_migration_time > 1)
    set(handles.text138, 'Visible', 'on');
else
    set(handles.text138, 'Visible', 'off');
end

% SECTION 5
set(handles.edit_sec5_minlength, 'String', num2str(loaded_para.track_para.min_track_length));
set(handles.edit_sec5_maxskip, 'String', num2str(loaded_para.track_para.max_num_frames_to_skip));
set(handles.edit_sec5_minscore_overall, 'String', num2str(loaded_para.track_para.min_track_score));
set(handles.edit_sec5_minscore_neighbor, 'String', num2str(loaded_para.track_para.min_track_score_per_step));
set(handles.edit_sec5_coexist, 'String', num2str(loaded_para.track_para.multiple_cells_penalty));
set(handles.edit_sec5_skip, 'String', num2str(loaded_para.track_para.skip_penalty));
set(handles.edit_sec5_swap, 'String', num2str(loaded_para.track_para.min_swap_score));
set(handles.edit_sec5_mitosis, 'String', num2str(loaded_para.track_para.mitosis_detection_min_prob));
set(handles.edit_sec5_critical, 'String', num2str(loaded_para.track_para.critical_length));

% SECTION 6
set(handles.edit_sec6_nucdist, 'String', num2str(loaded_para.signal_extraction_para.nuc_region_dist));
set(handles.edit_sec6_cytodist_inner, 'String', num2str(loaded_para.signal_extraction_para.cytoring_region_dist(1)));
set(handles.edit_sec6_cytodist_outer, 'String', num2str(loaded_para.signal_extraction_para.cytoring_region_dist(2)));
set(handles.edit_sec6_memdist, 'String', num2str(loaded_para.signal_extraction_para.background_dist));
temp = sprintf('% g', loaded_para.signal_extraction_para.intensity_percentile); temp = temp(2:end);
set(handles.edit_sec6_percentile, 'String', temp);
set(handles.edit_sec6_outlier, 'String', num2str(loaded_para.signal_extraction_para.outlier_percentile));

[imdata, ~, imalpha] = imread('utils/sig_ext.png');
image(imdata, 'AlphaData', imalpha, 'Parent', handles.axes_sec6);
set(handles.axes_sec6, 'Visible', 'off');

end
