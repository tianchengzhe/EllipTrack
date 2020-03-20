function paragenGUI_save_para( handles, path_to_save )
%PARAGENGUI_SAVE_PARA Generate parameter file.
%
%   Input
%       handles: Handles of GUI
%       path_to_save: Folder to save
%   Output: Empty


% open a file
fileID = fopen([adjust_path(path_to_save, 0), 'parameters.m'], 'wt');


% Introduction
fprintf(fileID, "function [ all_parameters ] = parameters()\n");
fprintf(fileID, "%%PARAMETERS Parameters of EllipTrack\n");
fprintf(fileID, "%%\n");
fprintf(fileID, "%%   Input: empty\n");
fprintf(fileID, "%%   Output:\n");
fprintf(fileID, "%%       all_parameters: Parameters organized in structs\n");
fprintf(fileID, "%%\n");
fprintf(fileID, "\n");


% MOVIE DEFINITION
fprintf(fileID, "%%%% MOVIE DEFINITION\n");
fprintf(fileID, "%% Parameters defining the movies.\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% image_type: Movie format. 3 options:\n");
fprintf(fileID, "%%   'seq': Movies are stored as image sequences. Each image contains one\n");
fprintf(fileID, "%%   channel at one frame.\n");
fprintf(fileID, "%%   'stack': Movies are stored as image stacks. Each stack contains one\n");
fprintf(fileID, "%%   channel at all frames.\n");
fprintf(fileID, "%%   'nd2': Movies are stored in the Nikon ND2 format. Movies can be stored\n");
fprintf(fileID, "%%   in multiple segments (files). Each segment contains images of all\n");
fprintf(fileID, "%%   channels.\n");
fprintf(fileID, "image_type = '%s';\n", handles.image_type);
fprintf(fileID, "\n");
fprintf(fileID, "%% image_path: Paths to the folders storing the images.\n");
fprintf(fileID, "%%   Image Sequences/Stacks: nx1 cell array. Each row stores the path to \n");
fprintf(fileID, "%%   the folder with the images of the i-th channel.\n");
fprintf(fileID, "%%   nd2: nx1 cell array. Each row stores the path to the folder with the\n");
fprintf(fileID, "%%   i-th segment.\n");
fprintf(fileID, "image_path = {");
switch lower(handles.image_type)
    case 'nd2'
        num_entry = length(handles.nd2_image_path);
        if (num_entry==0)
            fprintf(fileID, "};\n");
        else
            for i=1:num_entry-1
                fprintf(fileID, "'%s';\n    ", handles.nd2_image_path{i});
            end
            fprintf(fileID, "'%s'};\n", handles.nd2_image_path{num_entry});
        end
        
    otherwise
        for i=1:handles.num_channels-1
            fprintf(fileID, "'%s';\n    ", get(handles.(handles.channel_operator{i}{3}), 'String'));
        end
        fprintf(fileID, "'%s'};\n", get(handles.(handles.channel_operator{handles.num_channels}{3}), 'String'));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% filename_format: Formats of image filenames. \n");
