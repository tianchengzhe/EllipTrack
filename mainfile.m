%MAINFILE Main file of tracking code
%% Step 1. Reading Parameters
disp('Step 1. Reading parameters.');
addpath('functions');
addpath('modified_mia_library');

% read parameters
all_parameters = parameters();
global_setting = all_parameters.global_setting;
segmentation_para = all_parameters.segmentation_para;
track_para = all_parameters.track_para;
signal_extraction_para = all_parameters.signal_extraction_para;

% extract information for later use
try
    h = load(global_setting.cmosoffset_path); cmosoffset = h.cmosoffset;
catch
    warning('Fail to load cmosoffset. Will not correct camera dark noise.');
    cmosoffset = 0;
end
try
    h = load(global_setting.nuc_bias_path); nuc_bias = h.bias;
catch
    warning('Fail to load nuclear bias. Will not correct illumination bias for the nuclear channel.');
    nuc_bias = 1;
end
size_image = size( read_image(global_setting.nuc_raw_image_path, global_setting.nd2_frame_range, ...
    global_setting.valid_wells(1,1), global_setting.valid_wells(1,2), global_setting.valid_wells(1,3), ...
    global_setting.nuc_signal_name, global_setting.all_frames(1), cmosoffset, nuc_bias) );
num_sites = max(global_setting.valid_wells(:,3));

%% Step 2. Segmentation
disp('Step 2. Segmentation');
rng(0); % set random seed to ensure reproducibility

all_ellipse_info = cell(8, 12, num_sites);
all_num_ellipses = cell(8, 12, num_sites);
for i=1:size(global_setting.valid_wells, 1)
    % segmentation
    row_id = global_setting.valid_wells(i,1);
    col_id = global_setting.valid_wells(i,2);
    site_id = global_setting.valid_wells(i,3);
    disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
    all_ellipse_info{row_id, col_id, site_id} = segmentation( row_id, col_id, site_id, global_setting, segmentation_para, cmosoffset, nuc_bias );
    
    % count detection number
    all_num_ellipses{row_id, col_id, site_id} = nan(length(global_setting.all_frames), 1);
    for j=1:length(global_setting.all_frames)
        all_num_ellipses{row_id, col_id, site_id}(j) = size(all_ellipse_info{row_id, col_id, site_id}{j}.all_parametric_para, 1);
    end
end
save([global_setting.output_path, 'segmentation.mat'], 'all_ellipse_info', 'all_num_ellipses');

clear i row_id col_id site_id j;

%% Step 3. Jitter Correction 
disp('Step 3. Jitter Correction');
jitters = compute_jitter( global_setting, cmosoffset, nuc_bias );
accumulated_jitters = zeros(size(jitters{1}, 1), size(jitters{1}, 2), length(global_setting.all_frames), 2);

% correct all ellipse info entries
for i=1:size(global_setting.valid_wells, 1)
    row_id = global_setting.valid_wells(i, 1);
    col_id = global_setting.valid_wells(i, 2);
    for j=2:length(global_setting.all_frames)
        % compute accumulated jitter compared to the first image
        curr_jitter = squeeze(jitters{j}(row_id, col_id, :));
        accumulated_jitters(row_id, col_id, j, :) = squeeze(accumulated_jitters(row_id, col_id, j-1, :)) + curr_jitter;
    end
end

save([global_setting.output_path, 'jitter_correction.mat'], 'accumulated_jitters');

clear i row_id col_id j curr_jitter jitters;

%% Step 4. Predicting Events
disp('Step 4. Predicting Events');
rng(0); % set random seed to ensure reproducibility

% load training data
morphology_training_info = [];
motion_training_info = [];
motion_distances = [];
for i=1:size(track_para.training_data_path, 1)
    h = load(track_para.training_data_path{i});
    morphology_training_info = cat(2, morphology_training_info, h.morphology_training_info);
    motion_training_info = cat(2, motion_training_info, h.motion_training_info);
    motion_distances = cat(2, motion_distances, h.motion_distances);
end
disp(['Loaded ', num2str(size(track_para.training_data_path, 1)), ' training datasets.']);

