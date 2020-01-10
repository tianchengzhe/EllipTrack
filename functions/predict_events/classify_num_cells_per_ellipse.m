function [ all_cell_count_prob ] = classify_num_cells_per_ellipse ( varargin )
%CLASSIFY_NUM_CELLS_PER_ELLIPSE Compute the probability that an ellipse
%has zero, one and two cells. 
%
%   Input
%       morphology_training_features (varargin{1}): Features of training 
%       data
%       morphology_training_labels (varargin{2}): Labels of training data
%       all_ellipse_info (varargin{3}): Segmentation results
%       prob_para (varargin{4}): Parameters defining the prediction
%   Output
%       all_cell_count_prob: Probability of having zero, one and two cells

% extract info to use
if (nargin < 3)
    error('classify_num_cells_per_ellipse: Wrong number of inputs for classify_num_cells_per_detection.');
end
morphology_training_features = varargin{1};
morphology_training_labels = varargin{2};
all_ellipse_info = varargin{3};
if (nargin >= 4)
    prob_para = varargin{4};
else % give a fake, but acceptable value
    prob_para = struct('empty_prob', 0);
end

% put before M/ after M/ apoptotic labels as 1 cell (i.e. 4-6 -> 2)
morphology_training_labels(morphology_training_labels>=4) = 2;

% define data structure
num_frames = length(all_ellipse_info);
all_cell_count_prob = cell(num_frames, 1);
for i=1:num_frames
    all_cell_count_prob{i} = nan(size(all_ellipse_info{i}.all_features, 1), 3);
end

% determine the number of available cell counts 
available_labels = intersect(1:3, unique(morphology_training_labels)); % label which is available
missing_labels = setdiff(1:3, available_labels); % label which is missing.

% note that 1 for no cell, 2 for 1 cell, 3 for 2 cells. Assume that a
% number greater than 2 is not possible.
switch (length(available_labels))
    case 0
        warning('classify_num_cells_per_ellipse: No training data for cell counts per ellipse. Assume equal probability for 3 labels.');
        for i=1:num_frames
            all_cell_count_prob{i}(:) = 1/3;
        end
    case 1  % only 1 label exists, no need to learn anything
        for i=1:num_frames
            warning('classify_num_cells_per_ellipse: Only training data for one cell count label is provided. Assume empty_prob for missing labels.');
            all_cell_count_prob{i}(:, missing_labels) = prob_para.empty_prob;
            all_cell_count_prob{i}(:, available_labels) = 1-2*prob_para.empty_prob;
        end
    case 2  % can train an SVM classifier for 2 labels
        % only select those training data for cell numbers
        warning('classify_num_cells_per_ellipse: Only training data for two cell count labels is provided. Assume empty_prob for missing labels.');
        
        % pick up one of the available label to train, train SVM
        adjusted_labels = morphology_training_labels == available_labels(1);
        res = fitcdiscr(morphology_training_features, adjusted_labels, 'ClassNames', [0, 1], ...
            'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
            struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0));
        
        % prediction
        for i=1:num_frames
            test_data = cell2mat(all_ellipse_info{i}.all_features')';
            [~, temp] = predict(res, test_data);
            all_cell_count_prob{i}(:, missing_labels) = prob_para.empty_prob;
            all_cell_count_prob{i}(:, available_labels(1)) = (1-prob_para.empty_prob)*temp(:,2);
            all_cell_count_prob{i}(:, available_labels(2)) = (1-prob_para.empty_prob)*(1-temp(:,2));
        end
    case 3  % can train a multiclass SVM classifier
        % train the multiclass SVM
        res = fitcdiscr(morphology_training_features, morphology_training_labels, 'ClassNames', [1, 2, 3], ...
            'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
            struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0));
        
        % prediction
        for i=1:num_frames
            test_data = cell2mat(all_ellipse_info{i}.all_features')';
            [~, temp] = predict(res, test_data);
            all_cell_count_prob{i}(:,1:3) = temp;
        end
end

end