fprintf(fileID, "%%   Image Sequences/Stacks: Full filenames are required.\n");
fprintf(fileID, "%%   nd2: First few characters of filenames are sufficient.\n");
fprintf(fileID, "%%   Available format operators:\n");
fprintf(fileID, "%%   %%r: Row ID (numeric)\n");
fprintf(fileID, "%%   %%a: Row ID (letter, lower case)\n");
fprintf(fileID, "%%   %%b: Row ID (letter, upper case)\n");
fprintf(fileID, "%%   %%c: Column ID (numeric)\n");
fprintf(fileID, "%%   %%s: Site ID (numeric, not for ND2 format)\n");
fprintf(fileID, "%%   %%i: Channel ID (numeric, not for ND2 format)\n");
fprintf(fileID, "%%   %%n: Channel Name (string, not for ND2 format)\n");
fprintf(fileID, "%%   %%t: Frame ID (numeric, Image Sequence only)\n");
fprintf(fileID, "%%   Prefix zeros: %%0Nr (N digits)\n");
fprintf(fileID, "filename_format = '%s';\n", get(handles.edit_sec1_filename, 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% channel_names: Names of the fluorescent channels.\n");
fprintf(fileID, "%%   nx1 cell array. Each row stores the name of the i-th channel.\n");
fprintf(fileID, "channel_names = {");
for i=1:handles.num_channels-1
    fprintf(fileID, "'%s';\n    ", get(handles.(handles.channel_operator{i}{1}), 'String'));
end
fprintf(fileID, "'%s'};\n", get(handles.(handles.channel_operator{handles.num_channels}{1}), 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% signal_names: Names of the signals to measure.\n");
fprintf(fileID, "%%   nx1 cell array. Each row stores the name of the i-th signal. Must match\n");
fprintf(fileID, "%%   the order of channel_names.\n");
fprintf(fileID, "signal_names = {");
for i=1:handles.num_channels-1
    fprintf(fileID, "'%s';\n    ", get(handles.(handles.channel_operator{i}{2}), 'String'));
end
fprintf(fileID, "'%s'};\n", get(handles.(handles.channel_operator{handles.num_channels}{2}), 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% if_compute_cytoring: Whether to compute signals in the cytoplasmic ring.\n");
fprintf(fileID, "%%   nx1 array. Each row is either 1 (compute) or 0 (not compute). Must\n");
fprintf(fileID, "%%   match the order of channel_names.\n");
if (handles.num_channels == 1)
    fprintf(fileID, "if_compute_cytoring = 0;\n");
else
    fprintf(fileID, "if_compute_cytoring = [");
    for i=1:handles.num_channels-1
        fprintf(fileID, "%g;\n    ", get(handles.(handles.channel_operator{i}{8}), 'Value'));
    end
    fprintf(fileID, "%g];\n", get(handles.(handles.channel_operator{handles.num_channels}{8}), 'Value'));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% bias_paths: Paths to the MAT files storing the illumination biases.\n");
fprintf(fileID, "%%   nx1 cell array. Each row stores the path to the bias of the i-th\n");
fprintf(fileID, "%%   channel. Must match the order of channel_names.\n");
fprintf(fileID, "bias_paths = {");
for i=1:handles.num_channels-1
    fprintf(fileID, "'%s';\n    ", get(handles.(handles.channel_operator{i}{5}), 'String'));
end
fprintf(fileID, "'%s'};\n", get(handles.(handles.channel_operator{handles.num_channels}{5}), 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% cmosoffset_path: Path to the MAT file storing the camera dark noises.\n");
fprintf(fileID, "cmosoffset_path = '%s';\n", get(handles.edit_sec1_cmos, 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% wells_to_track: Movie coordinates in a multi-well plate.\n");
fprintf(fileID, "%%   nx3 array. Each row stores the Row, Column, and Site ID of one movie.\n");
fprintf(fileID, "%%   If not performed in a multi-well plate, enter [1, 1, 1].\n");
if (get(handles.checkbox_sec1_well, 'Value') == 1) % not multi-well format
    fprintf(fileID, "wells_to_track = [1, 1, 1];\n");
else
    row_id_from = str2double(get(handles.edit_sec1_row_from, 'String'));
    row_id_to = str2double(get(handles.edit_sec1_row_to, 'String'));
    col_id_from = str2double(get(handles.edit_sec1_column_from, 'String'));
    col_id_to = str2double(get(handles.edit_sec1_column_to, 'String'));
    site_id_from = str2double(get(handles.edit_sec1_site_from, 'String'));
    site_id_to = str2double(get(handles.edit_sec1_site_to, 'String'));
    if (isnan(row_id_from) || isnan(row_id_to) || isnan(col_id_from) || isnan(col_id_to) || isnan(site_id_from) || isnan(site_id_to))
        fprintf(fileID, "wells_to_track = [];\n");
    else
        fprintf(fileID, "wells_to_track = allcomb(%g:%g, %g:%g, %g:%g);\n", row_id_from, row_id_to, col_id_from, col_id_to, site_id_from, site_id_to);
    end
end
fprintf(fileID, "\n");
fprintf(fileID, "%% frames_to_track: Frame IDs.\n");
frame_id_from = str2double(get(handles.edit_sec1_frame_from, 'String'));
frame_id_to = str2double(get(handles.edit_sec1_frame_to, 'String'));
if (isnan(frame_id_from) || isnan(frame_id_to))
    fprintf(fileID, "frames_to_track = [];\n");
else
    fprintf(fileID, "frames_to_track = %g:%g;\n", frame_id_from, frame_id_to);
end
fprintf(fileID, "\n");
fprintf(fileID, "%% jitter_correction_method: Method of jitter correction. 3 options:\n");
fprintf(fileID, "%%   'none': No jitter correction will be performed. Suggested if jitters\n");
fprintf(fileID, "%%   are negligible.\n");
fprintf(fileID, "%%   'local': Local method. Jitter correction will be performed on each\n");
fprintf(fileID, "%%   movie, independent from other movies. Suggested if movies have big\n");
fprintf(fileID, "%%   jitters.\n");
fprintf(fileID, "%%   'global': Global method. First perform the Local method. Jitters will\n");
fprintf(fileID, "%%   then be corrected by the locations of wells on the multi-well plate.\n");
fprintf(fileID, "%%   Suggested for improving the accuracy of jitter inference. Require at\n");
fprintf(fileID, "%%   least 6 wells.\n");
switch get(handles.uibuttongroup_sec1_jitter, 'SelectedObject')
    case handles.radiobutton_sec1_jitter_none
        fprintf(fileID, "jitter_correction_method = 'none';\n");
    case handles.radiobutton_sec1_jitter_local
        fprintf(fileID, "jitter_correction_method = 'local';\n");
    case handles.radiobutton_sec1_jitter_global
        fprintf(fileID, "jitter_correction_method = 'global';\n");
end
fprintf(fileID, "\n");
fprintf(fileID, "%% num_cores: Number of logical cores for parallel computing.\n");
fprintf(fileID, "num_cores = %s;\n", get(handles.edit_sec1_core, 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "movie_definition = struct('image_type', image_type, ...\n");
fprintf(fileID, "    'image_path', {adjust_path(image_path)}, 'filename_format', filename_format, ...\n");
fprintf(fileID, "    'channel_names', {channel_names}, 'signal_names', {signal_names}, ...\n");
fprintf(fileID, "    'if_compute_cytoring', if_compute_cytoring, 'bias_paths', {adjust_path(bias_paths)}, ...\n");
fprintf(fileID, "    'cmosoffset_path', adjust_path(cmosoffset_path), 'wells_to_track', wells_to_track, ...\n");
fprintf(fileID, "    'frames_to_track', frames_to_track, 'jitter_correction_method', jitter_correction_method, ...\n");
fprintf(fileID, "    'num_cores', num_cores);\n");
fprintf(fileID, "\n");

% INPUT/OUTPUT
fprintf(fileID, "%%%% INPUT/OUTPUT\n");
fprintf(fileID, "%% Parameters defining the input and output files.\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% training_data_path: Paths to the training datasets.\n");
fprintf(fileID, "%%   nx1 cell array. Each row stores the path to one training dataset.\n");
fprintf(fileID, "%%   Use empty cell array ({}) if no training datasets are available.\n");
fprintf(fileID, "training_data_path = {");
num_entry = length(handles.all_training_path);
if num_entry == 0
    fprintf(fileID, "};\n");
else
    for i=1:num_entry-1
        fprintf(fileID, "'%s';\n    ", handles.all_training_path{i});
    end
    fprintf(fileID, "'%s'};\n", handles.all_training_path{num_entry});
end
fprintf(fileID, "\n");
fprintf(fileID, "%% output_path: Path to the folder storing the output MAT files.\n");
fprintf(fileID, "output_path = '%s';\n", get(handles.edit_sec2_output, 'String'));
fprintf(fileID, "\n");
fprintf(fileID, "%% mask_path: Path to the folder storing the mask.\n");
fprintf(fileID, "%%   A mask is the binarized nuclear image before Ellipse Fitting.\n");
fprintf(fileID, "%%   Use empty character ('') if not generating this output.\n");
fprintf(fileID, "%%   Suggested for evaluating the accuracy of segmentation.\n");
if get(handles.checkbox_sec2_mask, 'Value') == 0
    fprintf(fileID, "mask_path = '';\n");
else
    fprintf(fileID, "mask_path = '%s';\n", get(handles.edit_sec2_mask, 'String'));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% ellipse_movie_path: Path to the folder storing the 'ellipse movies'.\n");
fprintf(fileID, "%%   An 'ellipse movie' is the autoscaled nuclear image overlaid by fitted\n");
fprintf(fileID, "%%   ellipses.\n");
fprintf(fileID, "%%   Use empty character ('') if not generating this output.\n");
fprintf(fileID, "%%   Suggested for evaluating the accuracy of segmentation.\n");
if get(handles.checkbox_sec2_ellipse, 'Value') == 0
    fprintf(fileID, "ellipse_movie_path = '';\n");
else
    fprintf(fileID, "ellipse_movie_path = '%s';\n", get(handles.edit_sec2_ellipse, 'String'));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% seg_info_path: Path to the folder storing the 'seg info'.\n");
fprintf(fileID, "%%   A 'seg info' is the ellipse information of one frame. \n");
fprintf(fileID, "%%   Use empty character ('') if not generating this output.\n");
fprintf(fileID, "%%   Suggested if training datasets will be constructed from this movie.\n");
if get(handles.checkbox_sec2_seginfo, 'Value') == 0
    fprintf(fileID, "seg_info_path = '';\n");
else
    fprintf(fileID, "seg_info_path = '%s';\n", get(handles.edit_sec2_seginfo, 'String'));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% vistrack_path: Path to the folder storing the 'vistrack movie'.\n");
fprintf(fileID, "%%   A 'vistrack movie' is the autoscaled nuclear image overlaid by fitted\n");
fprintf(fileID, "%%   ellipses and cell track IDs.\n");
fprintf(fileID, "%%   Use empty character ('') if not generating this output.\n");
fprintf(fileID, "%%   Suggested for evaluating the accuracy of tracking.\n");
if get(handles.checkbox_sec2_vistrack, 'Value') == 0
    fprintf(fileID, "vistrack_path = '';\n");
else
    fprintf(fileID, "vistrack_path = '%s';\n", get(handles.edit_sec2_vistrack, 'String'));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "inout_para = struct('training_data_path', {adjust_path(training_data_path)}, ...\n");
fprintf(fileID, "    'output_path', adjust_path(output_path), ...\n");
fprintf(fileID, "    'mask_path', adjust_path(mask_path), 'ellipse_movie_path', adjust_path(ellipse_movie_path), ...\n");
fprintf(fileID, "    'seg_info_path', adjust_path(seg_info_path), 'vistrack_path', adjust_path(vistrack_path));\n");
fprintf(fileID, "\n");

% SEGMENTATION
fprintf(fileID, "%%%% SEGMENTATION\n");
fprintf(fileID, "%% Parameters controlling Segmentation\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 1. Non-Specific Parameters\n");
fprintf(fileID, "%% Parameters used by all Segmentation Steps.\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% nuc_radius: Average radius (in pixels) of a nucleus.\n");
fprintf(fileID, "nuc_radius = %g;\n", handles.seg_para.nonspecific_para.nuc_radius);
fprintf(fileID, "\n");
fprintf(fileID, "%% allowed_nuc_size: Acceptable areas (in pixels) of a nucleus.\n");
fprintf(fileID, "%%   1x2 array storing the lower and upper limits.\n");
fprintf(fileID, "%%   Mask components not within the range will be removed.\n");
fprintf(fileID, "allowed_nuc_size = [%g, %g];\n", handles.seg_para.nonspecific_para.allowed_nuc_size(1), handles.seg_para.nonspecific_para.allowed_nuc_size(2));
fprintf(fileID, "\n");
fprintf(fileID, "%% allowed_ellipse_size: Acceptable areas (in pixels) of an ellipse.\n");
fprintf(fileID, "%%   1x2 array storing the lower and upper limits.\n");
fprintf(fileID, "%%   Ellipses not within the range will be removed.\n");
fprintf(fileID, "allowed_ellipse_size = [%g, %g];\n", handles.seg_para.nonspecific_para.allowed_ellipse_size(1), handles.seg_para.nonspecific_para.allowed_ellipse_size(2));
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] max_ellipse_aspect_ratio: Maximal aspect ratio (>1) of an\n");
fprintf(fileID, "%% ellipse.\n");
fprintf(fileID, "%%   Ellipses with greater aspect ratios will be removed.\n");
fprintf(fileID, "max_ellipse_aspect_ratio = %g;\n", handles.seg_para.nonspecific_para.max_ellipse_aspect_ratio);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] max_hole_size_to_fill: Maximal hole area (in pixels) to fill.\n");
fprintf(fileID, "%%   A hole is defined as a set of background pixels surrounded by\n");
fprintf(fileID, "%%   foreground pixels in a mask.\n");
fprintf(fileID, "%%   Holes with smaller areas will be converted to foreground pixels.\n");
fprintf(fileID, "%%   Helpful if a nucleus contains some dark regions.\n");
fprintf(fileID, "max_hole_size_to_fill = %g;\n", handles.seg_para.nonspecific_para.max_hole_size_to_fill);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] blur_radius: Radius (in pixels) of the disk for image\n");
fprintf(fileID, "%% smoothing.\n");
fprintf(fileID, "blur_radius = %g;\n", handles.seg_para.nonspecific_para.blur_radius);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "nonspecific_para = struct('nuc_radius', nuc_radius, 'allowed_nuc_size', allowed_nuc_size, ...\n");
fprintf(fileID, "    'allowed_ellipse_size', allowed_ellipse_size, 'max_ellipse_aspect_ratio', max_ellipse_aspect_ratio, ...\n");
fprintf(fileID, "    'max_hole_size_to_fill', max_hole_size_to_fill, 'blur_radius', blur_radius);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 2. Image Binarization\n");
fprintf(fileID, "%% Parameters controlling Image Binarization\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% if_log: Whether to log-transform the images. Binary variable:\n");
fprintf(fileID, "%%   1: log-transform. Suggested if nuclei have heterogeneous brightness.\n");
fprintf(fileID, "%%   0: not log-transform. Suggested if nuclei have homogeneous brightness.\n");
fprintf(fileID, "if_log = %g;\n", handles.seg_para.image_binarization_para.if_log);
fprintf(fileID, "\n");
fprintf(fileID, "%% background_subtraction_method: Method of Background Subtraction. 4 options:\n");
fprintf(fileID, "%%   'none': No background subtraction will be performed. Suggested if the\n");
fprintf(fileID, "%%   images have low backgrounds.\n");
fprintf(fileID, "%%   'min', 'median', and 'mean': Images will be subtracted by the minimal,\n");
fprintf(fileID, "%%   median, and mean intensity of the background. Suggested if the images\n");
fprintf(fileID, "%%   have high backgrounds.\n");
fprintf(fileID, "background_subtraction_method = '%s';\n", handles.seg_para.image_binarization_para.background_subtraction_method);
fprintf(fileID, "\n");
fprintf(fileID, "%% binarization_method. Method of Image Binarization. 2 options: \n");
fprintf(fileID, "%%   'threshold': Thresholding. A threshold is applied to the image\n");
fprintf(fileID, "%%   intensities. Suggested if nuclei have homogeneous brightness. \n");
fprintf(fileID, "%%   'blob': Blob Detection. A threshold is applied to the hessian of image\n");
fprintf(fileID, "%%   intensities. Suggested if nuclei have heterogeneous brightness.\n");
fprintf(fileID, "binarization_method = '%s';\n", handles.seg_para.image_binarization_para.binarization_method);
fprintf(fileID, "\n");
fprintf(fileID, "%% blob_threshold. Blob Detection only. Threshold of the hessian.\n");
fprintf(fileID, "blob_threshold = %g;\n", handles.seg_para.image_binarization_para.blob_threshold);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct \n");
fprintf(fileID, "image_binarization_para = struct('background_subtraction_method', background_subtraction_method, ...\n");
fprintf(fileID, "    'if_log', if_log, 'binarization_method', binarization_method, 'blob_threshold', blob_threshold);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 3. Active Contour\n");
fprintf(fileID, "%% Parameters controlling Active Contour\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% if_run: Whether to run Active Contour. Binary variable:\n");
fprintf(fileID, "%%   1: run. Suggested if Image Binarization does not detect accurate\n");
fprintf(fileID, "%%   nuclear boundary.\n");
fprintf(fileID, "%%   0: not run. Suggested if Image Binarization results are satisfactory.\n");
fprintf(fileID, "if_run = %g;\n", handles.seg_para.active_contour_para.if_run);
fprintf(fileID, "\n");
fprintf(fileID, "%% if_log: Whether to log-transform the images. Binary variable:\n");
fprintf(fileID, "%%   1: log-transform. Suggested if nuclei have heterogeneous brightness.\n");
fprintf(fileID, "%%   0: not log-transform. Suggested if nuclei have homogeneous brightness.\n");
fprintf(fileID, "if_log = %g;\n", handles.seg_para.active_contour_para.if_log);
fprintf(fileID, "\n");
fprintf(fileID, "%% active_contour_method: Method of active contour. 2 options:\n");
fprintf(fileID, "%%   'local': Local method. Active contour is applied to the neighborhood of\n");
fprintf(fileID, "%%   every nucleus. Suggested if nuclei have heterogeneous brightness.\n");
fprintf(fileID, "%%   'global': Global method. Active contour is applied to the entire image\n");
fprintf(fileID, "%%   at once. Suggested if nuclei have homogeneous brightness.\n");
fprintf(fileID, "active_contour_method = '%s';\n", handles.seg_para.active_contour_para.active_contour_method);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct \n");
fprintf(fileID, "active_contour_para = struct('if_run', if_run, 'if_log', if_log, ...\n");
fprintf(fileID, "    'active_contour_method', active_contour_method);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 4. Watershed\n");
fprintf(fileID, "%% Parameters controlling Watershed\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% if_run: Whether to run Watershed. Binary variable:\n");
fprintf(fileID, "%%   1: run. Suggested if nuclei overlap frequently.\n");
fprintf(fileID, "%%   0: not run. Suggested if nuclei do not frequently overlap.\n");
fprintf(fileID, "if_run = %g;\n", handles.seg_para.watershed_para.if_run);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "watershed_para = struct('if_run', if_run);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 5. Ellipse Fitting\n");
fprintf(fileID, "%% Parameters controlling Ellipse Fitting\n");
fprintf(fileID, "%% Defined in Zafari et al 2015. Descriptions are adapted from the source\n");
fprintf(fileID, "%% code.\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] k: Consider up to k-th adjacent points to the corner point.\n");
fprintf(fileID, "k = %g;\n", handles.seg_para.ellipse_para.k);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] thd1: Distance (in pixels) between the ellipse centroid of the\n");
fprintf(fileID, "%% combined contour segments and the ellipse fitted to each segment.\n");
fprintf(fileID, "thd1 = %g;\n", handles.seg_para.ellipse_para.thd1);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] thd2: Distance (in pixels) between the centroids of ellipse\n");
fprintf(fileID, "%% fitted to each segment.\n");
fprintf(fileID, "thd2 = %g;\n", handles.seg_para.ellipse_para.thd2);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] thdn: Distance (in pixels) between contour center points.\n");
fprintf(fileID, "thdn = %g;\n", handles.seg_para.ellipse_para.thdn);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] C: Minimal aspect ratio for corner detection.\n");
fprintf(fileID, "C = %g;\n", handles.seg_para.ellipse_para.C);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] T_angle: Maximal angle (in degrees) of a corner.\n");
fprintf(fileID, "T_angle = %g;\n", handles.seg_para.ellipse_para.T_angle);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] sig: Standard deviation (in pixels) of the Gaussian filter.\n");
fprintf(fileID, "sig = %g;\n", handles.seg_para.ellipse_para.sig);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] Endpoint: Whether to add the end points of a curve as corner.\n");
fprintf(fileID, "%%   Binary variable. 1: add; 0: not add.\n");
fprintf(fileID, "Endpoint = %g;\n", handles.seg_para.ellipse_para.Endpoint);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] Gap_size: Maximal length of gaps (in pixels) in the contours\n");
fprintf(fileID, "%% to fill.\n");
fprintf(fileID, "Gap_size = %g;\n", handles.seg_para.ellipse_para.Gap_size);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "ellipse_para = struct('k', k, 'thd1', thd1, 'thd2', thd2, 'thdn', thdn, 'C', C, 'T_angle', T_angle, ...\n");
fprintf(fileID, "    'sig', sig, 'Endpoint', Endpoint, 'Gap_size', Gap_size);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 6. Correction with Training Data\n");
fprintf(fileID, "%% Parameters controlling Correction with Training Data\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% if_run: Whether to run Correction with Training Data. Binary variable:\n");
fprintf(fileID, "%%   1: run. Suggested if training datasets are available and well-predict\n");
fprintf(fileID, "%%   the number of nuclei in each ellipse.\n");
fprintf(fileID, "%%   0: not run. Suggested if training datasets are not available or not\n");
fprintf(fileID, "%%   suitable.\n");
fprintf(fileID, "if_run = %g;\n", handles.seg_para.seg_correction_para.if_run);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] min_corr_prob: Minimal probability (0 to 1) for correction.\n");
fprintf(fileID, "min_corr_prob = %g;\n", handles.seg_para.seg_correction_para.min_corr_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "seg_correction_para = struct('if_run', if_run, 'min_corr_prob', min_corr_prob);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% assemble everything into a struct\n");
fprintf(fileID, "segmentation_para = struct('nonspecific_para', nonspecific_para, ...\n");
fprintf(fileID, "    'image_binarization_para', image_binarization_para, ...\n");
fprintf(fileID, "    'active_contour_para', active_contour_para, 'watershed_para', watershed_para, ...\n");
fprintf(fileID, "    'ellipse_para', ellipse_para, 'seg_correction_para', seg_correction_para);\n");
fprintf(fileID, "\n");

