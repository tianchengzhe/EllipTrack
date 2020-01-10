function [ all_tracks ] = part2_premature_term( nuc_radius, track_para, all_ellipse_info, accumulated_jitters, all_tracks )
%PART2_PREMATURE_TERM Fix premature termination of tracks
%
%   Input
%       nuc_radius: Average radius of nuclei
%       track_para: Parameters for track linking
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_tracks: Cell tracks
%   Output
%       all_tracks: Modified cell tracks

% get ellipse information
num_frames = length(all_tracks{1}.current_id);
[ all_ellipse_positions, all_nuc_areas ] = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, 'area' );
[ ~, all_closest_ellipse_id ] = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, 'closest_ellipse' );
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
    'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});

while 1
    % Step 1. Premature termination after mitosis
    % Mitosis event: M -> T1 + T2. T2 might terminate prematurely due to two
    % daughter cells being closed to each other. Later when two daughter cells
    % are well-separated, a new track T3 is initiated via move-in to describe
    % the cell originally described by T2. Need to link T2 and T3.

    % get track information
    [ all_track_paths, ~, ~, all_firstlast_frame_id ] = get_track_paths( all_tracks, 'firstlast' );
    [ ~, ~, ~, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
    [ mitosis_list, mitosis_exit_list ] = get_event_list( all_tracks, all_track_paths );

    % search for instances
    track_to_handle = []; % columns: T1, T2, T3, other_info, if_mitosis
    for i=1:size(mitosis_list, 1)
        % sort daughter ID by their death/move-out time
        curr_track = mitosis_list(i, 2); 
        curr_daughter_tracks = all_tracks{curr_track}.daughters{mitosis_list(i, 1)};
        if (all_firstlast_frame_id(curr_daughter_tracks(1), 2) ~= all_firstlast_frame_id(curr_daughter_tracks(2), 2))
            [~, id] = sort(all_firstlast_frame_id(curr_daughter_tracks, 2), 'descend');
            curr_daughter_tracks = curr_daughter_tracks(id);
        else
            if (~isempty(mitosis_list) && ismember(curr_daughter_tracks(2), mitosis_list(:, 2)) && ~ismember(curr_daughter_tracks(1), mitosis_list(:, 2)))
                curr_daughter_tracks = curr_daughter_tracks([2, 1]);
            end
        end
        if (~isempty(track_to_handle) && any(ismember(curr_daughter_tracks, track_to_handle(:, 1:4)))) % avoid conflict
            continue;
        end

        % requirement on T2 (curr_daughter_tracks(2))
        % (1) No longer than track_para.critical_length
        % (2) Not overlap with other tracks, or only overlap with daughter 1 at the last frame
        % (3) Terminates by apoptosis/move-out
        daughter2_track_id = curr_daughter_tracks(2);
        daughter2_first_frame_id = all_firstlast_frame_id(daughter2_track_id, 1);
        daughter2_last_frame_id = all_firstlast_frame_id(daughter2_track_id, 2);
        if (daughter2_last_frame_id-daughter2_first_frame_id+1 > track_para.critical_length || ...
                ~ismember(all_shared_tracks(daughter2_last_frame_id, daughter2_track_id), [0, curr_daughter_tracks(1)]) || ...
                (~isempty(mitosis_list) && ismember(daughter2_track_id, mitosis_list(:,2))))
            continue;
        end

        % requirement on T1 (curr_daughter_tracks(1)), T3 (replacement of T2)
        % (1) Birth T3 - Death T2: no longer than track_para.critical_length
        % EITHER (2) Birth of T3 overlap with T1
        % OR
        % (2) Centroids of T1 and T3 are closer than 3x nuc_radius at the birth
        % frame (50% allowance)
        % (3) T1 and T3 have the mutually closest ellipse at the birth frame
        % (4) T3 not overlap with other tracks at the birth frame. T1 not
        % overlap with other tracks between T2 Death and T3 Birth.
        % Possible that T3 is born by mitosis (T1 -> T3 + T4). In this case,
        % replace T1 by T4.
        daughter1_track_id = curr_daughter_tracks(1);
        daughter1_last_frame_id = all_firstlast_frame_id(daughter1_track_id, 2);
        if_found = 0;
        for j=daughter2_last_frame_id+1:min(daughter2_last_frame_id+track_para.critical_length, daughter1_last_frame_id)
            if (all_shared_tracks(j, daughter1_track_id) > 0) 
                % Examine whether T1 overlap with the first frame of T3
                daughter3_track_id = all_shared_tracks(j, daughter1_track_id);
                if (all_firstlast_frame_id(daughter3_track_id, 1) == j && ...
                        (isempty(mitosis_exit_list) || ~ismember(daughter3_track_id, mitosis_exit_list(:, 2))) && ...
                        (isempty(track_to_handle) || ~ismember(daughter3_track_id, track_to_handle(:, 1:4))))
                    if_found = 1;
                    track_to_handle = cat(1, track_to_handle, [daughter1_track_id, daughter2_track_id, daughter3_track_id, NaN, 0]);
                end
                % Otherwise, T1 should not overlap with other tracks
                break;
            elseif isnan(all_shared_tracks(j, daughter1_track_id))
                continue;
            end
            daughter1_ellipse_id = all_track_paths(j, daughter1_track_id);
            daughter3_ellipse_id = all_closest_ellipse_id{j}(daughter1_ellipse_id);
            if (all_closest_ellipse_id{j}(daughter3_ellipse_id) ~= daughter1_ellipse_id || ...
                norm(all_ellipse_positions{j}(daughter1_ellipse_id,:)-all_ellipse_positions{j}(daughter3_ellipse_id,:)) > 3*nuc_radius) % (2) and (3)
                continue;
            end
            daughter3_track_id = find(all_track_paths(j, :) == daughter3_ellipse_id);
            if (length(daughter3_track_id) ~= 1 || all_firstlast_frame_id(daughter3_track_id, 1) ~= j) % T3 initiates at this frame, not overlap with other tracks
                continue;
            end
            if (~isempty(mitosis_exit_list) && ismember(daughter3_track_id, mitosis_exit_list(:, 2))) % must initiate via move-in
                continue;
            end
            if (~isempty(track_to_handle) && ismember(daughter3_track_id, track_to_handle(:, 1:4))) % avoid conflict
                continue;
            end
            % record
            if_found = 1;
            track_to_handle = cat(1, track_to_handle, [daughter1_track_id, daughter2_track_id, daughter3_track_id, NaN, 0]);
            break;
        end
        % check mitosis case
        if (~if_found && daughter1_last_frame_id <= daughter2_last_frame_id+track_para.critical_length)
            if any(all_shared_tracks(daughter2_last_frame_id+1:daughter1_last_frame_id, daughter1_track_id) > 0)
                continue;
            end
            T1_daughters = all_tracks{daughter1_track_id}.daughters{daughter1_last_frame_id};
            if (isempty(T1_daughters) || (~isempty(track_to_handle) && any(ismember(T1_daughters, track_to_handle(:, 1:4)))))
                continue;
            end
            T1_daughters_ellipse_id = all_track_paths(daughter1_last_frame_id+1, T1_daughters);
            if (norm(all_ellipse_positions{daughter1_last_frame_id+1}(T1_daughters_ellipse_id(1),:)-all_ellipse_positions{daughter1_last_frame_id+1}(T1_daughters_ellipse_id(2),:)) > 3*nuc_radius || ... (2)
                    all_closest_ellipse_id{daughter1_last_frame_id+1}(T1_daughters_ellipse_id(1)) ~= T1_daughters_ellipse_id(2) || all_closest_ellipse_id{daughter1_last_frame_id+1}(T1_daughters_ellipse_id(2)) ~= T1_daughters_ellipse_id(1) || ... (3)
                    all_shared_tracks(daughter1_last_frame_id+1, T1_daughters(1)) ~= 0 || all_shared_tracks(daughter1_last_frame_id+1, T1_daughters(2)) ~= 0) % (4)
                continue;
            end
            track_to_handle = cat(1, track_to_handle, [daughter1_track_id, daughter2_track_id, T1_daughters, 1]);
        end
    end

    % handle everything
    num_handle1 = size(track_to_handle, 1);
    for i=1:num_handle1
        if (track_to_handle(i, 5) == 0) % not mitosis
            daughter1_track_id = track_to_handle(i, 1);
            daughter2_track_id = track_to_handle(i, 2); daughter2_last_frame_id = all_firstlast_frame_id(daughter2_track_id, 2);
            daughter3_track_id = track_to_handle(i, 3); daughter3_first_frame_id = all_firstlast_frame_id(daughter3_track_id, 1);
            all_tracks = swap_tracks( all_tracks, daughter2_track_id, daughter3_track_id, daughter3_first_frame_id );
            all_tracks{daughter3_track_id} = empty_track;
            all_tracks{daughter2_track_id}.if_apoptosis(daughter2_last_frame_id) = 0;
            all_tracks{daughter2_track_id}.current_id(daughter2_last_frame_id+1:daughter3_first_frame_id-1) = all_tracks{daughter1_track_id}.current_id(daughter2_last_frame_id+1:daughter3_first_frame_id-1);
        else % mitosis
            daughter1_track_id = track_to_handle(i, 1); daughter1_last_frame_id = all_firstlast_frame_id(daughter1_track_id, 2);
            daughter2_track_id = track_to_handle(i, 2); daughter2_last_frame_id = all_firstlast_frame_id(daughter2_track_id, 2);
            T1_daughters = all_tracks{daughter1_track_id}.daughters{daughter1_last_frame_id};
            all_tracks = swap_tracks( all_tracks, daughter1_track_id, T1_daughters(1), daughter1_last_frame_id+1 );
            all_tracks = swap_tracks( all_tracks, daughter2_track_id, T1_daughters(2), daughter1_last_frame_id+1 );
            all_tracks{T1_daughters(1)} = empty_track;
            all_tracks{T1_daughters(2)} = empty_track;
            all_tracks{daughter1_track_id}.daughters{daughter1_last_frame_id} = [];
            all_tracks{daughter2_track_id}.if_apoptosis(daughter2_last_frame_id) = 0;
            all_tracks{daughter2_track_id}.current_id(daughter2_last_frame_id+1:daughter1_last_frame_id) = all_tracks{daughter1_track_id}.current_id(daughter2_last_frame_id+1:daughter1_last_frame_id);
        end
    end
    all_tracks = remove_empty_tracks( all_tracks );

    % Step 2. Premature termination by oversegmentation
    %     Frame 1 (Correct)     Frame 2 (Over)      Frame 3 (Correct)
    %  T1 ----------------------------|
    %  T2                             |------------------------------
    % Need to concatenate T2 to T1 
    % OR  Frame 1 (Correct)     Frame 2-N (Correct)     Frame N+1 (Correct)
    %  T1 ----------------------------------------|
    %  T2                       |------------------------------------------
    % Need to concatenate T2 to T1 or remove T2 (if T2 ends before T1)

    % get track information
    [ all_track_paths, num_tracks, ~, all_firstlast_frame_id ] = get_track_paths( all_tracks, 'firstlast' );
    [ ~, ~, ~, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
    [ mitosis_list, mitosis_exit_list ] = get_event_list( all_tracks, all_track_paths );
    track_to_handle = []; % nx3 matrix: track1 ID, track2 ID, status id
    for track1_id = 1:num_tracks
        % track 1 info
        if (~isempty(track_to_handle) && ismember(track1_id, track_to_handle(:, 1:2)))
            continue;
        end
        track1_first_frame_id = all_firstlast_frame_id(track1_id, 1);
        track1_last_frame_id = all_firstlast_frame_id(track1_id, 2);

        % Requirement on Track 2
        % (1) Must initiate during track 1 (>=birth, <=death), via move-in
        % (2) Tracks may skip some frames (not the first and last frame of
        % overlap)
        % (3) Track 2 may end in any order. Earlier one via death/move-out.
        % (4) Same ellipse. Only different for over-segmentation, and the two
        % ellipses must satisfy
        %   (a) Mutually closest ellipse
        %   (b) Distance between centroids <= 3x nuc_radius
        %   (c) Sum of nuclear areas within [0.66,1.5]x area(last correct seg.). 
        %   (d) Not overlap with other tracks

        for i=track1_first_frame_id:track1_last_frame_id
            % get track2 info
            if (all_shared_tracks(i, track1_id) > 0)
                track2_id = all_shared_tracks(i, track1_id);
            elseif (all_shared_tracks(i, track1_id) == 0)
                track2_id = find(all_track_paths(i, :) == all_closest_ellipse_id{i}(all_track_paths(i, track1_id)));
                if (length(track2_id) ~= 1)
                    continue;
                end
            else
                continue;
            end
            if (~isempty(track_to_handle) && ismember(track2_id, track_to_handle(:, 1:2)))
                continue;
            end
            track2_first_frame_id = all_firstlast_frame_id(track2_id, 1);
            track2_last_frame_id = all_firstlast_frame_id(track2_id, 2);
            if (track2_first_frame_id ~= i || (~isempty(mitosis_exit_list) && ismember(track2_id, mitosis_exit_list(:, 2)))) % must initiate at the frame, by move-in
                continue;
            end

            % earlier terminated one must be via death/move-out
            if (track1_last_frame_id < track2_last_frame_id)
                last_overlap_id = track1_last_frame_id; status_id = 1;
                if (~isempty(mitosis_list) && ismember(track1_id, mitosis_list(:, 2)))
                    continue;
                end
            elseif (track1_last_frame_id > track2_last_frame_id)
                last_overlap_id = track2_last_frame_id; status_id = 2;
                if (~isempty(mitosis_list) && ismember(track2_id, mitosis_list(:, 2)))
                    continue;
                end
            else
                last_overlap_id = track1_last_frame_id; status_id = 1;
                if (track1_last_frame_id == num_frames || (~isempty(mitosis_list) && any(ismember([track1_id, track2_id], mitosis_list(:, 2)))))
                    continue;
                end
            end

            if any(isnan(all_track_paths(last_overlap_id, [track1_id, track2_id]))) % must not skip the last overlapped frame
                continue;
            end
            
            % check whether closest (4)
            diff_frame_id = find(all_track_paths(track2_first_frame_id:last_overlap_id, track1_id) ~= all_track_paths(track2_first_frame_id:last_overlap_id, track2_id));
            if_correct = 1;
            if ~isempty(diff_frame_id)
                shared_groups = label_consecutive_numbers(diff_frame_id');
                for j=1:length(diff_frame_id)
                    curr_diff_frame_id = diff_frame_id(j) + track2_first_frame_id - 1;
                    last_correct_frame_id = min(diff_frame_id(shared_groups==shared_groups(j))) + track2_first_frame_id - 2;
                    curr_track1_ellipse_id = all_track_paths(curr_diff_frame_id, track1_id);
                    curr_track2_ellipse_id = all_track_paths(curr_diff_frame_id, track2_id);
                    if (isnan(curr_track1_ellipse_id) || isnan(curr_track2_ellipse_id))
                        continue;
                    end
                    curr_sum_area = sum(all_nuc_areas{curr_diff_frame_id}([curr_track1_ellipse_id, curr_track2_ellipse_id]));
                    if (last_correct_frame_id < track1_first_frame_id || isnan(all_track_paths(last_correct_frame_id, track1_id)))
                        last_correct_area = curr_sum_area;
                    else
                        last_correct_area = all_nuc_areas{last_correct_frame_id}(all_track_paths(last_correct_frame_id, track1_id));
                    end

                    if (norm(all_ellipse_positions{curr_diff_frame_id}(curr_track1_ellipse_id, :) - all_ellipse_positions{curr_diff_frame_id}(curr_track2_ellipse_id, :)) > 3*nuc_radius || ... (4a)
                            all_closest_ellipse_id{curr_diff_frame_id}(curr_track1_ellipse_id) ~= curr_track2_ellipse_id || all_closest_ellipse_id{curr_diff_frame_id}(curr_track2_ellipse_id) ~= curr_track1_ellipse_id || ... (4b)
                            curr_sum_area < 0.66*last_correct_area || curr_sum_area > 1.5*last_correct_area || ... (4c)
                            all_shared_tracks(curr_diff_frame_id, track1_id) ~= 0 || all_shared_tracks(curr_diff_frame_id, track2_id) ~= 0) % (4d)
                        if_correct = 0;
                        break;
                    end
                end
            end
            if (if_correct)
                track_to_handle = cat(1, track_to_handle, [track1_id, track2_id, status_id]);
            end
        end
    end
    
    % handle everything
    num_handle2 = size(track_to_handle, 1);
    for i=1:num_handle2
        track1_id = track_to_handle(i, 1); track1_last_frame_id = all_firstlast_frame_id(track1_id, 2);
        track2_id = track_to_handle(i, 2); track2_first_frame_id = all_firstlast_frame_id(track2_id, 1); track2_last_frame_id = all_firstlast_frame_id(track2_id, 2);
        status_id = track_to_handle(i, 3);
        if (status_id == 1)
            all_tracks = swap_tracks(all_tracks, track1_id, track2_id, track1_last_frame_id+1);
            all_tracks{track1_id}.if_apoptosis(track1_last_frame_id) = 0;
        end
        id = find(isnan(all_tracks{track1_id}.current_id(track2_first_frame_id:track2_last_frame_id)) & ~isnan(all_tracks{track2_id}.current_id(track2_first_frame_id:track2_last_frame_id)));
        all_tracks{track1_id}.current_id(id+track2_first_frame_id-1) = all_tracks{track2_id}.current_id(id+track2_first_frame_id-1);
        all_tracks{track2_id} = empty_track;
    end
    all_tracks = remove_empty_tracks( all_tracks );

    % Step 3. Premature termination by undersegmentation
    %     Frame 1 (Correct)     Frame 2 (Under)      Frame 3 (Correct)
    %  T1 ------------------------------------------------------------
    %  T2 --------|                            
    %  T3                                                   |---------
    % Need to concatenate T3 to T2
    
    % get track information
    [ all_track_paths, ~, ~, all_firstlast_frame_id ] = get_track_paths( all_tracks, 'firstlast' );
    [ ~, ~, ~, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
    [ ~, mitosis_exit_list, apoptosis_moveout_list ] = get_event_list( all_tracks, all_track_paths );
    track_to_handle = []; % nx3 matrix: track1 ID, track2 ID, situation id
    for i=1:size(apoptosis_moveout_list, 1)
        % Requirement
        % (1) Birth of T3 - Death of T2 <= track_para.critical_length
        % (2) Birth of T3, Death of T2: two ellipses must satisfy
        %   (a) Overlap
        %   OR
        %   (a) Mutually closest ellipses
        %   (b) Distance of centroids <= 3*nuc_radius
        %   (c) Not overlap with other tracks
        % (3) Intermediate frames, must satisfy ONE of the criteria
        %   (a) Nuc area within [0.66, 1.5]x(T1+T2 area at Death)
        %   (b) Has a mutually closest ellipse not passed by any track
        %   (c) Skip the frame. But never share with other tracks.
        % (4) Birth of T3: Sum of two areas within [0.66, 1.5]x(T1+T2 area at Death)

        % get track2 info
        track2_id = apoptosis_moveout_list(i, 2);
        track2_last_frame_id = apoptosis_moveout_list(i, 1);
        track2_last_ellipse_id = all_track_paths(track2_last_frame_id, track2_id);
        if (ismember(track2_id, track_to_handle))
            continue;
        end
        
        % get track1 info
        if (all_shared_tracks(track2_last_frame_id, track2_id) > 0)
            track1_id = all_shared_tracks(track2_last_frame_id, track2_id);
            sum_nuc_area_at_death = all_nuc_areas{track2_last_frame_id}(track2_last_ellipse_id);
        else
            shared_ellipse_id = all_closest_ellipse_id{track2_last_frame_id}(track2_last_ellipse_id);
            if (all_closest_ellipse_id{track2_last_frame_id}(shared_ellipse_id) ~= track2_last_ellipse_id || ... (2a)
                    norm(all_ellipse_positions{track2_last_frame_id}(shared_ellipse_id,:)-all_ellipse_positions{track2_last_frame_id}(track2_last_ellipse_id,:)) > 3*nuc_radius) % 2(b)
                continue;
            end
            track1_id = find(all_track_paths(track2_last_frame_id, :)==shared_ellipse_id);
            if (length(track1_id) ~= 1) % (2c)
                continue;
            end
            sum_nuc_area_at_death = sum(all_nuc_areas{track2_last_frame_id}([shared_ellipse_id, track2_last_ellipse_id]));
        end
        if ismember(track1_id, track_to_handle)
            continue;
        end
        
        for j=track2_last_frame_id+1:min(track2_last_frame_id+track_para.critical_length, track1_last_frame_id)
           if isnan(all_shared_tracks(j, track1_id)) % (3c)
               continue;
           elseif (all_shared_tracks(j, track1_id) > 0)
               track3_id = all_shared_tracks(j, track1_id);
               if (all_firstlast_frame_id(track3_id, 1) == j && ...
                        (isempty(mitosis_exit_list) || ~ismember(track3_id, mitosis_exit_list(:, 2))) && ...
                        (isempty(track_to_handle) || ~ismember(track3_id, track_to_handle)))
                    track_to_handle = cat(1, track_to_handle, [track1_id, track2_id, track3_id]);
               end
               break;
           end
           
           % whether found one
           curr_track1_ellipse_id = all_track_paths(j, track1_id);
           curr_track3_ellipse_id = all_closest_ellipse_id{j}(curr_track1_ellipse_id);
           if (all_closest_ellipse_id{j}(curr_track3_ellipse_id) == curr_track1_ellipse_id && ... (3)
                   norm(all_ellipse_positions{j}(curr_track1_ellipse_id,:)-all_ellipse_positions{j}(curr_track3_ellipse_id,:)) <= 3*nuc_radius)
               track3_id = find(all_track_paths(j, :) == curr_track3_ellipse_id);
               if (length(track3_id) == 1 && ~ismember(track3_id, track_to_handle) && ... No skip or overlap with other tracks
                       all_firstlast_frame_id(track3_id, 1) == j && (isempty(mitosis_exit_list) || ~ismember(track3_id, mitosis_exit_list(:, 2)))) % move-in at this frame
                   curr_sum_area = sum(all_nuc_areas{j}(all_track_paths(j, [track1_id, track3_id])));
                   if (curr_sum_area <= 1.5*sum_nuc_area_at_death && curr_sum_area >= 0.66*sum_nuc_area_at_death) % (4) -> found
                       track_to_handle = cat(1, track_to_handle, [track1_id, track2_id, track3_id]);
                       break;
                   end
               end
           end

           % not found one, need to satisfy (3a) or (3b)
           if (all_nuc_areas{j}(curr_track1_ellipse_id) >= 0.66*sum_nuc_area_at_death && all_nuc_areas{j}(curr_track1_ellipse_id) <= 1.5*sum_nuc_area_at_death) % (3a)
               continue;
           elseif (all_closest_ellipse_id{j}(curr_track3_ellipse_id) == curr_track1_ellipse_id && ...
                       norm(all_ellipse_positions{j}(curr_track1_ellipse_id,:)-all_ellipse_positions{j}(curr_track3_ellipse_id,:)) <= 3*nuc_radius && ...
                       isempty(find(all_track_paths(j, :) == curr_track3_ellipse_id, 1))) % (3b)
               continue;
           else
               break;
           end
        end
    end

    % handle everything
    num_handle3 = size(track_to_handle, 1);
    for i=1:num_handle3
        track1_id = track_to_handle(i, 1); track2_id = track_to_handle(i, 2); track3_id = track_to_handle(i, 3);
        track2_last_frame_id = all_firstlast_frame_id(track2_id, 2);
        track3_first_frame_id = all_firstlast_frame_id(track3_id, 1);
        all_tracks = swap_tracks(all_tracks, track2_id, track3_id, track3_first_frame_id);
        all_tracks{track3_id} = empty_track;
        all_tracks{track2_id}.if_apoptosis(track2_last_frame_id) = 0;
        all_tracks{track2_id}.current_id(track2_last_frame_id+1:track3_first_frame_id-1) = all_tracks{track1_id}.current_id(track2_last_frame_id+1:track3_first_frame_id-1);
    end
    all_tracks = remove_empty_tracks( all_tracks );
    
    if (num_handle1 + num_handle2 + num_handle3 == 0)
        break;
    end
    disp(['Fixed ', num2str(num_handle1 + num_handle2 + num_handle3), ' premature terminations.']);
end

end