function [ all_tracks ] = part4_miss_mitosis( nuc_radius, prob_para, track_para, all_ellipse_info, accumulated_jitters, all_morphology_prob, all_tracks )
%PART4_MISS_MITOSIS Find missing mitosis events.
%
%   Input
%       nuc_radius: Average radius of nuclei
%       prob_para: Parameters for prediction
%       track_para: Parameters for track linking
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_morphology_prob: Morphological probabilities
%       all_tracks: Cell tracks
%   Output
%       all_tracks: Modified cell tracks

% Requirement
%   Mother/Daughter: (Track 2)
%   (1) High prob of being a mitotic cell at the previous frame
%   (2) High prob of being a newly born cell at the current frame
%   (3) Not sharing with other tracks at these two frames
%   Missing Daughter: (Track 1)
%   (1) High prob of being a newly born cell at curr frame
%   (2) Not overlap with other tracks
%   (3) Initiates with move-in
%   Distance at current frame
%   (1) Mutual closest ellipse
%   (2) Distance of centroid <= 3*nuc_radius

% parameters
min_prob_before_mitosis = track_para.mitosis_detection_min_prob;
min_prob_after_mitosis = track_para.mitosis_detection_min_prob;
if (strcmpi(prob_para.mitosis_inference_option, 'after') || strcmpi(prob_para.mitosis_inference_option, 'none'))
    min_prob_before_mitosis = 0.5;
end
if (strcmpi(prob_para.mitosis_inference_option, 'before') || strcmpi(prob_para.mitosis_inference_option, 'none'))
    min_prob_after_mitosis = 0.5;
end

% get ellipse and track info
[ all_track_paths, ~, num_frames, all_firstlast_frame_id ] = get_track_paths( all_tracks, 'firstlast' );
[ ~, ~, ~, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
[ ~, mitosis_exit_list ] = get_event_list( all_tracks, all_track_paths );
all_ellipse_positions = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, 'none' );
[ ~, all_closest_ellipse_id ] = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, 'closest_ellipse' );

missing_mitosis = []; % col1: frame, col2: Track 1 ID, col3: Track 2 ID
for i=2:num_frames
    candidate_track1_ellipse_id = find(all_morphology_prob{i}(:, 5) >= min_prob_after_mitosis);
    for j=1:length(candidate_track1_ellipse_id)
        % initates via move-in, not overlap with other tracks
        track1_ellipse_id = candidate_track1_ellipse_id(j);
        track1_id = find(all_track_paths(i, :) == track1_ellipse_id);
        if (length(track1_id) ~= 1 || all_firstlast_frame_id(track1_id, 1) ~= i || (~isempty(mitosis_exit_list) && ismember(track1_id, mitosis_exit_list(:, 2))))
            continue;
        end
        
        % find neighbor (Track 2)
        track2_ellipse_id = all_closest_ellipse_id{i}(track1_ellipse_id);
        if (all_closest_ellipse_id{i}(track2_ellipse_id) ~= track1_ellipse_id || ... % distance requirement
                norm(all_ellipse_positions{i}(track2_ellipse_id,:)-all_ellipse_positions{i}(track1_ellipse_id,:)) > 3*nuc_radius)
            continue;
        end
        track2_id = find(all_track_paths(i, :) == track2_ellipse_id); % not overlap
        if (length(track2_id)~= 1 || all_firstlast_frame_id(track2_id, 1) >= i || all_shared_tracks(i-1, track2_id) ~= 0)
            continue;
        end
        
        % prob requirement
        if (all_morphology_prob{i}(track2_ellipse_id, 5) >= min_prob_after_mitosis && all_morphology_prob{i-1}(all_track_paths(i-1, track2_id), 4) >= min_prob_before_mitosis)
            missing_mitosis = cat(1, missing_mitosis, [i, track1_id, track2_id]);
        end
    end
end

% handle tracks
disp(['Found ', num2str(size(missing_mitosis, 1)), ' missing mitoses.']);
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
    'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
for i=1:size(missing_mitosis, 1)
    curr_frame = missing_mitosis(i, 1); track1_id = missing_mitosis(i, 2); track2_id = missing_mitosis(i, 3);
    all_tracks = cat(1, all_tracks, empty_track); new_track_id = length(all_tracks);
    all_tracks = swap_tracks( all_tracks, track2_id, new_track_id, curr_frame );
    all_tracks{track2_id}.daughters{curr_frame-1} = [track1_id, new_track_id];
    
    % change track_to_swap
    missing_mitosis(missing_mitosis(:, 1) > curr_frame & missing_mitosis(:, 2) == track2_id, 2) = new_track_id;
    missing_mitosis(missing_mitosis(:, 1) > curr_frame & missing_mitosis(:, 3) == track2_id, 3) = new_track_id;
end

all_tracks = remove_empty_tracks( all_tracks );

end