% PREDICTION OF EVENTS
fprintf(fileID, "%%%% PREDICTING OF EVENTS\n");
fprintf(fileID, "%% Parameters controlling Prediction of Events\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] empty_prob: Probability of an event (0 to 1) if no training\n");
fprintf(fileID, "%% data is provided.\n");
fprintf(fileID, "empty_prob = %g;\n", handles.prob_para.empty_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% mitosis_inference_option: Method of mitosis inference. 4 options:\n");
fprintf(fileID, "%%   'all' or 'both': Mother cells need to have high probabilities of being\n");
fprintf(fileID, "%%   mitotic, and daughter cells need to have high probabilities of being\n");
fprintf(fileID, "%%   newly born.\n");
fprintf(fileID, "%%   'before': Mother cells need to have high probabilities of being\n");
fprintf(fileID, "%%   mitotic. No requirement on daughter cells.\n");
fprintf(fileID, "%%   'after': Daughter cells need to have high probabilities of being newly\n");
fprintf(fileID, "%%   born. No requirement on mother cells.\n");
fprintf(fileID, "%%   'none': No requirement on either mother or daughter cells.\n");
fprintf(fileID, "%%   In principle 'all' should be used, though flexibility is provided in\n");
fprintf(fileID, "%%   case probabilities of some events do not reflect reality.\n");
switch get(handles.uibuttongroup_sec4_mito, 'SelectedObject')
    case handles.radiobutton_sec4_mito_all
        fprintf(fileID, "mitosis_inference_option = 'all';\n");
    case handles.radiobutton_sec4_mito_before
        fprintf(fileID, "mitosis_inference_option = 'before';\n");
    case handles.radiobutton_sec4_mito_after
        fprintf(fileID, "mitosis_inference_option = 'after';\n");
    case handles.radiobutton_sec4_mito_none
        fprintf(fileID, "mitosis_inference_option = 'none';\n");
end
fprintf(fileID, "\n");
fprintf(fileID, "%% migration_option: Method of migration probability calculation. 2 options:\n");
fprintf(fileID, "%%   'similarity': Consider both the migration distance and the probability\n");
fprintf(fileID, "%%   that the two ellipses belong to the same cell.\n");
fprintf(fileID, "%%   'distance': Consider only the migration distance.\n");
fprintf(fileID, "%%   In principle 'similarity' should be used, though flexibility is\n");
fprintf(fileID, "%%   provided in case ellipse similarity is not well-calculated.\n");
switch get(handles.uibuttongroup_sec4_migsim, 'SelectedObject')
    case handles.radiobutton_sec4_migsim_both
        fprintf(fileID, "migration_option = 'similarity';\n");
    case handles.radiobutton_sec4_migsim_dist
        fprintf(fileID, "migration_option = 'distance';\n");
end
fprintf(fileID, "\n");
fprintf(fileID, "%% migration_speed: Migration speed. \n");
fprintf(fileID, "%%   Defined as the standard deviation of random walk in one direction and\n");
fprintf(fileID, "%%   one frame. 4 options:\n");
fprintf(fileID, "%%   'global': All cells have the same migration speed. Suggested if cells\n");
fprintf(fileID, "%%   migrate independently of other cells and factors.\n");
fprintf(fileID, "%%   'time': Migration speed is dependent on time. Suggested if cell\n");
fprintf(fileID, "%%   migration mode changes, such as due to drug addition.\n");
fprintf(fileID, "%%   'density': Migration speed is dependent on local cell density.\n");
fprintf(fileID, "%%   Suggested if cell migration is limited by the available space or\n");
fprintf(fileID, "%%   controlled by cell-cell communication.\n");
fprintf(fileID, "%%   custom: A numeric number specifying the migration speed of all cells.\n");
fprintf(fileID, "%%   Suggested if training datasets are unavailable or the other options do\n");
fprintf(fileID, "%%   not produce satisfactory results.\n");
fprintf(fileID, "%%   The first three options require training datasets.\n");
switch (handles.migration_speed)
    case 'custom'
        fprintf(fileID, "migration_speed = %s;\n", get(handles.edit_sec4_speed_custom, 'String'));
    otherwise
        fprintf(fileID, "migration_speed = '%s';\n", handles.migration_speed);
end
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] max_migration_dist_fold: Maximal distance (in folds of the\n");
fprintf(fileID, "%% migration speed) a cell can migrate in a frame.\n");
fprintf(fileID, "max_migration_dist_fold = %g;\n", handles.prob_para.max_migration_dist_fold);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] migration_inference_resolution: 'time' and 'density' only.\n");
fprintf(fileID, "%% Resolution of time (in frames) or cell density (in number of cells) for\n");
fprintf(fileID, "%% inference.\n");
fprintf(fileID, "migration_inference_resolution = %g;\n", handles.prob_para.migration_inference_resolution);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] migration_inference_min_samples: 'time' and 'density' only.\n");
fprintf(fileID, "%% Minimal number of samples for inference.\n");
fprintf(fileID, "migration_inference_min_samples = %g;\n", handles.prob_para.migration_inference_min_samples);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] prob_nonmigration: Null probability (0 to 1) of migration.\n");
fprintf(fileID, "prob_nonmigration = %g;\n", handles.prob_para.prob_nonmigration);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] min_inout_prob: Minimal probability (0 to 1) to migrate in/out\n");
fprintf(fileID, "%% of the field of view.\n");
fprintf(fileID, "min_inout_prob = %g;\n", handles.prob_para.min_inout_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] max_migration_time: Maximal number of frames in a migration\n");
fprintf(fileID, "%% event. \n");
fprintf(fileID, "%%   max_migration_time-1 equals to the maximal number of frames a track can\n");
fprintf(fileID, "%%   skip.\n");
fprintf(fileID, "%%   Warning: Local track correction is not optimized for tracks skipping\n");
fprintf(fileID, "%%   any frames. Error rate might be high.\n");
fprintf(fileID, "max_migration_time = %g;\n", handles.prob_para.max_migration_time);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "prob_para = struct('empty_prob', empty_prob, 'mitosis_inference_option', mitosis_inference_option, ...\n");
fprintf(fileID, "    'migration_option', migration_option, 'migration_speed', migration_speed, ...\n");
fprintf(fileID, "    'max_migration_dist_fold', max_migration_dist_fold, 'migration_inference_resolution', migration_inference_resolution, ...\n");
fprintf(fileID, "    'migration_inference_min_samples', migration_inference_min_samples, 'prob_nonmigration', prob_nonmigration, ...\n");
fprintf(fileID, "    'min_inout_prob', min_inout_prob, 'max_migration_time', max_migration_time);\n");
fprintf(fileID, "\n");

