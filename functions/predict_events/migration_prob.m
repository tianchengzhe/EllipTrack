function [ posterior_prob ] = migration_prob( motion_classifier, curr_features, prev_features, curr_pos, prev_pos, gap, migration_sigma, prob_para )
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
%       prob_para: Parameters for prediction
%   Output
%       posterior_prob: Probability to migrate from old_pos to new_pos

% compute the likelihood of migration
diff_pos = repmat(curr_pos, size(prev_pos, 1), 1) - prev_pos;
likelihood_migration = exp(-(diff_pos(:,1).^2 + diff_pos(:,2).^2)./(2*migration_sigma.^2*gap))./(2*pi*migration_sigma.^2*gap);
invalid_id = abs(diff_pos(:, 1)) >= migration_sigma*prob_para.max_migration_dist_fold*sqrt(gap) | ...
    abs(diff_pos(:, 2)) >= migration_sigma*prob_para.max_migration_dist_fold*sqrt(gap); % find cells travel too far, put the likelihood to 0
likelihood_migration(invalid_id) = 0; 

switch lower(prob_para.migration_option)
    case 'similarity'
        % predict prior probability (similarity score)
        diff_features = repmat(curr_features, size(prev_features,1), 1) - prev_features;
        [~, temp] = predict(motion_classifier, diff_features);
        prior_prob = temp(:,2);

        % compute probability of migration
        posterior_prob = prior_prob.*likelihood_migration ./( prior_prob.*likelihood_migration + (1-prior_prob).*prob_para.prob_nonmigration);
        
    case 'distance'
        posterior_prob = likelihood_migration;
        
    otherwise
        error('migration_prob: unknown option.');
end

end