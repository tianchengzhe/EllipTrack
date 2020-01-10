%MAINFILE Mainfile of EllipTrack

% add path
addpath(genpath('functions'));
addpath(genpath('third_party_functions'));
addpath(genpath('GUI'));

% tracking pipeline
% initialization
[ movie_definition, inout_para, segmentation_para, prob_para, track_para, signal_extraction_para, cmosoffset, all_bias ] = step1_initialization();

% segmentation
[ all_ellipse_info, all_num_ellipses ] = step2_segmentation( movie_definition, inout_para, segmentation_para, cmosoffset, all_bias{1} );

% jitter correction
[ accumulated_jitters ] = step3_jitter_correction( movie_definition, inout_para, cmosoffset, all_bias{1} );

% prediction of events
[ all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_motion_classifiers, all_migration_sigma ] = ...
    step4_predict_events(movie_definition, inout_para, prob_para, all_ellipse_info, all_num_ellipses, accumulated_jitters);

% track linking
[ all_tracks ] = step5_track_linking( movie_definition, inout_para, segmentation_para, prob_para, track_para, all_ellipse_info, all_num_ellipses, ...
    accumulated_jitters, all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_motion_classifiers, all_migration_sigma );

% visualize tracking
step6_visualize_tracking(movie_definition, inout_para, all_ellipse_info, all_tracks, cmosoffset, all_bias{1});

% signal extraction
[ all_signals ] = step7_signal_extraction( movie_definition, inout_para, ...
    signal_extraction_para, all_ellipse_info, accumulated_jitters, all_tracks, cmosoffset, all_bias );
