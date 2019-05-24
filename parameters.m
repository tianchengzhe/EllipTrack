function [ all_parameters ] = parameters()
%PARAMETERS Definition of all the parameters used in the program
%
%   Input: empty
%   Output:
%       all_parameters: all the parameters, organized in a struct variable
%

%% GLOBAL_SETTING
% Parameters used by all tracker modules.

% [Essential] nuc_raw_image_path: Path to the folder containing images of
% the nuclear channel.
% [Essential] nd2_frame_range: Range of frames each ND2 file stores.
nuc_raw_image_path = {'Z:/projects/tracking_code/20181115/Raw/'};
nd2_frame_range = [1, 288];
% DO NOT CHANGE THE SCRIPTS BELOW
if (ischar(nuc_raw_image_path))
    nuc_raw_image_path = adjust_path(nuc_raw_image_path);
else
    for i=1:length(nuc_raw_image_path)
        nuc_raw_image_path{i} = adjust_path(nuc_raw_image_path{i});
    end
end
% DO NOT CHANGE THE SCRIPTS ABOVE

% [Essential] valid_wells: Movies being tracked.
valid_wells = allcomb(2:2, 3:3, 1:1);

% [Essential] cmosoffset_path: Path to the MAT file storing the camera dark
% noises (CMOS Offset).
cmosoffset_path = 'Z:/microscope_mat_files/nikon1_matfiles/cmosoffset.mat';

% [Essential] nuc_bias_path: Path to the MAT file storing the illumination
% bias (Bias) of the nuclear channel.
nuc_bias_path = 'Z:/microscope_mat_files/nikon1_matfiles/CFP.mat';

% [Essential] all_frames: Frames to track.
all_frames = 1:288;

% [Essential] nuc_signal_name: Name of the nuclear channel.
nuc_signal_name = 'CFP';

% [Essential] nuc_biomarker_name: Name of the measured nuclear marker.
nuc_biomarker_name = 'H2B';

% [Optional] if_global_correction: Indicator variable of whether to perform
% global jitter correction.
if_global_correction = 0;

% [Essential] output_path: Path to the folder storing the outputs.
output_path = 'Z:/projects/tracking_code/20181115/MCF10A/myversion/results/2_3_1/';

% Assemble into a struct variable
global_setting = struct('nuc_raw_image_path', {nuc_raw_image_path}, 'nd2_frame_range', {nd2_frame_range}, 'valid_wells', {valid_wells}, ...
    'cmosoffset_path', adjust_path(cmosoffset_path), 'nuc_bias_path', adjust_path(nuc_bias_path), 'all_frames', all_frames, ...
    'nuc_signal_name', nuc_signal_name, 'nuc_biomarker_name', nuc_biomarker_name, ...
    'if_global_correction', if_global_correction, 'output_path', adjust_path(output_path));

%% SEGMENTATION_PARA
% Parameters used by Segmentation

% Part 1. Non-Specific Parameters
% [Optional] if_active_contour: Indicator variable of whether to run Active
% Contour.
if_active_contour = 1;

% [Optional] if_watershed: Indicator variable of whether to run Watershed.
if_watershed = 1;

% [Optional] if_seg_correction: Indicator variable of whether to run
% Correction with Training Datasets.
if_seg_correction = 0;

% [Essential]: if_print_mask: Indicator variable of whether to generate the
% mask before Ellipse Fitting.
% [Essential]: mask_path: Path to the folder storing the masks.
if_print_mask = 1;
mask_path = 'Z:/projects/tracking_code/20181115/MCF10A/myversion/mask/';

% [Essential] if_print_ellipse_movie: Indicator variable of whether to
% generate 'Ellipse Movie' where fitted ellipses are overlaid on the
% nuclear images.
% [Essential] ellipse_movie_path: Path to the folder storing the 'Ellipse
% Movies'.
if_print_ellipse_movie = 1;
ellipse_movie_path = 'Z:/projects/tracking_code/20181115/MCF10A/myversion/ellipse_movie/';

% [Essential] if_save_seg_info: Indicator variable of whether to save the
% features of ellipses in each frame ('seg info').
% [Essential] seg_info_path: Path to the folder storing the 'seg info'.
if_save_seg_info = 1;
seg_info_path = 'Z:/projects/tracking_code/20181115/MCF10A/myversion/seg_info/';