% TRACK LINKING
fprintf(fileID, "%%%% TRACK LINKING\n");
fprintf(fileID, "%% Parameters controlling Track Linking\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Penalty score\n");
fprintf(fileID, "%% [Advanced] skip_penalty: Penalty score for skipping one frame.\n");
fprintf(fileID, "skip_penalty = %g;\n", handles.track_para.skip_penalty);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] multiple_cells_penalty: Penalty score for two tracks\n");
fprintf(fileID, "%% co-existing in one ellipse.\n");
fprintf(fileID, "multiple_cells_penalty = %g;\n", handles.track_para.multiple_cells_penalty);
fprintf(fileID, "\n");
fprintf(fileID, "%% Minimal score\n");
fprintf(fileID, "%% [Advanced] min_track_score: Minimal score of a track.\n");
fprintf(fileID, "%%   Cell tracks with lower scores will not be considered.\n");
fprintf(fileID, "min_track_score = %g;\n", handles.track_para.min_track_score);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] min_track_score_per_step: Minimal score of a track between two\n");
fprintf(fileID, "%% neighboring frames.\n");
fprintf(fileID, "%%   Cell tracks with lower scores will not be considered.\n");
fprintf(fileID, "min_track_score_per_step = %g;\n", handles.track_para.min_track_score_per_step);
fprintf(fileID, "\n");
fprintf(fileID, "%% Local Track Correction (Post-Processing)\n");
fprintf(fileID, "%% [Advanced] min_swap_score: Minimal score to gain if two tracks are\n");
fprintf(fileID, "%% swapped.\n");
fprintf(fileID, "%%   Swaps with lower score gains will not be implemented.\n");
fprintf(fileID, "min_swap_score = %g;\n", handles.track_para.min_swap_score);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] mitosis_detection_min_prob: Minimal probability (0 to 1) for\n");
fprintf(fileID, "%% mitosis detection.\n");
fprintf(fileID, "%%   Mitosis will not be detected if either mother or daughter cells have\n");
fprintf(fileID, "%%   probabilities lower than this value.\n");
fprintf(fileID, "mitosis_detection_min_prob = %g;\n", handles.track_para.mitosis_detection_min_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] critical_length: Critical length (in frames) of track absence\n");
fprintf(fileID, "%% due to undersegmentation.\n");
fprintf(fileID, "%%   Suggested to be 10-20%% of a typical cell cycle duration.\n");
fprintf(fileID, "critical_length = %g;\n", handles.track_para.critical_length);
fprintf(fileID, "\n");
fprintf(fileID, "%% min_track_length: Minimal length (in frames) of a valid track.\n");
fprintf(fileID, "%%   Tracks shorter than this value will be removed.\n");
fprintf(fileID, "min_track_length = %g;\n", handles.track_para.min_track_length);
fprintf(fileID, "\n");
fprintf(fileID, "%% max_num_frames_to_skip: Maximal number of frames a valid track can skip.\n");
fprintf(fileID, "%%   Tracks skipping more than this value will be removed.\n");
fprintf(fileID, "max_num_frames_to_skip = %g;\n", handles.track_para.max_num_frames_to_skip);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "track_para = struct('skip_penalty', skip_penalty, 'multiple_cells_penalty', multiple_cells_penalty, ...\n");
fprintf(fileID, "    'min_track_score', min_track_score, 'min_track_score_per_step', min_track_score_per_step, ...\n");
fprintf(fileID, "    'min_swap_score', min_swap_score, 'mitosis_detection_min_prob', mitosis_detection_min_prob, ...\n");
fprintf(fileID, "    'critical_length', critical_length, 'min_track_length', min_track_length, ...\n");
fprintf(fileID, "    'max_num_frames_to_skip', max_num_frames_to_skip);\n");
fprintf(fileID, "\n");

