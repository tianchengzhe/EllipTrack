function [ all_tracks ] = step5_track_linking( movie_definition, inout_para, segmentation_para, prob_para, track_para, all_ellipse_info, all_num_ellipses, ...
    accumulated_jitters, all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_motion_classifiers, all_migration_sigma )
%STEP5_TRACK_LINKING Interface function for track linking
%
%   Input
%       movie_definition: Parameters defining the movie
%       inout_para: Parameters defining inputs and outputs
%       segmentation_para: Parameters for segmentation
%       prob_para: Parameters for prediction
%       track_para: Parameters for track linking
%       all_ellipse_info: Segmentation results
%       all_num_ellipses: Number of ellipses at each frame
%       accumulated_jitters: Jitters compared to the first frame
%       all_morphology_prob: Probabilities of morphological events
%       all_prob_migration: Probabilities of migration events
%       all_prob_inout_frame: Probabilities of migrating in/out of field of
%       view
%       all_motion_classifiers: Classifiers for migration events
%       all_migration_sigma: Standard deviation of migration
%   Output
%       all_tracks: Tracking results

disp('Step 5. Generate Tracks');
nuc_radius = segmentation_para.nonspecific_para.nuc_radius;
% version 1: no parallel computing
if (movie_definition.num_cores == 1) 
    all_tracks = cell(movie_definition.plate_def);
    for i=1:size(movie_definition.wells_to_track, 1)
        row_id = movie_definition.wells_to_track(i, 1);
        col_id = movie_definition.wells_to_track(i, 2);
        site_id = movie_definition.wells_to_track(i, 3);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);

        % construct tracks
        disp('Current Progress: Construct cell tracks');
        all_tracks{row_id, col_id, site_id} = generate_tracks( all_num_ellipses{row_id, col_id, site_id}, all_morphology_prob{row_id, col_id, site_id}, ...
            all_prob_migration{row_id, col_id, site_id}, all_prob_inout_frame{row_id, col_id, site_id}, track_para );

        % post-processing
        disp('Current Progress: Post-Processing');
        all_tracks{row_id, col_id, site_id} = post_processing( nuc_radius, prob_para, track_para, all_ellipse_info{row_id, col_id, site_id}, squeeze(accumulated_jitters(row_id, col_id, :, :)), ...
            all_morphology_prob{row_id, col_id, site_id}, all_prob_migration{row_id, col_id, site_id}, all_prob_inout_frame{row_id, col_id, site_id}, ...
            all_tracks{row_id, col_id, site_id}, all_motion_classifiers{row_id, col_id, site_id}, all_migration_sigma{row_id, col_id, site_id} );
    end
else % version 2: parallel computing, need to redefine variables to optimize slicing
    all_row_id = movie_definition.wells_to_track(:, 1);
    all_col_id = movie_definition.wells_to_track(:, 2);
    all_site_id = movie_definition.wells_to_track(:, 3);
    temp_all_ellipse_info = convert_matrix_seq(movie_definition, all_ellipse_info, 'm2a'); 
    temp_all_num_ellipses = convert_matrix_seq(movie_definition, all_num_ellipses, 'm2a'); 
    temp_accu_jitters = convert_accu_jitters(movie_definition, accumulated_jitters);
    temp_all_morphology_prob = convert_matrix_seq(movie_definition, all_morphology_prob, 'm2a');
    temp_all_prob_migration = convert_matrix_seq(movie_definition, all_prob_migration, 'm2a');
    temp_all_prob_inout_frame = convert_matrix_seq(movie_definition, all_prob_inout_frame, 'm2a');
    temp_all_motion_classifiers = convert_matrix_seq(movie_definition, all_motion_classifiers, 'm2a');
    temp_all_migration_sigma = convert_matrix_seq(movie_definition, all_migration_sigma, 'm2a');
    
    temp_all_tracks = cell(length(all_row_id), 1);
    parfor i=1:length(all_row_id)
        row_id = all_row_id(i);
        col_id = all_col_id(i);
        site_id = all_site_id(i);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);

        % construct tracks
        disp('Current Progress: Construct cell tracks');
        temp_all_tracks{i} = generate_tracks( temp_all_num_ellipses{i}, temp_all_morphology_prob{i}, ...
            temp_all_prob_migration{i}, temp_all_prob_inout_frame{i}, track_para );

        % post-processing
        disp('Current Progress: Post-Processing');
        temp_all_tracks{i} = post_processing( nuc_radius, prob_para, track_para, temp_all_ellipse_info{i}, temp_accu_jitters{i}, ...
            temp_all_morphology_prob{i}, temp_all_prob_migration{i}, temp_all_prob_inout_frame{i}, ...
            temp_all_tracks{i}, temp_all_motion_classifiers{i}, temp_all_migration_sigma{i} );
    end
    
    all_tracks = convert_matrix_seq(movie_definition, temp_all_tracks, 'a2m'); 
end

save([inout_para.output_path, 'tracks.mat'], 'all_tracks');
[~, id] = lastwarn('');
if strcmp(id,'MATLAB:save:sizeTooBigForMATFile') 
    save([inout_para.output_path, 'tracks.mat'], 'all_tracks', '-v7.3');
    disp('Use v7.3 switch instead. All variables have been saved.');
end

end