% [Optional] nuc_radius: Average radius (in pixels) of a nucleus.
nuc_radius = 12;

% [Optional] max_hole_size_for_fill: Maximal area (in pixels) of a hole to
% fill in.
max_hole_size_for_fill = 200;

% [Optional] min_component_size_for_nucleus: Minimal area (in pixels) of a
% component to contain a nucleus.
min_component_size_for_nucleus = 25;

% Part 2. Image Binarization
% [Optional] blurradius: Both methods. Radius (in pixels) of disk for
% smoothing.
blurradius = 3; 

% [Essential] if_log: Both methods. Indicator variable of whether to
% log-transform the images.
if_log = 1;

% [Essential] if_blob_detection: Both methods. Indicator variable of
% whether to run Blob Detection.
if_blob_detection = 0;

% [Important] blob_threshold: Blob Detection only. Threshold of Hessian.
blob_threshold = -0.1;

% Assemble into a struct variable 
image_binarization_para = struct('blurradius', blurradius, 'if_log', if_log, ...
    'if_blob_detection', if_blob_detection, 'blob_threshold', blob_threshold);

% Part 3. Active Contour
% [Optional] blurradius: Radius (in pixels) of disk for smoothing.
blurradius = 2;

% [Essential] if_log: Indicator variable of whether to log-transform the
% images.
if_log = 1;

% [Essential] if_global: Indicator variable of whether to run the Global
% method.
if_global = 0;

% Assemble into a struct variable
active_contour_para = struct('blurradius', blurradius, 'if_log', if_log, 'if_global', if_global);

% Part 4. Watershed
% [Optional] max_thresh_component_size: Maximal area (in pixels) of a peak.
% [Optional] min_thresh_component_size: Minimal area (in pixels) of a peak.
max_thresh_component_size = 25;
min_thresh_component_size = 0;

% Assemble into a struct variable
watershed_para = struct('max_thresh_component_size', max_thresh_component_size, ...
    'min_thresh_component_size', min_thresh_component_size);

% Part 5. Ellipse Fitting
% [Optional] k, thd1, thd2, thdn, C, T_angle, sig, Endpoint, Gap_size:
% Parameters in Zafari et al 2015. Refer to the original publication for
% more information.
k = 5; 
thd1 = 10; 
thd2 = 25;
thdn = 30; 
C = 1.5; 
T_angle = 162;
sig = 3; 
Endpoint = 1;
Gap_size = 1; 

% [Optional] min_ellipse_perimeter: Minimal perimeter (in pixels) of an
% ellipse.
min_ellipse_perimeter = 5; 

% [Optional] min_ellipse_area: Minimal area (in pixels) of an ellipse.
min_ellipse_area = 5; 

% [Optional] max_major_axis: Maximal major axis (in pixels) of an ellipse.
max_major_axis = 100;

% Assemble into a struct variable
ellipse_para = struct('k', k, 'thd1', thd1, 'thd2', thd2, 'thdn', thdn, 'C', C, 'T_angle', T_angle, ...
    'sig', sig, 'Endpoint', Endpoint, 'Gap_size', Gap_size, 'min_ellipse_perimeter', min_ellipse_perimeter, ...
    'min_ellipse_area', min_ellipse_area, 'max_major_axis', max_major_axis);

% Part 6. Correction of Segmentation Mistakes
% [Essential] training_data_path: Paths to the training datasets.
training_data_path = {'Z:/projects/tracking_code/20181115/MCF10A/myversion/mat_files/2_1_1_CFP_training_data_21_100.mat';
    'Z:/projects/tracking_code/20181115/MCF10A/myversion/mat_files/2_1_1_CFP_training_data_126_175.mat';
    'Z:/projects/tracking_code/20181115/MCF10A/myversion/mat_files/2_1_1_CFP_training_data_201_250.mat'};
% DO NOT CHANGE THE SCRIPTS BELOW
for i=1:length(training_data_path)
    training_data_path{i} = adjust_path(training_data_path{i});
