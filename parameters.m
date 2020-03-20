function [ all_parameters ] = parameters()
%PARAMETERS Parameters of EllipTrack
%
%   Input: empty
%   Output:
%       all_parameters: Parameters organized in structs
%

%% MOVIE DEFINITION
% Parameters defining the movies.

% image_type: Movie format. 3 options:
%   'seq': Movies are stored as image sequences. Each image contains one
%   channel at one frame.
%   'stack': Movies are stored as image stacks. Each stack contains one
%   channel at all frames.
%   'nd2': Movies are stored in the Nikon ND2 format. Movies can be stored
%   in multiple segments (files). Each segment contains images of all
%   channels.
image_type = 'seq';

% image_path: Paths to the folders storing the images.
%   Image Sequences/Stacks: nx1 cell array. Each row stores the path to 
%   the folder with the images of the i-th channel.
%   nd2: nx1 cell array. Each row stores the path to the folder with the
%   i-th segment.
image_path = {};

% filename_format: Formats of image filenames. 
%   Image Sequences/Stacks: Full filenames are required.
%   nd2: First few characters of filenames are sufficient.
%   Available format operators:
%   %r: Row ID (numeric)
%   %a: Row ID (letter, lower case)
%   %b: Row ID (letter, upper case)
%   %c: Column ID (numeric)
%   %s: Site ID (numeric, not for ND2 format)
%   %i: Channel ID (numeric, not for ND2 format)
%   %n: Channel Name (string, not for ND2 format)
%   %t: Frame ID (numeric, Image Sequence only)
%   Prefix zeros: %0Nr (N digits)
filename_format = '';

% channel_names: Names of the fluorescent channels.
%   nx1 cell array. Each row stores the name of the i-th channel.
channel_names = {};

% signal_names: Names of the signals to measure.
%   nx1 cell array. Each row stores the name of the i-th signal. Must match
%   the order of channel_names.
signal_names = {};

% if_compute_cytoring: Whether to compute signals in the cytoplasmic ring.
%   nx1 array. Each row is either 1 (compute) or 0 (not compute). Must
%   match the order of channel_names.
if_compute_cytoring = [];

% bias_paths: Paths to the MAT files storing the illumination biases.
%   nx1 cell array. Each row stores the path to the bias of the i-th
%   channel. Must match the order of channel_names.
bias_paths = {};

% cmosoffset_path: Path to the MAT file storing the camera dark noises.
cmosoffset_path = '';

% wells_to_track: Movie coordinates in a multi-well plate.
%   nx3 array. Each row stores the Row, Column, and Site ID of one movie.
%   If not performed in a multi-well plate, enter [1, 1, 1].
wells_to_track = [];

% frames_to_track: Frame IDs.
frames_to_track = [];

% jitter_correction_method: Method of jitter correction. 3 options:
%   'none': No jitter correction will be performed. Suggested if jitters
%   are negligible.
%   'local': Local method. Jitter correction will be performed on each
%   movie, independent from other movies. Suggested if movies have big
%   jitters.
%   'global': Global method. First perform the Local method. Jitters will
%   then be corrected by the locations of wells on the multi-well plate.
%   Suggested for improving the accuracy of jitter inference. Require at
%   least 6 wells.
jitter_correction_method = 'none';

% num_cores: Number of logical cores for parallel computing.
num_cores = 1;

% organize into a struct
movie_definition = struct('image_type', image_type, ...
    'image_path', {adjust_path(image_path)}, 'filename_format', filename_format, ...
    'channel_names', {channel_names}, 'signal_names', {signal_names}, ...
    'if_compute_cytoring', if_compute_cytoring, 'bias_paths', {adjust_path(bias_paths)}, ...
    'cmosoffset_path', adjust_path(cmosoffset_path), 'wells_to_track', wells_to_track, ...
    'frames_to_track', frames_to_track, 'jitter_correction_method', jitter_correction_method, ...
    'num_cores', num_cores);

