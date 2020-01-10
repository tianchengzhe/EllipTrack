function [ all_tracks ] = part3_swap_underseg( prob_para, all_ellipse_info, accumulated_jitters, all_tracks, motion_classifier, migration_sigma )
%PART3_SWAP_UNDERSEG Fix track swapping due to undersegmentation
%
%   Input
%       prob_para: Parameters for prediction
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_tracks: Cell tracks
%       motion_classifier: Classifier for motion classification
%       migration_sigma: Standard deviation of random walk in one direction
%       and one frame
%   Output
%       all_tracks: Modified cell tracks

% Only consider cases satisfying the following conditions
%   (1) Before: Two tracks in different ellipses. Both ellipses are not
%   under-segmented.
%   (2) During: Share with the same track. Skipping frames are not allowed.
%   (3) After: Two tracks in different ellipses. Both ellipses are not
%   under-segmented.

% get information
[ all_track_paths, num_tracks, num_frames, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
all_ellipse_positions = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, 'none' );

% examine every pair of tracks
track_to_swap = []; % nx3 matrix. frame to swap, track id 1, track id 2
for i=1:num_tracks
    % find all shared ellipses
    shared_frames = find(all_shared_tracks(:,i) > 0)';
    if (isempty(shared_frames))
        continue;
    end
    shared_groups = label_consecutive_numbers(shared_frames);
    
    % examine every group, see whether fit requirement
    for j=1:max(shared_groups)
        % current track
        curr_shared_frames = shared_frames(shared_groups == j);
        if (min(curr_shared_frames) == 1 || max(curr_shared_frames) == num_frames) % need to have before and after
            continue;
        end
        
        % track sharing the same ellipse with the current track
        track_to_share_with = unique(all_shared_tracks(curr_shared_frames, i));
        if (length(track_to_share_with) > 1 || track_to_share_with < i) % must share with the same track. prevent duplication
            continue;
        end
        
        % examine before and after 
        prev_frame_id = min(curr_shared_frames) - 1; prev_ellipse_id = all_track_paths(prev_frame_id, [i, track_to_share_with]);
        curr_frame_id = max(curr_shared_frames) + 1; curr_ellipse_id = all_track_paths(curr_frame_id, [i, track_to_share_with]);
        if (any(all_shared_tracks(prev_frame_id, [i, track_to_share_with]) ~= 0) || any(all_shared_tracks(curr_frame_id, [i, track_to_share_with]) ~= 0))
            continue;
        end
        
        % examine similarity score
        try
            curr_assignment_score = convert_probability_to_score(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(1)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(1)}', ...
                all_ellipse_positions{curr_frame_id}(curr_ellipse_id(1), :), all_ellipse_positions{prev_frame_id}(prev_ellipse_id(1), :), curr_frame_id-prev_frame_id, migration_sigma{prev_frame_id}(prev_ellipse_id(1)), prob_para)) + ...
                convert_probability_to_score(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(2)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(2)}', ...
                all_ellipse_positions{curr_frame_id}(curr_ellipse_id(2), :), all_ellipse_positions{prev_frame_id}(prev_ellipse_id(2), :), curr_frame_id-prev_frame_id, migration_sigma{prev_frame_id}(prev_ellipse_id(2)), prob_para));
            alternative_assignment_score = convert_probability_to_score(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(1)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(2)}', ...
                all_ellipse_positions{curr_frame_id}(curr_ellipse_id(1), :), all_ellipse_positions{prev_frame_id}(prev_ellipse_id(2), :), curr_frame_id-prev_frame_id, migration_sigma{prev_frame_id}(prev_ellipse_id(2)), prob_para)) + ...
                convert_probability_to_score(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(2)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(1)}', ...
                all_ellipse_positions{curr_frame_id}(curr_ellipse_id(2), :), all_ellipse_positions{prev_frame_id}(prev_ellipse_id(1), :), curr_frame_id-prev_frame_id, migration_sigma{prev_frame_id}(prev_ellipse_id(1)), prob_para));
            if (alternative_assignment_score > curr_assignment_score) % alternative one is better, need to swap
                track_to_swap = cat(1, track_to_swap, [curr_frame_id, i, track_to_share_with]);
            end
        catch
        end
    end
end

% handle all swapping cases
num_track_to_swap = size(track_to_swap, 1);
if (num_track_to_swap > 0)
    [~, id] = sort(track_to_swap(:, 1)); track_to_swap = track_to_swap(id, :);
end
for i=1:num_track_to_swap
    curr_frame = track_to_swap(i, 1);
    track1_id = track_to_swap(i, 2);
    track2_id = track_to_swap(i, 3);
    all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
    
    id_1_to_2 = {find(track_to_swap(:,1) > curr_frame & track_to_swap(:,2) == track1_id), find(track_to_swap(:,1) > curr_frame & track_to_swap(:,3) == track1_id)};
    id_2_to_1 = {find(track_to_swap(:,1) > curr_frame & track_to_swap(:,2) == track2_id), find(track_to_swap(:,1) > curr_frame & track_to_swap(:,3) == track2_id)};
    track_to_swap(id_1_to_2{1}, 2) = track2_id; track_to_swap(id_1_to_2{2}, 3) = track2_id;
    track_to_swap(id_2_to_1{1}, 2) = track1_id; track_to_swap(id_2_to_1{2}, 3) = track1_id; 
end
all_tracks = remove_empty_tracks( all_tracks );
disp(['Fixed ', num2str(num_track_to_swap), ' track swapping.']);

end