% SIGNAL EXTRACTION
fprintf(fileID, "%%%% SIGNAL EXTRACTION\n");
fprintf(fileID, "%% Parameters controlling Signal Extraction\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% cytoring_region_dist: Distances (in pixels) between the cytoplasmic ring\n");
fprintf(fileID, "%% and the ellipse contour.\n");
fprintf(fileID, "%%   1x2 array storing the distances of inner and outer boundary of the\n");
fprintf(fileID, "%%   cytoplasmic ring.\n");
fprintf(fileID, "cytoring_region_dist = [%g, %g];\n", handles.signal_extraction_para.cytoring_region_dist(1), handles.signal_extraction_para.cytoring_region_dist(2));
fprintf(fileID, "\n");
fprintf(fileID, "%% nuc_region_dist: Distances (in pixels) between the nucleus and the\n");
fprintf(fileID, "%% ellipse contour.\n");
fprintf(fileID, "nuc_region_dist = %g;\n", handles.signal_extraction_para.nuc_region_dist);
fprintf(fileID, "\n");
fprintf(fileID, "%% background_dist: Distances (in pixels) between the image background and\n");
fprintf(fileID, "%% the ellipse contour.\n");
fprintf(fileID, "background_dist = %g;\n", handles.signal_extraction_para.background_dist);
fprintf(fileID, "\n");
fprintf(fileID, "%% intensity_percentile: Percentile of intensities (0 to 100) to measure.\n");
fprintf(fileID, "%%   1xn array. Each element defines a percentile to measure.\n");
if length(handles.signal_extraction_para.intensity_percentile) == 1
    fprintf(fileID, "intensity_percentile = %g;\n", handles.signal_extraction_para.intensity_percentile);