%% INPUT/OUTPUT
% Parameters defining the input and output files.

% training_data_path: Paths to the training datasets.
%   nx1 cell array. Each row stores the path to one training dataset.
%   Use empty cell array ({}) if no training datasets are available.
training_data_path = {};

% output_path: Path to the folder storing the output MAT files.
output_path = '';

% mask_path: Path to the folder storing the mask.
%   A mask is the binarized nuclear image before Ellipse Fitting.
%   Use empty character ('') if not generating this output.
%   Suggested for evaluating the accuracy of segmentation.
mask_path = '';

% ellipse_movie_path: Path to the folder storing the 'ellipse movies'.
%   An 'ellipse movie' is the autoscaled nuclear image overlaid by fitted
%   ellipses.
%   Use empty character ('') if not generating this output.
%   Suggested for evaluating the accuracy of segmentation.
ellipse_movie_path = '';

% seg_info_path: Path to the folder storing the 'seg info'.
%   A 'seg info' is the ellipse information of one frame. 
%   Use empty character ('') if not generating this output.
%   Suggested if training datasets will be constructed from this movie.
seg_info_path = '';

% vistrack_path: Path to the folder storing the 'vistrack movie'.
%   A 'vistrack movie' is the autoscaled nuclear image overlaid by fitted
%   ellipses and cell track IDs.
%   Use empty character ('') if not generating this output.
%   Suggested for evaluating the accuracy of tracking.
vistrack_path = '';

% organize into a struct
inout_para = struct('training_data_path', {adjust_path(training_data_path)}, ...
    'output_path', adjust_path(output_path), ...
    'mask_path', adjust_path(mask_path), 'ellipse_movie_path', adjust_path(ellipse_movie_path), ...
    'seg_info_path', adjust_path(seg_info_path), 'vistrack_path', adjust_path(vistrack_path));

%% SEGMENTATION
% Parameters controlling Segmentation

% Part 1. Non-Specific Parameters
% Parameters used by all Segmentation Steps.

% nuc_radius: Average radius (in pixels) of a nucleus.
nuc_radius = 12;

% allowed_nuc_size: Acceptable areas (in pixels) of a nucleus.
%   1x2 array storing the lower and upper limits.
%   Mask components not within the range will be removed.
allowed_nuc_size = [25, Inf];

% allowed_ellipse_size: Acceptable areas (in pixels) of an ellipse.
%   1x2 array storing the lower and upper limits.
%   Ellipses not within the range will be removed.
allowed_ellipse_size = [5, Inf];

% [Advanced] max_ellipse_aspect_ratio: Maximal aspect ratio (>1) of an
% ellipse.
%   Ellipses with greater aspect ratios will be removed.
max_ellipse_aspect_ratio = 7.5;

% [Advanced] max_hole_size_to_fill: Maximal hole area (in pixels) to fill.
%   A hole is defined as a set of background pixels surrounded by
%   foreground pixels in a mask.
%   Holes with smaller areas will be converted to foreground pixels.
%   Helpful if a nucleus contains some dark regions.
max_hole_size_to_fill = 200;

% [Advanced] blur_radius: Radius (in pixels) of the disk for image
% smoothing.
blur_radius = 3;

% organize into a struct
nonspecific_para = struct('nuc_radius', nuc_radius, 'allowed_nuc_size', allowed_nuc_size, ...
    'allowed_ellipse_size', allowed_ellipse_size, 'max_ellipse_aspect_ratio', max_ellipse_aspect_ratio, ...
    'max_hole_size_to_fill', max_hole_size_to_fill, 'blur_radius', blur_radius);

% Part 2. Image Binarization
% Parameters controlling Image Binarization

% if_log: Whether to log-transform the images. Binary variable:
%   1: log-transform. Suggested if nuclei have heterogeneous brightness.
%   0: not log-transform. Suggested if nuclei have homogeneous brightness.
if_log = 1;

