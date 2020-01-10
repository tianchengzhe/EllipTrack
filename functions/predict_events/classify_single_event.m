function [ all_event_prob ] = classify_single_event ( varargin )
%CLASSIFY_SINGLE_EVENT Compute the probability of an ellipse to display an
%event.
%
%   Input
%       morphology_training_features (varargin{1}): Features of training 
%       data
%       morphology_training_labels (varargin{2}): Labels of training data
%       label_to_classify (varargin{3}): Event label to classify
%       all_ellipse_info (varargin{4}): Segmentation results.
%       prob_para (varargin{5}): Parameters defining the prediction
%   Output
%       all_event_prob: Probability of an ellipse to display the event.

% extract info to use
if (nargin < 4)
    error('classify_single_event: Wrong number of inputs for classify_single_event.');
end
morphology_training_features = varargin{1};
morphology_training_labels = varargin{2};
label_to_classify = varargin{3};
all_ellipse_info = varargin{4};
if (nargin >= 5)
    prob_para = varargin{5};
else % give a fake but acceptable prob
    prob_para = struct('empty_prob', 0);
end

% define data structure
num_frames = length(all_ellipse_info);
all_event_prob = cell(num_frames, 1);
for i=1:num_frames
    all_event_prob{i} = nan(size(all_ellipse_info{i}.all_features, 1), 1);
end

% train classifier
adjusted_labels = morphology_training_labels == label_to_classify;
if (sum(adjusted_labels) == 0) % no training data, give empty_prob
    for i=1:num_frames
        all_event_prob{i}(:) = prob_para.empty_prob;
    end
else % has training data, train SVM
    res = fitcdiscr(morphology_training_features, adjusted_labels, 'ClassNames', [0, 1], ...
            'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
            struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0));
    
    % make predictions
    for i=1:num_frames
        test_data = cell2mat(all_ellipse_info{i}.all_features')';
        [~, temp] = predict(res, test_data);
        all_event_prob{i} = temp(:,2);
    end
end

end
