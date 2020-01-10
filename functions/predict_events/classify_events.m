function [ all_morphology_prob ] = classify_events( prob_para, all_training_data, all_ellipse_info )
%CLASSIFY_EVENTS Classify the probability of an ellipse to display an
%event. Morphological events only.
%
%   Input
%       prob_para: Parameters defining the prediction
%       all_training_data: Training data
%       all_ellipse_info: Segmentation results
%   Output
%       all_morphology_prob: Probability of displaying an event

% aggregate morphological training data
morphology_training_info = [];
for i=1:length(all_training_data)
    morphology_training_info = cat(2, morphology_training_info, all_training_data{i}.morphology_training_info);
end

% define data structures
morphology_training_features = cell2mat({morphology_training_info.features})';
morphology_training_labels = [morphology_training_info.label]';
num_frames = length(all_ellipse_info);
all_morphology_prob = cell(num_frames, 1);

% classify cell counts
all_cell_count_prob = classify_num_cells_per_ellipse(morphology_training_features, morphology_training_labels, all_ellipse_info, prob_para);

% classify others
all_before_mitosis_prob = classify_single_event(morphology_training_features, morphology_training_labels, 4, all_ellipse_info, prob_para);
all_after_mitosis_prob = classify_single_event(morphology_training_features, morphology_training_labels, 5, all_ellipse_info, prob_para);
all_apoptosis_prob = classify_single_event(morphology_training_features, morphology_training_labels, 6, all_ellipse_info, prob_para);

% fill in the stuff
for i=1:num_frames
    all_morphology_prob{i} = [all_cell_count_prob{i}, all_before_mitosis_prob{i}, all_after_mitosis_prob{i}, all_apoptosis_prob{i}];
end

% determine whether to convert before M/after M probabilities to 0.5
if (strcmpi(prob_para.mitosis_inference_option, 'after') || strcmpi(prob_para.mitosis_inference_option, 'none'))
    for i=1:num_frames
        all_morphology_prob{i}(:, 4) = 0.5;
    end
end
if (strcmpi(prob_para.mitosis_inference_option, 'before') || strcmpi(prob_para.mitosis_inference_option, 'none'))
    for i=1:num_frames
        all_morphology_prob{i}(:, 5) = 0.5;
    end
end

% fix maximal probability
for i=1:num_frames
    all_morphology_prob{i} = min(all_morphology_prob{i}, 1-1e-10);
end

end