end
% DO NOT CHANGE THE SCRIPTS ABOVE

% [Optional] min_ellipse_area_twocells: Minimal area (in pixels) of an
% ellipse for splitting.
min_ellipse_area_twocells = 20;

% [Optional] max_fraction_mismatch: Maximal fraction (between 0 and 1) of
% mismatch between two k-means runs.
max_fraction_mismatch = 0.1;

% [Optional] min_no_cell_prob: Minimal probability (between 0 and 1) of
% containing no nucleus for removal.
min_no_cell_prob = 0.9;

% [Optional] min_two_cells_prob: Minimal probability (between 0 and 1) of
% containing two nuclei for splitting.
min_two_cells_prob = 0.9;

% Assemble into a struct variable
seg_correction_para = struct('training_data_path', {training_data_path}, 'min_ellipse_area_twocells', min_ellipse_area_twocells, ...
    'max_fraction_mismatch', max_fraction_mismatch, 'min_no_cell_prob', min_no_cell_prob, 'min_two_cells_prob', min_two_cells_prob);

% Assemble everything
segmentation_para = struct('if_active_contour', if_active_contour, ...
    'if_watershed', if_watershed, 'if_seg_correction', if_seg_correction, ...
    'if_print_mask', if_print_mask, 'mask_path', adjust_path(mask_path), ...
    'if_print_ellipse_movie', if_print_ellipse_movie, 'ellipse_movie_path', adjust_path(ellipse_movie_path), ...
    'if_save_seg_info', if_save_seg_info, 'seg_info_path', adjust_path(seg_info_path), ...
    'nuc_radius', nuc_radius, 'max_hole_size_for_fill', max_hole_size_for_fill, ...
    'min_component_size_for_nucleus', min_component_size_for_nucleus, ...
    'image_binarization_para', image_binarization_para, 'active_contour_para', active_contour_para, ...
    'watershed_para', watershed_para, 'ellipse_para', ellipse_para, ...
    'seg_correction_para', seg_correction_para);

%% TRACK_PARA
% Parameters used for track linking

% Part 1. Predict Probabilities
% [Essential] training_data_path: Paths to the training datasets.
training_data_path = {'Z:/projects/tracking_code/20181115/MCF10A/myversion/mat_files/2_1_1_CFP_training_data_21_100.mat';
    'Z:/projects/tracking_code/20181115/MCF10A/myversion/mat_files/2_1_1_CFP_training_data_126_175.mat';
    'Z:/projects/tracking_code/20181115/MCF10A/myversion/mat_files/2_1_1_CFP_training_data_201_250.mat'};
% DO NOT CHANGE THE SCRIPTS BELOW
for i=1:length(training_data_path)
    training_data_path{i} = adjust_path(training_data_path{i});
end
% DO NOT CHANGE THE SCRIPTS ABOVE

% [Optional] empty_prob: Probability of an event (between 0 and 1) if no
% training samples are provided.
empty_prob = 0.0001;

% [Important] if_switch_off_before_mitosis: Indicator variable of whether
% to ignore the probability of being an mitotic cell (Before M) during
% mitosis detection.
% [Optional] if_switch_off_after_mitosis: Indicator variable of whether to
% ignore the probability of being a newly born cell (After M) during
% mitosis detection.
if_switch_off_before_mitosis = 1;
if_switch_off_after_mitosis = 0;

% [Optional] if_similarity_for_migration: Indicator variable of whether to
% consider ellipse similarity when computing migration probabilities.
if_similarity_for_migration = 1;

% [Important] migration_sigma: Standard deviation (in pixels) of random
% walk in one frame and one direction. If NaN is chosen, the value will be
% inferred from the training datasets.
migration_sigma = 4;

% [Optional] max_migration_distance_fold: Maximal distances (expressed as
% folds of migration_sigma) an ellipse can travel in one frame and one
% direction.
max_migration_distance_fold = 20;

% [Optional] likelihood_nonmigration: Null probability (between 0 and 1)
% for migration.
likelihood_nonmigration = 0.001;

% [Optional] min_inout_prob: Minimal probability (between 0 and 1) of
% migrating in/out of the field of view.
min_inout_prob = 0.0001;

