function [ prob_migration, prob_inout_frame, motion_classifier, migration_sigma ] = compute_score_migration( size_image, all_num_ellipses, motion_training_info, motion_distances, all_ellipse_info, jitter_adjusted_all_ellipse_info, track_para )
%COMPUTE_SCORE_MIGRATION Compute the migration probability between an
%ellipse in one frame to another ellipse in an later frame. Also the
%probability of moving in/out of the field of view.
%   
%   Input
%       size_image: Dimension of the image
%       all_num_ellipses: Number of ellipses in each frame
%       motion_training_info: Morphology training features
%       motion_distances: Distance metric used to infer migration_sigma
%       all_ellipse_info: Segmentation results
%       jitter_adjusted_all_ellipse_info: Segmentation results after jitter
%       correction
%       track_para: Parameters for tracking
%   Output
%       prob_migration: Probability of migration between two ellipses
%       prob_inout_frame: Probability of moving in/out of the field of view
%       motion_classifier: Classifier for motion classification
%       migration_sigma: Standard deviation of random walk in one
%       direction and one frame

%% PART 0. INFER PARAMETER SIGMA
if (~isnan(track_para.migration_sigma))
    migration_sigma = track_para.migration_sigma;
    disp('Parameter migration_sigma is provided. Will not infer the value based on training data.');
else
    f = @(x) -sum(log(normpdf([motion_distances.dist_x], 0, x*sqrt([motion_distances.dist_t])))) ...
        -sum(log(normpdf([motion_distances.dist_y], 0, x*sqrt([motion_distances.dist_t]))));
    temp = fminbnd(f, 0, 1e2);
    if (isnan(temp) || isinf(temp))
        disp('Inferring the value of migration_sigma is failed. Use the default value of 10 instead.');
        migration_sigma = 10;
    else
        disp(['Inferring the value of migration_sigma is successful. The inferred value is ', num2str(temp), '.']);
        migration_sigma = temp;
    end
end

%% PART 1. MIGRATION SCORE
% construct classifier to compute similarity between two detections
motion_training_features = cell2mat({motion_training_info.features})';
motion_training_labels = [motion_training_info.label]';
motion_classifier = fitcdiscr(motion_training_features, motion_training_labels, 'ClassNames', [0, 1], ...
    'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0));
close all;

% define empty structures
num_frames = length(all_num_ellipses); % number of frames
prob_migration = cell(num_frames, 1); % all scores of migration
for i=1:num_frames
    prob_migration{i} = cell(all_num_ellipses(i), track_para.max_gap);
end

% iterate over all frames and detections
for i=2:num_frames % skip the first frame
    allowed_max_gap = min(track_para.max_gap, i-1);
    for j=1:allowed_max_gap
        % compute position and features of all detection on the previous
        % frame
        prev_pos = cell2mat(jitter_adjusted_all_ellipse_info{i-j}.all_parametric_para')';
        prev_pos = prev_pos(:,3:4);
        prev_features = cell2mat(jitter_adjusted_all_ellipse_info{i-j}.all_features')';
        for k=1:all_num_ellipses(i)
            % compute the position and feature of the current detection on
            % the current frame
            curr_pos = jitter_adjusted_all_ellipse_info{i}.all_parametric_para{k}(3:4)';
            curr_features = jitter_adjusted_all_ellipse_info{i}.all_features{k}';
            
            % compute the posterior probability and score of migration
            prob_migration{i}{k,j} = migration_prob( motion_classifier, curr_features, prev_features, curr_pos, prev_pos, j, migration_sigma, track_para );
        end
    end
end

%% PART 2. MOVE IN/OUT SCORES
prob_inout_frame = cell(num_frames, 1);
for i=1:num_frames
    % get rounded center position, adjust to the image size
    center_pos = cell2mat(all_ellipse_info{i}.all_parametric_para')';
    center_pos = round(center_pos(:,3:4));
    center_pos(:,1) = min(max(center_pos(:,1), 1), size_image(2));
    center_pos(:,2) = min(max(center_pos(:,2), 1), size_image(1));
    center_pos(:,1) = min(center_pos(:,1)-1, size_image(2)-center_pos(:,1)); 
    center_pos(:,2) = min(center_pos(:,2)-1, size_image(1)-center_pos(:,2));
    
    % give parameters
    prob_inout_frame{i} = max(max(normpdf(center_pos(:,1), 0, migration_sigma), normpdf(center_pos(:,2), 0, migration_sigma)), track_para.min_inout_prob);
end

end