else
    temp = sprintf('% g', handles.signal_extraction_para.intensity_percentile); temp = temp(2:end);
    fprintf(fileID, "intensity_percentile = [%s];\n", temp);
end
fprintf(fileID, "\n");
fprintf(fileID, "%% [Advanced] outlier_percentile: Outlier percentiles (0 to 50) of\n");
fprintf(fileID, "%% intensities.\n");
fprintf(fileID, "%%   Upper X%% and lower X%% intensities of a region will not be considered\n");
fprintf(fileID, "%%   for signal calculation.\n");
fprintf(fileID, "outlier_percentile = %g;\n", handles.signal_extraction_para.outlier_percentile);
fprintf(fileID, "\n");
fprintf(fileID, "%% organize into a struct\n");
fprintf(fileID, "signal_extraction_para = struct('cytoring_region_dist', cytoring_region_dist, ...\n");
fprintf(fileID, "    'nuc_region_dist', nuc_region_dist, 'background_dist', background_dist, ...\n");
fprintf(fileID, "    'intensity_percentile', intensity_percentile, 'outlier_percentile', outlier_percentile);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%%%% ASSEMBLE ALL PARAMETERS\n");
fprintf(fileID, "all_parameters = struct('movie_definition', movie_definition, 'inout_para', inout_para, ...\n");
fprintf(fileID, "    'segmentation_para', segmentation_para, 'prob_para', prob_para, ...\n");
fprintf(fileID, "    'track_para', track_para, 'signal_extraction_para', signal_extraction_para);\n");
fprintf(fileID, "\n");
fprintf(fileID, "end\n");

% close the file
fclose(fileID);

end