% [Optional] max_gap: Maximal gap (in frames) of migration. Gap = number of
% frames to skip + 1.
max_gap = 1;

% Part 2. Construct Cell Tracks
% [Optional] skip_penalty: Penalty score for skipping one frame.
skip_penalty = 10;

% [Optional] multiple_cells_penalty: Penalty score for two cells
% co-existing in one ellipse.
multiple_cells_penalty = 5;

% [Optional] min_mitosis_prob: Minimal probability (between 0 and 1) of
% mitotic and newly born cells for mitosis detection.
min_mitosis_prob = 0;

% [Optional] max_num_tracks: Maximal number of tracks to construct.
max_num_tracks = Inf;

% [Optional] min_track_score: Minimal score of a track.
min_track_score = 2;

% [Optional] min_track_score_per_step: Minimal score of a track between two
% neighboring frames.
min_track_score_per_step = -15;

% [Optional] max_recorded_link: For each ellipse, maximal number of
% migration events to keep.
max_recorded_link = 5;

% Part 3. Post-Processing
% [Optional] min_swap_score: Minimal score for swapping cell tracks.
min_swap_score = 2;

% [Optional] fixation_min_prob_before_mitosis: Minimal probability of
% mitotic cells (Before M) for mitosis detection.
% [Optional] fixation_min_prob_after_mitosis: Minimal probability of newly
% born cells (After M) for mitosis detection.
fixation_min_prob_before_mitosis = 0.5;
fixation_min_prob_after_mitosis = 0.5;

% [Optional] min_track_length: Minimal length (in frames) of a valid track.
min_track_length = 10;

% [Optional] max_num_frames_to_skip: Maximal number of frames a valid track
% can skip.
max_num_frames_to_skip = 2;

% Part 4. Visualization
% [Essential] if_print_vistrack: Indicator variable of whether to generate
% 'Vistrack Movies' where fitted ellipses are overlaid on the nuclear
% images and Cell Track IDs are displayed next to the ellipses they mapped
% to.
% [Essential] vistrack_path: Path to the folder storing 'Vistrack Movies'.
if_print_vistrack = 1;
vistrack_path = 'Z:/projects/tracking_code/20181115/MCF10A/myversion/vistrack/';

% Assemble into a struct variable
track_para = struct('training_data_path', {training_data_path}, 'empty_prob', empty_prob, ...
    'if_switch_off_before_mitosis', if_switch_off_before_mitosis, ...
    'if_switch_off_after_mitosis', if_switch_off_after_mitosis, ...
    'if_similarity_for_migration', if_similarity_for_migration, ...
    'migration_sigma', migration_sigma, 'max_migration_distance_fold', max_migration_distance_fold, ...
    'likelihood_nonmigration', likelihood_nonmigration, 'min_inout_prob', min_inout_prob, ...
    'max_gap', max_gap, 'skip_penalty', skip_penalty, 'multiple_cells_penalty', multiple_cells_penalty, ...
    'min_mitosis_prob', min_mitosis_prob, 'max_num_tracks', max_num_tracks, 'min_track_score', min_track_score, ...
    'min_track_score_per_step', min_track_score_per_step, 'max_recorded_link', max_recorded_link, ...
    'min_swap_score', min_swap_score, 'fixation_min_prob_before_mitosis', fixation_min_prob_before_mitosis, ...
    'fixation_min_prob_after_mitosis', fixation_min_prob_after_mitosis, ...
    'min_track_length', min_track_length, 'max_num_frames_to_skip', max_num_frames_to_skip, ...
    'if_print_vistrack', if_print_vistrack, 'vistrack_path', adjust_path(vistrack_path));

%% SIGNAL_EXTRACTION_PARA
% A struct containing all the information of the additional markers. In
% other words, this will NOT include the nuclear marker (H2B) which is used
% to perform tracking

% Part 1. Signal Channels
% [Essential] additional_signal_names: Names of the signal channels.
additional_signal_names = {'mCherry'};

% [Essential] additional_biomarker_names: Names of the measured markers in
% the signal channels.
additional_biomarker_names = {'CDK2'};

