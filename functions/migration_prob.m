function [ posterior_prob ] = migration_prob( motion_classifier, curr_features, prev_features, curr_pos, prev_pos, gap, migration_sigma, track_para )
%MIGRATION_PROB Compute the probability to migrate from one ellipse in a
%frame to another ellipse in a later frame.
%
%   Input
%       motion_classifier: Classifier for motion classification
%       curr_features: Features of the ellipse in the current frame
%       prev_features: Features of all ellipses in the previous frame
%       curr_pos: Position of the ellipse centroid in the current frame 
%       prev_pos: Position of the ellipse centroids in the previous frame
%       gap: The number of frames to jump
%       migration_sigma: Standard deviation of random walk in one direction
%       and one frame.
%       track_para: Parameters for track linking
%   Output
%       posterior_prob: Probability to migrate from old_pos to new_pos

% compute the feature and position difference between the current detection
% and previous detections
diff_features = repmat(curr_features, size(prev_features,1), 1) - prev_features;
diff_pos = repmat(curr_pos, size(prev_pos, 1), 1) - prev_pos;

% predict prior probability (similarity score)
[~, temp] = predict(motion_classifier, diff_features);
prior_prob = temp(:,2);

% compute the likelihood of migration
likelihood_migration = exp(-(diff_pos(:,1).^2 + diff_pos(:,2).^2)/(2*migration_sigma^2*gap))/(2*pi*migration_sigma^2*gap);
invalid_id = abs(diff_pos(:, 1)) >= migration_sigma*track_para.max_migration_distance_fold*sqrt(gap) | ...
    abs(diff_pos(:, 2)) >= migration_sigma*track_para.max_migration_distance_fold*sqrt(gap); % find cells travel too far, put the likelihood to 0
likelihood_migration(invalid_id) = 0; 
if (track_para.if_similarity_for_migration)
    posterior_prob = prior_prob.*likelihood_migration ./( prior_prob.*likelihood_migration + (1-prior_prob).*track_para.likelihood_nonmigration);
else
    posterior_prob = likelihood_migration;
end

end