% background_subtraction_method: Method of Background Subtraction. 4 options:
%   'none': No background subtraction will be performed. Suggested if the
%   images have low backgrounds.
%   'min', 'median', and 'mean': Images will be subtracted by the minimal,
%   median, and mean intensity of the background. Suggested if the images
%   have high backgrounds.
background_subtraction_method = 'none';

% binarization_method. Method of Image Binarization. 2 options: 
%   'threshold': Thresholding. A threshold is applied to the image
%   intensities. Suggested if nuclei have homogeneous brightness. 
%   'blob': Blob Detection. A threshold is applied to the hessian of image
%   intensities. Suggested if nuclei have heterogeneous brightness.
binarization_method = 'threshold';

% blob_threshold. Blob Detection only. Threshold of the hessian.
blob_threshold = -0.1;

% organize into a struct 
image_binarization_para = struct('background_subtraction_method', background_subtraction_method, ...
    'if_log', if_log, 'binarization_method', binarization_method, 'blob_threshold', blob_threshold);

% Part 3. Active Contour
% Parameters controlling Active Contour

% if_run: Whether to run Active Contour. Binary variable:
%   1: run. Suggested if Image Binarization does not detect accurate
%   nuclear boundary.
%   0: not run. Suggested if Image Binarization results are satisfactory.
if_run = 1;

% if_log: Whether to log-transform the images. Binary variable:
%   1: log-transform. Suggested if nuclei have heterogeneous brightness.
%   0: not log-transform. Suggested if nuclei have homogeneous brightness.
if_log = 1;

% active_contour_method: Method of active contour. 2 options:
%   'local': Local method. Active contour is applied to the neighborhood of
%   every nucleus. Suggested if nuclei have heterogeneous brightness.
%   'global': Global method. Active contour is applied to the entire image
%   at once. Suggested if nuclei have homogeneous brightness.
active_contour_method = 'local';

% organize into a struct 
active_contour_para = struct('if_run', if_run, 'if_log', if_log, ...
    'active_contour_method', active_contour_method);

% Part 4. Watershed
% Parameters controlling Watershed

% if_run: Whether to run Watershed. Binary variable:
%   1: run. Suggested if nuclei overlap frequently.
%   0: not run. Suggested if nuclei do not frequently overlap.
if_run = 1;

% organize into a struct
watershed_para = struct('if_run', if_run);

% Part 5. Ellipse Fitting
% Parameters controlling Ellipse Fitting
% Defined in Zafari et al 2015. Descriptions are adapted from the source
% code.

% [Advanced] k: Consider up to k-th adjacent points to the corner point.
k = 5;

% [Advanced] thd1: Distance (in pixels) between the ellipse centroid of the
% combined contour segments and the ellipse fitted to each segment.
thd1 = 10;

% [Advanced] thd2: Distance (in pixels) between the centroids of ellipse
% fitted to each segment.
thd2 = 25;

% [Advanced] thdn: Distance (in pixels) between contour center points.
thdn = 30;

% [Advanced] C: Minimal aspect ratio for corner detection.
C = 1.5;

% [Advanced] T_angle: Maximal angle (in degrees) of a corner.
T_angle = 162;

% [Advanced] sig: Standard deviation (in pixels) of the Gaussian filter.
sig = 3;

% [Advanced] Endpoint: Whether to add the end points of a curve as corner.
%   Binary variable. 1: add; 0: not add.
Endpoint = 1;

% [Advanced] Gap_size: Maximal length of gaps (in pixels) in the contours
% to fill.
Gap_size = 1;

% organize into a struct
ellipse_para = struct('k', k, 'thd1', thd1, 'thd2', thd2, 'thdn', thdn, 'C', C, 'T_angle', T_angle, ...
    'sig', sig, 'Endpoint', Endpoint, 'Gap_size', Gap_size);

% Part 6. Correction with Training Data
% Parameters controlling Correction with Training Data