% [Essential] additional_raw_image_paths: Paths to the folder containing
% images of the signal channels.
additional_raw_image_paths = {{'Z:/projects/tracking_code/20181115/Raw/'}};
% USE THE FOLLOWING SCRIPTS IF USING ND2 FILES OR ALL TIFF FILES ARE STORED IN THE SAME FOLDER
% additional_raw_image_paths = cell(length(additional_signal_names), 1);
% additional_raw_image_paths(:) = {global_setting.nuc_raw_image_path};
% USE THE ABOVE SCRIPTS IF USING ND2 FILES OR ALL TIFF FILES ARE STORED IN THE SAME FOLDER
% DO NOT CHANGE THE SCRIPTS BELOW
for i=1:length(additional_raw_image_paths)
    if (ischar(additional_raw_image_paths{i}))
        additional_raw_image_paths{i} = adjust_path(additional_raw_image_paths{i});
    else
        for j=1:length(additional_raw_image_paths{i})
            additional_raw_image_paths{i}{j} = adjust_path(additional_raw_image_paths{i}{j});
        end
    end
end
% DO NOT CHANGE THE SCRIPTS ABOVE

% [Essential] additional_bias_paths: Paths to the MAT files storing the
% illumination bias of the signal channels.
additional_bias_paths = {'Z:/microscope_mat_files/nikon1_matfiles/mCherry.mat'};
% DO NOT CHANGE THE SCRIPTS BELOW
for i=1:length(additional_bias_paths)
    additional_bias_paths{i} = adjust_path(additional_bias_paths{i});
end
% DO NOT CHANGE THE SCRIPTS ABOVE
% [Essential] if_compute_cyto_ring: Indicator variables of whether to
% extract the signals in the cytoplasmic ring.
if_compute_cyto_ring = [1];

% Part 2. ROI
% [Optional] cyto_ring_inner_size: Minimal distance (in pixels) between the
% region of cytoplasmic ring and the ellipse contour.
% [Optional] cyto_ring_outer_size: Maximal distance (in pixels) between the
% region of cytoplasmic ring and the ellipse contour.
% [Optional] nuc_outer_size: Minimal distance (in pixels) between the
% region of nucleus and the ellipse contour.
cyto_ring_inner_size = 1;
cyto_ring_outer_size = 4;
nuc_outer_size = 1;

% [Optional] foreground_dilation_size: Minimal distance (in pixels) between
% the image background and a nucleus.
foreground_dilation_size = 20;

% [Optional] intensity_percentile: Measured percentile (between 0 and 100)
% of each region.
intensity_percentile = 75;

% [Optional] lower_percentile: Lower percentile (between 0 and 100) of
% intensities to keep.
% [Optional] higher_percentile: Higher percentile (between 0 and 100,
% greater than lower_percentile) to keep.
lower_percentile = 5;
higher_percentile = 95;

% Save all parameters into a struct
signal_extraction_para = struct('additional_signal_names', {additional_signal_names}, ...
    'additional_biomarker_names', {additional_biomarker_names}, ...
    'additional_raw_image_paths', {additional_raw_image_paths}, ...
    'additional_bias_paths', {additional_bias_paths}, ...
    'if_compute_cyto_ring', if_compute_cyto_ring, ...
    'cyto_ring_inner_size', cyto_ring_inner_size, 'cyto_ring_outer_size', cyto_ring_outer_size, ...
    'nuc_outer_size', nuc_outer_size, ...
    'foreground_dilation_size', foreground_dilation_size, 'intensity_percentile', intensity_percentile, ...
    'lower_percentile', lower_percentile, 'higher_percentile', higher_percentile);

%% ASSEMBLE ALL PARAMETERS
all_parameters = struct('global_setting', global_setting, 'segmentation_para', ...
    segmentation_para, 'track_para', track_para, 'signal_extraction_para', signal_extraction_para);

end

function [ new_path ] = adjust_path ( old_path )
%ADJUST_PATH Adjust the path of files such that the code can be used in
%both windows and mac platforms

new_path = old_path;
if (~isempty(old_path) && old_path(end) ~= '/' && ~strcmp(old_path(max(end-3,1):end), '.mat'))
    new_path = cat(2, new_path, '/');
end
new_path = strrep(new_path, '\', '/');

end
