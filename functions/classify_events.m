function [ all_morphology_posterior_prob ] = classify_events( morphology_training_info, jitter_adjusted_all_ellipse_info, track_para )
%CLASSIFY_EVENTS Classify the probability of an ellipse to display an
%event. Morphological events only.
%
%   Input
%       morphology_training_info: Morphology training features
%       jitter_adjusted_all_ellipse_info: Jitter corrected segmentation
%       results
%       track_para: Parameters for track linking
%   Output
%       all_morphology_posterior_prob: Probability of displaying an event

% define data structures
morphology_training_features = cell2mat({morphology_training_info.features})';
morphology_training_labels = [morphology_training_info.label]';
num_frames = length(jitter_adjusted_all_ellipse_info);
all_morphology_posterior_prob = cell(num_frames, 1);

% classify cell counts
all_cell_count_prob = classify_num_cells_per_ellipse(morphology_training_features, morphology_training_labels, jitter_adjusted_all_ellipse_info, track_para);

% classify others
all_before_mitosis_prob = classify_single_event(morphology_training_features, morphology_training_labels, 4, jitter_adjusted_all_ellipse_info, track_para);
all_after_mitosis_prob = classify_single_event(morphology_training_features, morphology_training_labels, 5, jitter_adjusted_all_ellipse_info, track_para);
all_apoptosis_prob = classify_single_event(morphology_training_features, morphology_training_labels, 6, jitter_adjusted_all_ellipse_info, track_para);

% fill in the stuff
for i=1:num_frames
    all_morphology_posterior_prob{i} = [all_cell_count_prob{i}, all_before_mitosis_prob{i}, all_after_mitosis_prob{i}, all_apoptosis_prob{i}];
end

% modify mitosis and mitosis exit probabilities
for i=1:num_frames
    all_morphology_posterior_prob{i}(all_morphology_posterior_prob{i}(:,4) < track_para.min_mitosis_prob, 4) = 0;
    all_morphology_posterior_prob{i}(all_morphology_posterior_prob{i}(:,5) < track_para.min_mitosis_prob, 5) = 0;
end

% determine whether to convert before M/after M probabilities to 0.5
if (track_para.if_switch_off_before_mitosis)
    for i=1:num_frames
        all_morphology_posterior_prob{i}(:,4) = 0.5;
    end
end
if (track_para.if_switch_off_after_mitosis)
    for i=1:num_frames
        all_morphology_posterior_prob{i}(:,5) = 0.5;
    end
end

% fix maximal probability
for i=1:num_frames
    all_morphology_posterior_prob{i} = min(all_morphology_posterior_prob{i}, 1-1e-10);
end

end
