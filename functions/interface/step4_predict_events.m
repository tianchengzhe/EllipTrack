function [ all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_motion_classifiers, all_migration_sigma ] = ...
    step4_predict_events(movie_definition, inout_para, prob_para, all_ellipse_info, all_num_ellipses, accumulated_jitters)
%STEP4_PREDICT_EVENTS Interface function for computing the probabilities of
%morphological and migration events.
%
%   Input
%       movie_definition: Parameters defining the movie
%       inout_para: Parameters defining the inputs and outputs
%       prob_para: Parameters defining the prediction
%       all_ellipse_info: Segmentation results
%       all_num_ellipses: Number of ellipses in each frame
%       accumulated_jitters: Jitters compared to the first image
%   Output
%       all_morphology_prob: Probabilities of morphological events
%       all_prob_migration: Probabilities of migration events
%       all_prob_inout_frame: Probabilities of migrating in/out of field of
%       view
%       all_motion_classifiers: Classifiers for migration events
%       all_migration_sigma: Standard deviation of migration

disp('Step 4. Predicting Events');
rng(0); % set random seed to ensure reproducibility

% load training data
num_training_data_files = size(inout_para.training_data_path, 1);
all_training_data = cell(num_training_data_files, 1);
for i=1:num_training_data_files
    all_training_data{i} = load(inout_para.training_data_path{i});
end
disp(['Loaded ', num2str(num_training_data_files), ' training datasets.']);

% classify events
% version 1: no parallel computing
if (movie_definition.num_cores == 1)
    all_morphology_prob = cell(movie_definition.plate_def);
    all_prob_migration = cell(movie_definition.plate_def);
    all_prob_inout_frame = cell(movie_definition.plate_def);
    all_motion_classifiers = cell(movie_definition.plate_def);
    all_migration_sigma = cell(movie_definition.plate_def);
    for i=1:size(movie_definition.wells_to_track, 1)
        row_id = movie_definition.wells_to_track(i, 1);
        col_id = movie_definition.wells_to_track(i, 2);
        site_id = movie_definition.wells_to_track(i, 3);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);

        % compute morphology events
        all_morphology_prob{row_id, col_id, site_id} = classify_events( prob_para, all_training_data, all_ellipse_info{row_id, col_id, site_id} );

        % compute migration events
        [ all_prob_migration{row_id, col_id, site_id}, all_prob_inout_frame{row_id, col_id, site_id}, all_motion_classifiers{row_id, col_id, site_id}, all_migration_sigma{row_id, col_id, site_id} ] = compute_score_migration ( ...
            movie_definition.size_image, all_num_ellipses{row_id, col_id, site_id}, all_training_data, all_ellipse_info{row_id, col_id, site_id}, squeeze(accumulated_jitters(row_id, col_id, :, :)), prob_para, movie_definition.frames_to_track );
    end
else % version 2: parallel computing, need to redefine variables to optimize slicing
    all_row_id = movie_definition.wells_to_track(:, 1);
    all_col_id = movie_definition.wells_to_track(:, 2);
    all_site_id = movie_definition.wells_to_track(:, 3);
    size_image = movie_definition.size_image;
    frames_to_track = movie_definition.frames_to_track;
    temp_all_ellipse_info = convert_matrix_seq(movie_definition, all_ellipse_info, 'm2a'); 
    temp_all_num_ellipses = convert_matrix_seq(movie_definition, all_num_ellipses, 'm2a'); 
    temp_accu_jitters = convert_accu_jitters(movie_definition, accumulated_jitters);
    
    temp_all_morphology_prob = cell(length(all_row_id), 1);
    temp_all_prob_migration = cell(length(all_row_id), 1);
    temp_all_prob_inout_frame = cell(length(all_row_id), 1);
    temp_all_motion_classifiers = cell(length(all_row_id), 1);
    temp_all_migration_sigma = cell(length(all_row_id), 1);
    
    parfor i=1:length(all_row_id)
        row_id = all_row_id(i);
        col_id = all_col_id(i);
        site_id = all_site_id(i);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
        
        % compute morphology events
        temp_all_morphology_prob{i} = classify_events( prob_para, all_training_data, temp_all_ellipse_info{i} );
    
        % compute migration events
        [ temp_all_prob_migration{i}, temp_all_prob_inout_frame{i}, temp_all_motion_classifiers{i}, temp_all_migration_sigma{i} ] = compute_score_migration ( ...
            size_image, temp_all_num_ellipses{i}, all_training_data, temp_all_ellipse_info{i}, temp_accu_jitters{i}, prob_para, frames_to_track );
    end
    
    % convert to final structure
    all_morphology_prob = convert_matrix_seq(movie_definition, temp_all_morphology_prob, 'a2m');
    all_prob_migration = convert_matrix_seq(movie_definition, temp_all_prob_migration, 'a2m');
    all_prob_inout_frame = convert_matrix_seq(movie_definition, temp_all_prob_inout_frame, 'a2m');
    all_motion_classifiers = convert_matrix_seq(movie_definition, temp_all_motion_classifiers, 'a2m');
    all_migration_sigma = convert_matrix_seq(movie_definition, temp_all_migration_sigma, 'a2m');    
end

save([inout_para.output_path, 'probabilities.mat'], 'all_morphology_prob', 'all_prob_migration', 'all_prob_inout_frame', 'all_motion_classifiers', 'all_migration_sigma');
[~, id] = lastwarn('');
if strcmp(id,'MATLAB:save:sizeTooBigForMATFile') 
    save([inout_para.output_path, 'probabilities.mat'], 'all_morphology_prob', 'all_prob_migration', 'all_prob_inout_frame', 'all_motion_classifiers', 'all_migration_sigma', '-v7.3');
    disp('Use v7.3 switch instead. All variables have been saved.');
end

end