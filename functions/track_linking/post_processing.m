function [ all_tracks ] = post_processing ( nuc_radius, prob_para, track_para, all_ellipse_info, accumulated_jitters, all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_tracks, motion_classifier, migration_sigma )
%POST_PROCESSING Correct tracking mistakes
%
%   Input
%       nuc_radius: Average radius of nuclei
%       prob_para: Parameters for prediction
%       track_para: Parameters for track linking
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_morphology_prob: Morphological probabilities
%       all_prob_migration: Migration probabilities
%       all_prob_inout_frame: Probabilities of moving in/out of the field
%       of view
%       all_tracks: Cell tracks
%       motion_classifier: Classifier for motion classification
%       migration_sigma: Standard deviation of random walk in one direction
%       and one frame
%   Output
%       all_tracks: Modified cell tracks

if (isempty(all_tracks))
    error('post_processing: No cell tracks.');
end

%% PART 1. SYSTEMATIC EVALUATION OF SWAPPING
disp('Part 1. Systematic evaluation of track swapping.');
all_tracks = part1_sys_eval_swap( nuc_radius, prob_para, track_para, all_ellipse_info, accumulated_jitters, all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_tracks, migration_sigma);

%% PART 2 FIX PREMATURE TERMINATION OF TRACKS
disp('Part 2. Fix premature termination of tracks.');
all_tracks = part2_premature_term( nuc_radius, track_para, all_ellipse_info, accumulated_jitters, all_tracks );

%% PART 3. FIX TRACK SWAPPING DUE TO UNDERSEGMENTATION
disp('Part 3. Fix track swapping due to undersegmentation.');
all_tracks = part3_swap_underseg( prob_para, all_ellipse_info, accumulated_jitters, all_tracks, motion_classifier, migration_sigma );

%% PART 4. LINK MISSING MITOSIS
disp('Part 4. Find missing mitoses.');
all_tracks = part4_miss_mitosis( nuc_radius, prob_para, track_para, all_ellipse_info, accumulated_jitters, all_morphology_prob, all_tracks );

%% PART 5. DETERMINE AND REMOVE INVALID TRACKS
disp('Part 5. Remove invalid tracks.');
all_tracks = part5_remove_invalid( all_tracks, track_para );

%% PART 6. SWITCH TRACK ID FOR CONVENIENCE
disp('Part 6. Switch track IDs for convenience.');
all_tracks = part6_switch_convenience( all_tracks, all_ellipse_info );

end

