function [ all_parameters ] = default_para()
%PARAMETERS Default parameter values
%
%   Input: empty
%   Output:
%       all_parameters: Default parameter values, organized in struct.
%

% MOVIE DEFINITION
image_type = 'seq';
image_path = {};
filename_format = '';
channel_names = {};
signal_names = {};
if_compute_cytoring = [];
bias_paths = {};
cmosoffset_path = '';
wells_to_track = [];
frames_to_track = [];
jitter_correction_method = 'none';
num_cores = 1;

movie_definition = struct('image_type', image_type, ...
    'image_path', {adjust_path(image_path)}, 'filename_format', filename_format, ...
    'channel_names', {channel_names}, 'signal_names', {signal_names}, ...
    'if_compute_cytoring', if_compute_cytoring, 'bias_paths', {adjust_path(bias_paths)}, ...
    'cmosoffset_path', adjust_path(cmosoffset_path), 'wells_to_track', wells_to_track, ...
    'frames_to_track', frames_to_track, 'jitter_correction_method', jitter_correction_method, ...
    'num_cores', num_cores);

% INPUT/OUTPUT
training_data_path = {};
output_path = '';
mask_path = '';
ellipse_movie_path = '';
seg_info_path = '';
vistrack_path = '';

inout_para = struct('training_data_path', {adjust_path(training_data_path)}, ...
    'output_path', adjust_path(output_path), ...
    'mask_path', adjust_path(mask_path), 'ellipse_movie_path', adjust_path(ellipse_movie_path), ...
    'seg_info_path', adjust_path(seg_info_path), 'vistrack_path', adjust_path(vistrack_path));

% SEGMENTATION
% Part 1. Non-Specific Parameters
nuc_radius = 12;
allowed_nuc_size = [25, Inf];
allowed_ellipse_size = [5, Inf];
max_ellipse_aspect_ratio = 7.5;
max_hole_size_to_fill = 200;
blur_radius = 3; 

nonspecific_para = struct('nuc_radius', nuc_radius, 'allowed_nuc_size', allowed_nuc_size, ...
    'allowed_ellipse_size', allowed_ellipse_size, 'max_ellipse_aspect_ratio', max_ellipse_aspect_ratio, ...
    'max_hole_size_to_fill', max_hole_size_to_fill, 'blur_radius', blur_radius);

% Part 2. Image Binarization
if_log = 1;
background_subtraction_method = 'none';
binarization_method = 'threshold';
blob_threshold = -0.1;

image_binarization_para = struct('background_subtraction_method', background_subtraction_method, ...
    'if_log', if_log, 'binarization_method', binarization_method, 'blob_threshold', blob_threshold);

% Part 3. Active Contour
if_run = 1;
if_log = 1;
active_contour_method = 'local';

active_contour_para = struct('if_run', if_run, 'if_log', if_log, ...
    'active_contour_method', active_contour_method);

% Part 4. Watershed
if_run = 1;

watershed_para = struct('if_run', if_run);

% Part 5. Ellipse Fitting
k = 5; 
thd1 = 10; 
thd2 = 25;
thdn = 30; 
C = 1.5; 
T_angle = 162;
sig = 3; 
Endpoint = 1;
Gap_size = 1; 

ellipse_para = struct('k', k, 'thd1', thd1, 'thd2', thd2, 'thdn', thdn, 'C', C, 'T_angle', T_angle, ...
    'sig', sig, 'Endpoint', Endpoint, 'Gap_size', Gap_size);

% Part 6. Correction of Segmentation Mistakes
if_run = 0;
min_corr_prob = 0.9;

seg_correction_para = struct('if_run', if_run, 'min_corr_prob', min_corr_prob);

segmentation_para = struct('nonspecific_para', nonspecific_para, ...
    'image_binarization_para', image_binarization_para, ...
    'active_contour_para', active_contour_para, 'watershed_para', watershed_para, ...
    'ellipse_para', ellipse_para, 'seg_correction_para', seg_correction_para);

% PREDICTION OF EVENTS
empty_prob = 0.0001;
mitosis_inference_option = 'after';
migration_option = 'similarity';
migration_speed = 'global';
max_migration_dist_fold = 20;
migration_inference_resolution = 10;
migration_inference_min_samples = 50;
prob_nonmigration = 0.001;
min_inout_prob = 0.0001;
max_migration_time = 1;

prob_para = struct('empty_prob', empty_prob, 'mitosis_inference_option', mitosis_inference_option, ...
    'migration_option', migration_option, 'migration_speed', migration_speed, ...
    'max_migration_dist_fold', max_migration_dist_fold, 'migration_inference_resolution', migration_inference_resolution, ...
    'migration_inference_min_samples', migration_inference_min_samples, 'prob_nonmigration', prob_nonmigration, ...
    'min_inout_prob', min_inout_prob, 'max_migration_time', max_migration_time);

% TRACK LINKING
skip_penalty = 10;
multiple_cells_penalty = 5;
min_track_score = 2;
min_track_score_per_step = -2;
min_swap_score = 2;
mitosis_detection_min_prob = 0.5;
critical_length = 10;
min_track_length = 10;
max_num_frames_to_skip = 2;

track_para = struct('skip_penalty', skip_penalty, 'multiple_cells_penalty', multiple_cells_penalty, ...
    'min_track_score', min_track_score, 'min_track_score_per_step', min_track_score_per_step, ...
    'min_swap_score', min_swap_score, 'mitosis_detection_min_prob', mitosis_detection_min_prob, ...
    'critical_length', critical_length, 'min_track_length', min_track_length, ...
    'max_num_frames_to_skip', max_num_frames_to_skip);

% SIGNAL EXTRACTION
cytoring_region_dist = [1, 4];
nuc_region_dist = 1;
background_dist = 20;
intensity_percentile = 75;
outlier_percentile = 5;

signal_extraction_para = struct('cytoring_region_dist', cytoring_region_dist, ...
    'nuc_region_dist', nuc_region_dist, 'background_dist', background_dist, ...
    'intensity_percentile', intensity_percentile, 'outlier_percentile', outlier_percentile);

all_parameters = struct('movie_definition', movie_definition, 'inout_para', inout_para, ...
    'segmentation_para', segmentation_para, 'prob_para', prob_para, ...
    'track_para', track_para, 'signal_extraction_para', signal_extraction_para);

end