% if_run: Whether to run Correction with Training Data. Binary variable:
%   1: run. Suggested if training datasets are available and well-predict
%   the number of nuclei in each ellipse.
%   0: not run. Suggested if training datasets are not available or not
%   suitable.
if_run = 0;

% [Advanced] min_corr_prob: Minimal probability (0 to 1) for correction.
min_corr_prob = 0.9;

% organize into a struct
seg_correction_para = struct('if_run', if_run, 'min_corr_prob', min_corr_prob);

% assemble everything into a struct
segmentation_para = struct('nonspecific_para', nonspecific_para, ...
    'image_binarization_para', image_binarization_para, ...
    'active_contour_para', active_contour_para, 'watershed_para', watershed_para, ...
    'ellipse_para', ellipse_para, 'seg_correction_para', seg_correction_para);

%% PREDICTING OF EVENTS
% Parameters controlling Prediction of Events

% [Advanced] empty_prob: Probability of an event (0 to 1) if no training
% data is provided.
empty_prob = 0.0001;

% mitosis_inference_option: Method of mitosis inference. 4 options:
%   'all' or 'both': Mother cells need to have high probabilities of being
%   mitotic, and daughter cells need to have high probabilities of being
%   newly born.
%   'before': Mother cells need to have high probabilities of being
%   mitotic. No requirement on daughter cells.
%   'after': Daughter cells need to have high probabilities of being newly
%   born. No requirement on mother cells.
%   'none': No requirement on either mother or daughter cells.
%   In principle 'all' should be used, though flexibility is provided in
%   case probabilities of some events do not reflect reality.
mitosis_inference_option = 'after';

% migration_option: Method of migration probability calculation. 2 options:
%   'similarity': Consider both the migration distance and the probability
%   that the two ellipses belong to the same cell.
%   'distance': Consider only the migration distance.
%   In principle 'similarity' should be used, though flexibility is
%   provided in case ellipse similarity is not well-calculated.
migration_option = 'similarity';

% migration_speed: Migration speed. 
%   Defined as the standard deviation of random walk in one direction and
%   one frame. 4 options:
%   'global': All cells have the same migration speed. Suggested if cells
%   migrate independently of other cells and factors.
%   'time': Migration speed is dependent on time. Suggested if cell
%   migration mode changes, such as due to drug addition.
%   'density': Migration speed is dependent on local cell density.
%   Suggested if cell migration is limited by the available space or
%   controlled by cell-cell communication.
%   custom: A numeric number specifying the migration speed of all cells.
%   Suggested if training datasets are unavailable or the other options do
%   not produce satisfactory results.
%   The first three options require training datasets.
migration_speed = 'global';

% [Advanced] max_migration_dist_fold: Maximal distance (in folds of the
% migration speed) a cell can migrate in a frame.
max_migration_dist_fold = 20;

% [Advanced] migration_inference_resolution: 'time' and 'density' only.
% Resolution of time (in frames) or cell density (in number of cells) for
% inference.
migration_inference_resolution = 10;

% [Advanced] migration_inference_min_samples: 'time' and 'density' only.
% Minimal number of samples for inference.
migration_inference_min_samples = 50;

% [Advanced] prob_nonmigration: Null probability (0 to 1) of migration.
prob_nonmigration = 0.001;

% [Advanced] min_inout_prob: Minimal probability (0 to 1) to migrate in/out
% of the field of view.
min_inout_prob = 0.0001;

% [Advanced] max_migration_time: Maximal number of frames in a migration
% event. 
%   max_migration_time-1 equals to the maximal number of frames a track can
%   skip.
%   Warning: Local track correction is not optimized for tracks skipping
%   any frames. Error rate might be high.
max_migration_time = 1;