% classify events
all_morphology_posterior_prob = cell(8, 12, num_sites);
all_prob_migration = cell(8, 12, num_sites);
all_prob_inout_frame = cell(8, 12, num_sites);
all_motion_classifiers = cell(8, 12, num_sites);
all_migration_sigma = cell(8, 12, num_sites);
for i=1:size(global_setting.valid_wells, 1)
    row_id = global_setting.valid_wells(i, 1);
    col_id = global_setting.valid_wells(i, 2);
    site_id = global_setting.valid_wells(i, 3);
    disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
    
    % compute morphology events
    all_morphology_posterior_prob{row_id, col_id, site_id} = classify_events( morphology_training_info, all_ellipse_info{row_id, col_id, site_id}, track_para );
    
    % compute migration events
    [ all_prob_migration{row_id, col_id, site_id}, all_prob_inout_frame{row_id, col_id, site_id}, all_motion_classifiers{row_id, col_id, site_id}, all_migration_sigma{row_id, col_id, site_id} ] = compute_score_migration ( size_image, ...
        all_num_ellipses{row_id, col_id, site_id}, motion_training_info, motion_distances, all_ellipse_info{row_id, col_id, site_id}, squeeze(accumulated_jitters(row_id, col_id, :, :)), track_para );
end

save([global_setting.output_path, 'probabilities.mat'], 'all_morphology_posterior_prob', 'all_prob_migration', 'all_prob_inout_frame', 'all_motion_classifiers', 'all_migration_sigma');

clear h morphology_training_info motion_training_info i row_id col_id site_id;

%% Step 5. Generate Tracks
disp('Step 5. Generate Tracks');
all_tracks = cell(8, 12, num_sites);
for i=1:size(global_setting.valid_wells, 1)
    row_id = global_setting.valid_wells(i, 1);
    col_id = global_setting.valid_wells(i, 2);
    site_id = global_setting.valid_wells(i, 3);
    disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
    disp('Current Progress: Compute scores for migration and moving in/out of frames');
    
    % construct tracks
    disp('Current Progress: Construct cell tracks');
    all_tracks{row_id, col_id, site_id} = generate_tracks( all_num_ellipses{row_id, col_id, site_id}, all_morphology_posterior_prob{row_id, col_id, site_id}, ...
        all_prob_migration{row_id, col_id, site_id}, all_prob_inout_frame{row_id, col_id, site_id}, track_para );
    
    % post-processing
    disp('Current Progress: Post-Processing');
    all_tracks{row_id, col_id, site_id} = post_processing( all_ellipse_info{row_id, col_id, site_id}, squeeze(accumulated_jitters(row_id, col_id, :, :)), ...
        all_morphology_posterior_prob{row_id, col_id, site_id}, all_prob_migration{row_id, col_id, site_id}, all_prob_inout_frame{row_id, col_id, site_id}, ...
        all_tracks{row_id, col_id, site_id}, all_motion_classifiers{row_id, col_id, site_id}, all_migration_sigma{row_id, col_id, site_id}, track_para );
end

save([global_setting.output_path, 'tracks.mat'], 'all_tracks');

clear i row_id col_id site_id;

%% Step 6. Visualizing Tracking Performance
disp('Step 6. Visualizing Tracking Performance');
if (track_para.if_print_vistrack)
    for i=1:size(global_setting.valid_wells, 1)
        row_id = global_setting.valid_wells(i, 1);
        col_id = global_setting.valid_wells(i, 2);
        site_id = global_setting.valid_wells(i, 3);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
        visualize_tracking( all_ellipse_info{row_id, col_id, site_id}, all_tracks{row_id, col_id, site_id}, global_setting, row_id, col_id, site_id, track_para, cmosoffset, nuc_bias);
    end

    clear i row_id col_id site_id;
end

%% Step 7. Signal Extraction
disp('Step 7. Signal Extraction');
all_signals = cell(8, 12, num_sites);
for i=1:size(global_setting.valid_wells, 1)
    row_id = global_setting.valid_wells(i, 1);
    col_id = global_setting.valid_wells(i, 2);
    site_id = global_setting.valid_wells(i, 3);
    disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
    all_signals{row_id, col_id, site_id} = signal_extraction( size_image, all_ellipse_info{row_id, col_id, site_id}, squeeze(accumulated_jitters(row_id, col_id, :, :)), ...
        all_tracks{row_id, col_id, site_id}, global_setting , row_id, col_id, site_id, signal_extraction_para, cmosoffset, nuc_bias );
end

save([global_setting.output_path, 'signals.mat'], 'all_signals');

clear i row_id col_id site_id;
