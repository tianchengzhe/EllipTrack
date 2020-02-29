function [ prob_migration, prob_inout_frame, motion_classifier, all_migration_sigma ] = compute_score_migration( size_image, all_num_ellipses, all_training_data, all_ellipse_info, accumulated_jitters, prob_para, frames_to_track )
%COMPUTE_SCORE_MIGRATION Compute the migration probability between an
%ellipse in one frame to another ellipse in an later frame. Also the
%probability of moving in/out of the field of view.
%   
%   Input
%       size_image: Dimension of the image
%       all_num_ellipses: Number of ellipses in each frame
%       all_training_data: Training data
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       prob_para: Parameters for prediction
%       frames_to_track: Frames to track
%   Output
%       prob_migration: Probability of migration between two ellipses
%       prob_inout_frame: Probability of moving in/out of the field of view
%       motion_classifier: Classifier for motion classification
%       all_migration_sigma: Standard deviation of random walk in one
%       direction and one frame

%% PART 1. INFER MIGRAITON SIGMA
all_migration_sigma = compute_migration_sigma( prob_para, all_training_data, all_num_ellipses, all_ellipse_info, size_image, frames_to_track );

%% PART 2. MIGRATION SCORE
% extract motion training info
motion_training_info = [];
for i=1:length(all_training_data)
    motion_training_info = cat(2, motion_training_info, all_training_data{i}.motion_training_info);
end

% construct classifier to compute similarity between two detections
motion_training_features = cell2mat({motion_training_info.features})';
motion_training_labels = [motion_training_info.label]';
motion_classifier = fitcdiscr(motion_training_features, motion_training_labels, 'ClassNames', [0, 1], ...
    'OptimizeHyperparameters', 'auto', 'HyperparameterOptimizationOptions', ...
    struct('AcquisitionFunctionName','expected-improvement-plus', 'ShowPlots', false, 'Verbose', 0));

% define empty structures
num_frames = length(all_num_ellipses); % number of frames
prob_migration = cell(num_frames, 1); % all scores of migration
for i=1:num_frames
    prob_migration{i} = cell(all_num_ellipses(i), prob_para.max_migration_time);
end

% iterate over all frames and detections
for i=2:num_frames % skip the first frame
    allowed_max_gap = min(prob_para.max_migration_time, i-1);
    for j=1:allowed_max_gap
        % compute position and features of all detection on the previous
        % frame
        prev_pos = cell2mat(all_ellipse_info{i-j}.all_parametric_para')';
        prev_pos = prev_pos(:,3:4); 
        prev_pos(:,1) = prev_pos(:,1) + accumulated_jitters(i-j,2);
        prev_pos(:,2) = prev_pos(:,2) + accumulated_jitters(i-j,1);
        prev_features = cell2mat(all_ellipse_info{i-j}.all_features')';
        for k=1:all_num_ellipses(i)
            % compute the position and feature of the current detection on
            % the current frame
            curr_pos = all_ellipse_info{i}.all_parametric_para{k}(3:4)';
            curr_pos = curr_pos + accumulated_jitters(i, [2,1]);
            curr_features = all_ellipse_info{i}.all_features{k}';
            
            % compute the posterior probability and score of migration
            prob_migration{i}{k,j} = min(migration_prob( motion_classifier, curr_features, prev_features, curr_pos, prev_pos, j, all_migration_sigma{i-j}, prob_para ), 1-1e-10);
        end
    end
end

%% PART 3. MOVE IN/OUT SCORES
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
    prob_inout_frame{i} = min(max(max(normcdf(-center_pos(:,1), 0, all_migration_sigma{i}), normcdf(-center_pos(:,2), 0, all_migration_sigma{i})), prob_para.min_inout_prob), 1-1e-10);
end

end