% organize into a struct
prob_para = struct('empty_prob', empty_prob, 'mitosis_inference_option', mitosis_inference_option, ...
    'migration_option', migration_option, 'migration_speed', migration_speed, ...
    'max_migration_dist_fold', max_migration_dist_fold, 'migration_inference_resolution', migration_inference_resolution, ...
    'migration_inference_min_samples', migration_inference_min_samples, 'prob_nonmigration', prob_nonmigration, ...
    'min_inout_prob', min_inout_prob, 'max_migration_time', max_migration_time);

%% TRACK LINKING
% Parameters controlling Track Linking

% Penalty score
% [Advanced] skip_penalty: Penalty score for skipping one frame.
skip_penalty = 10;

% [Advanced] multiple_cells_penalty: Penalty score for two tracks
% co-existing in one ellipse.
multiple_cells_penalty = 5;

% Minimal score
% [Advanced] min_track_score: Minimal score of a track.
%   Cell tracks with lower scores will not be considered.
min_track_score = 2;

% [Advanced] min_track_score_per_step: Minimal score of a track between two
% neighboring frames.
%   Cell tracks with lower scores will not be considered.
min_track_score_per_step = -2;

% Local Track Correction (Post-Processing)
% [Advanced] min_swap_score: Minimal score to gain if two tracks are
% swapped.
%   Swaps with lower score gains will not be implemented.
min_swap_score = 2;

% [Advanced] mitosis_detection_min_prob: Minimal probability (0 to 1) for
% mitosis detection.
%   Mitosis will not be detected if either mother or daughter cells have
%   probabilities lower than this value.
mitosis_detection_min_prob = 0.5;

% [Advanced] critical_length: Critical length (in frames) of track absence
% due to undersegmentation.
%   Suggested to be 10-20% of a typical cell cycle duration.
critical_length = 10;

% min_track_length: Minimal length (in frames) of a valid track.
%   Tracks shorter than this value will be removed.
min_track_length = 10;

% max_num_frames_to_skip: Maximal number of frames a valid track can skip.
%   Tracks skipping more than this value will be removed.
max_num_frames_to_skip = 2;

% organize into a struct
track_para = struct('skip_penalty', skip_penalty, 'multiple_cells_penalty', multiple_cells_penalty, ...
    'min_track_score', min_track_score, 'min_track_score_per_step', min_track_score_per_step, ...
    'min_swap_score', min_swap_score, 'mitosis_detection_min_prob', mitosis_detection_min_prob, ...
    'critical_length', critical_length, 'min_track_length', min_track_length, ...
    'max_num_frames_to_skip', max_num_frames_to_skip);

%% SIGNAL EXTRACTION
% Parameters controlling Signal Extraction

% cytoring_region_dist: Distances (in pixels) between the cytoplasmic ring
% and the ellipse contour.
%   1x2 array storing the distances of inner and outer boundary of the
%   cytoplasmic ring.
cytoring_region_dist = [1, 4];

% nuc_region_dist: Distances (in pixels) between the nucleus and the
% ellipse contour.
nuc_region_dist = 1;

% background_dist: Distances (in pixels) between the image background and
% the ellipse contour.
background_dist = 20;

% intensity_percentile: Percentile of intensities (0 to 100) to measure.
%   1xn array. Each element defines a percentile to measure.
intensity_percentile = 75;

% [Advanced] outlier_percentile: Outlier percentiles (0 to 50) of
% intensities.
%   Upper X% and lower X% intensities of a region will not be considered
%   for signal calculation.
outlier_percentile = 5;

% organize into a struct
signal_extraction_para = struct('cytoring_region_dist', cytoring_region_dist, ...
    'nuc_region_dist', nuc_region_dist, 'background_dist', background_dist, ...
    'intensity_percentile', intensity_percentile, 'outlier_percentile', outlier_percentile);

%% ASSEMBLE ALL PARAMETERS
all_parameters = struct('movie_definition', movie_definition, 'inout_para', inout_para, ...
    'segmentation_para', segmentation_para, 'prob_para', prob_para, ...
    'track_para', track_para, 'signal_extraction_para', signal_extraction_para);

end
