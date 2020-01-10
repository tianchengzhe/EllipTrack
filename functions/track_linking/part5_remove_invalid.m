function [ all_tracks ] = part5_remove_invalid( all_tracks, track_para )
%PART5_REMOVE_INVALID Remove invalid tracks
%
%   Input
%       all_tracks: Cell tracks
%       track_para: Parameters for track linking
%   Output
%       all_tracks: Modified cell tracks

% define empty track
num_frames = length(all_tracks{1}.current_id);
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
        'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
while 1
    % get track information
    [ all_track_paths, num_tracks, ~, all_firstlast_frame_id ] = get_track_paths( all_tracks, 'firstlast' );
    
    % label all tracks not satisfying the requirement
    invalid_track_list = [];
    for i=1:num_tracks
        id_first = all_firstlast_frame_id(i, 1);
        id_last = all_firstlast_frame_id(i, 2);
        num_NaN_inbetween = sum(isnan(all_track_paths(id_first:id_last, i)));
        if (id_last-id_first+1 < track_para.min_track_length || num_NaN_inbetween > track_para.max_num_frames_to_skip)
            if (isempty(all_tracks{i}.daughters{id_last}) && id_first > 1 && id_last < num_frames)
                invalid_track_list = cat(2, invalid_track_list, i);
            end
        end
    end
    if (isempty(invalid_track_list))
        break;
    end
    valid_track_list = setdiff(1:num_tracks, invalid_track_list);

    % remove invalid tracks and re-assign daughter labels
    all_tracks = all_tracks(valid_track_list);
    mitosis_to_remove = []; % nx3 matrix. mitosis frame id, mother track, daughter track
    for i=1:length(valid_track_list)
        % re-assign daughter id, remove invalid daughter tracks
        last_id = all_firstlast_frame_id(valid_track_list(i), 2);
        new_daughters_id = cell2mat(arrayfun(@(x) find(x==valid_track_list, 1), all_tracks{i}.daughters{last_id}, 'UniformOutput', false));
        all_tracks{i}.daughters{last_id} = new_daughters_id;
        
        % if only one daughter cell exists, remove the mitosis event
        if (length(new_daughters_id) == 1)
            mitosis_to_remove = cat(1, mitosis_to_remove, [last_id, i, new_daughters_id]);
        end
    end
    
    % remove mitosis
    if (~isempty(mitosis_to_remove))
        [~, id] = sort(mitosis_to_remove(:, 1));
        mitosis_to_remove = mitosis_to_remove(id, :);
    end
    for i=1:size(mitosis_to_remove, 1)
        curr_frame = mitosis_to_remove(i, 1); track1_id = mitosis_to_remove(i, 2); track2_id = mitosis_to_remove(i, 3);
        all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame+1 );
        all_tracks{track2_id} = empty_track;
        all_tracks{track1_id}.daughters{curr_frame} = [];
        mitosis_to_remove(mitosis_to_remove(:,1) > curr_frame & mitosis_to_remove(:,2) == track2_id, 2) = track1_id;
        mitosis_to_remove(mitosis_to_remove(:,1) > curr_frame & mitosis_to_remove(:,3) == track2_id, 3) = track1_id;
    end
    
    % remove empty tracks
    all_tracks = remove_empty_tracks(all_tracks);
    disp(['Removed ', num2str(length(invalid_track_list)), ' invalid tracks.']);
end

% fixing gap_to_previous_id and gap_to_next_id
for i=1:length(all_tracks)
    id = find(~isnan(all_tracks{i}.current_id));
    all_tracks{i}.gap_to_previous_id = nan(num_frames, 1);
    all_tracks{i}.gap_to_next_id = nan(num_frames, 1);
    all_tracks{i}.gap_to_previous_id(id(2:end)) = diff(id);
    all_tracks{i}.gap_to_next_id(id(1:end-1)) = diff(id);
end

end