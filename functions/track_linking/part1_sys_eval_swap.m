function [ all_tracks ] = part1_sys_eval_swap( nuc_radius, prob_para, track_para, all_ellipse_info, accumulated_jitters, all_morphology_prob, all_prob_migration, all_prob_inout_frame, all_tracks, migration_sigma )
%PART1_SYS_EVAL_SWAP Systematic evaluation of track swapping
%
%   Input
%       nuc_radius: Average radius of nuclei
%       prob_para: Parameters for prediction
%       track_para: Parameters for track linking
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_morphology_prob: Morphological probabilities
%       all_prob_migration: Migration probabilities
%       all_prob_inout_frame: Probabilities of moving in/out of the field
%       of view
%       all_tracks: Cell tracks
%       migration_sigma: Standard deviation of random walk in one direction
%       and one frame
%   Output
%       all_tracks: Modified cell tracks

num_frames = length(all_tracks{1}.current_id);
[ all_ellipse_positions, all_closest_ellipse_id ] = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, 'closest_ellipse' );
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
    'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
track_to_skip = [];

while 1
    %% SYSTEMATIC SWAPPING 
    % Step 1. Extract Relevant Information
    % extract all track paths
    [ all_track_paths, ~, num_frames, genealogy ] = get_track_paths( all_tracks, 'genealogy' );
    [ ~, ~, ~, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
    
    % information of special events
    [ mitosis_event_list, mitosis_exit_event_list, apoptosis_event_list, movein_event_list ] = get_event_list( all_tracks, all_track_paths );

    % Step 2. Create swap list
    track_to_swap = []; % nx6 matrix. col1: frame id; col2-3: track1+2 id; col4-5: track1+2 status; col 6: situation id
    % iterate over all frames except for the first frame
    for i=2:num_frames
        % record which track has been swapped in this frame
        done_track = [];

        % find valid tracks, ellipse positions, and track status
        possible_track_list = find(~isnan(all_track_paths(i, :)) | ~isnan(all_track_paths(i-1, :))); % should present in at least one frame in consideration
        possible_track_pos = cell(length(possible_track_list), 1);
        possible_track_status = nan(length(possible_track_list), 1);
        possible_track_sigma = nan(length(possible_track_list), 2);
        for j=1:length(possible_track_list)
            curr_track = possible_track_list(j);
            % position at time point i-1
            if isnan(all_track_paths(i-1, curr_track))
                possible_track_pos{j} = [NaN, NaN];
                possible_track_sigma(j, 1) = NaN;
            else
                possible_track_pos{j} = all_ellipse_positions{i-1}(all_track_paths(i-1, curr_track), :);
                possible_track_sigma(j, 1) = migration_sigma{i-1}(all_track_paths(i-1, curr_track));
            end
            % position at time point i
            if isnan(all_track_paths(i, curr_track))
                possible_track_pos{j} = cat(1, possible_track_pos{j}, [NaN, NaN]);
                possible_track_sigma(j, 2) = NaN;
            else
                possible_track_pos{j} = cat(1, possible_track_pos{j}, all_ellipse_positions{i}(all_track_paths(i, curr_track), :));
                possible_track_sigma(j, 2) = migration_sigma{i}(all_track_paths(i, curr_track));
            end
            % status
            if (isnan(all_track_paths(i-1, curr_track))) % not present in the previous frame (mitosis exit or movein)
                if (~isempty(mitosis_exit_event_list) && ~isempty(find(mitosis_exit_event_list(:, 1) == i & mitosis_exit_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 2; % mitosis exit
                elseif (~isempty(movein_event_list) && ~isempty(find(movein_event_list(:, 1) == i & movein_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 4; % move in
                end
            elseif (isnan(all_track_paths(i, curr_track))) % not present in the current frame (mitosis or apoptosis/move out)
                if (~isempty(mitosis_event_list) && ~isempty(find(mitosis_event_list(:, 1) == i-1 & mitosis_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 1; % mitosis
                elseif (~isempty(apoptosis_event_list) && ~isempty(find(apoptosis_event_list(:, 1) == i-1 & apoptosis_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 3; % apoptosis/move out
                end
            else
                possible_track_status(j) = 0; % normal migration
            end
        end

        % for each track in possible_track_list, find which other tracks are within the distance defined by threshold_distance
        valid_track_list = cell(length(possible_track_pos), 1);
        for i1 = 1:length(possible_track_pos)
            for i2 = i1+1:length(possible_track_pos)
                pos_diff = abs(repmat(possible_track_pos{i1}, 2, 1) - repelem(possible_track_pos{i2}, 2, 1));
                
                if (all(pos_diff(~isnan(pos_diff)) <= nanmin([possible_track_sigma(i1, :), possible_track_sigma(i2, :)]) * prob_para.max_migration_dist_fold))
                    valid_track_list{i1} = cat(1, valid_track_list{i1}, i2);
                end
            end
        end

        for i1=1:length(possible_track_list)
            % information of current track
            track1_id = possible_track_list(i1); 
            track1_status = possible_track_status(i1);
            track1_ellipse_id = all_track_paths(i-1:i, track1_id);
            if (ismember(track1_id, done_track) || isempty(valid_track_list{i1}) || isnan(track1_status)) % skip if invalid, has no neighbors, or will swap with other tracks
                continue;
            end
            if (track1_status == 1 && any(ismember(find(genealogy==track1_id), done_track)))
                continue;
            end
            if (track1_status == 2 && ismember(genealogy(track1_id), done_track))
                continue;
            end
            if (~isempty(track_to_skip) && ismember([i, track1_ellipse_id'], track_to_skip, 'rows'))
                continue;
            end
            
            % record possible score swap with each other track
            % nx6 matrix. col1: score; col2-3: track1+2 id; col4-5: track1+2 status; col6: situation id
            score_diff = -inf(length(valid_track_list{i1}), 6);

            % compare with each possible track
            for i2=1:length(valid_track_list{i1})
                % this track should not be in the done_track list
                track2_id = possible_track_list(valid_track_list{i1}(i2));
                track2_status = possible_track_status(valid_track_list{i1}(i2));
                track2_ellipse_id = all_track_paths(i-1:i, track2_id);
                if (ismember(track2_id, done_track) || isnan(track2_status)) % skip if invalid or will swap with other tracks
                    continue;
                end
                if (track2_status == 1 && any(ismember(find(genealogy==track2_id), done_track)))
                    continue;
                end
                if (track2_status == 2 && ismember(genealogy(track2_id), done_track))
                    continue;
                end
                if (~isempty(track_to_skip) && ismember([i, track2_ellipse_id'], track_to_skip, 'rows'))
                    continue;
                end

                % to simplify the script, reverse the track info if
                % track1_status > track2_status
                if (track1_status <= track2_status)
                    curr_track1_id = track1_id; curr_track1_status = track1_status; curr_track1_ellipse_id = track1_ellipse_id;
                    curr_track2_id = track2_id; curr_track2_status = track2_status; curr_track2_ellipse_id = track2_ellipse_id;
                else
                    curr_track1_id = track2_id; curr_track1_status = track2_status; curr_track1_ellipse_id = track2_ellipse_id;
                    curr_track2_id = track1_id; curr_track2_status = track1_status; curr_track2_ellipse_id = track1_ellipse_id;
                end
                
                % calculate the scores before and after swapping
                if (curr_track1_status == 0 && curr_track2_status == 0) % Track 1: D1->D2; Track 2: D3->D4
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    after_score = nan(9, 1);
                    % Situation 1: Track 1: D1->D4; Track 2: D3->D2
                    after_score(1) = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                    % Situation 2-3
                    if (curr_track1_ellipse_id(2) == curr_track2_ellipse_id(2) || all_shared_tracks(i-1, curr_track1_id) ~= 0 || ...
                            all_shared_tracks(i, curr_track1_id) ~= 0 || all_shared_tracks(i, curr_track2_id) ~= 0)
                        after_score(2:3) = -Inf;
                    else
                        % Situation 2: Track 1: D1->D2+D4; Track 2: D3->X via apoptosis
                        after_score(2) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2)}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2)}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 6));
                        % Situation 3: Track 1: D1->D2+D4; Track 2: D3->X via moving out
                        after_score(3) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2)}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2)}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 4-5
                    if (curr_track1_ellipse_id(2) == curr_track2_ellipse_id(2) || all_shared_tracks(i-1, curr_track2_id) ~= 0 || ...
                            all_shared_tracks(i, curr_track1_id) ~= 0 || all_shared_tracks(i, curr_track2_id) ~= 0)
                        after_score(4:5) = -Inf;
                    else
                        % Situation 4: Track 1: D1->X via apoptosis; Track 2: D3->D2+D4
                        after_score(4) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 6)) + ...
                            convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2)}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2)}(curr_track2_ellipse_id(1)));
                        % Situation 5: Track 1: D1->X via moving out; Track 2: D3->D2+D4
                        after_score(5) = convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2)}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2)}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 6: D1->D4; X->D2; D3->X via apoptosis
                    after_score(6) = convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2)}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_ellipse_id(2))) + ...
                        convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 6));
                    % Situation 7: D1->D4; X->D2; D3->X via moving out
                    after_score(7) = convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2)}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_ellipse_id(2))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1)));
                    % Situation 8: D3->D2; X->D4; D1->X via apoptosis
                    after_score(8) = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2)}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 6)) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    % Situation 9: D3->D2; X->D4; D1->X via moving out
                    after_score(9) = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2)}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    % select the best
                    [max_val, max_id] = max(after_score - before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 0 && curr_track2_status == 1) % Track1: D->D; Track 2: M->E1+E2
                    curr_track2_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track2_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track2_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track2_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    after_score = nan(3, 1);
                    % Situation 1: Track 1: D->D+E1; Track 2: M->E2
                    if (curr_track1_ellipse_id(2) == curr_track2_daughters_ellipse_id(1) || ...
                            all_shared_tracks(i-1, curr_track1_id) ~= 0 || all_shared_tracks(i, curr_track1_id) ~= 0)
                        after_score(1) = -Inf;
                    else
                        after_score(1) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_daughters_ellipse_id(1), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 2: Track 1: D->D+E2; Track 2: M->E1
                    if (curr_track1_ellipse_id(2) == curr_track2_daughters_ellipse_id(2) || ...
                            all_shared_tracks(i-1, curr_track1_id) ~= 0 || all_shared_tracks(i, curr_track1_id) ~= 0)
                        after_score(2) = -Inf;
                    else
                        after_score(2) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_daughters_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 3: Track 1: D->E1+E2; Track 2: M->D
                    if (all_shared_tracks(i-1, curr_track1_id) ~= 0)
                        after_score(3) = -Inf;
                    else
                        after_score(3) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_daughters_ellipse_id(1), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_daughters_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    end
                    % select the best
                    [max_val, max_id] = max(after_score - before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 0 && curr_track2_status == 2) % Track 1: D->D; Track 2: M->E1+E2
                    curr_track2_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track2_id));
                    curr_track2_other_ellipse_id = all_track_paths(i, setdiff(all_tracks{genealogy(curr_track2_id)}.daughters{i-1}, curr_track2_id));
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                    % Track 1: D->E1; Track 2: M->D+E2
                    if (curr_track2_other_ellipse_id == curr_track1_ellipse_id(2) || all_shared_tracks(i, curr_track1_id) ~= 0)
                        after_score = -Inf;
                    else
                        after_score = convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                    end
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 0 && curr_track2_status == 3) % Track 1: D1->D2; Track 2: D3->X
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        max(convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 6)), ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1))));
                    % Track 1: D1->X; Track 2: D3->D2 (but 2 ways for D1->X)
                    [max_val, max_id] = max([convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 6)), ...
                        convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track1_ellipse_id(1)))]);
                    after_score = max_val + convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 0 && curr_track2_status == 4) % Track 1: D1->D2; Track 2: X->D3
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    after_score = nan(2, 1);
                    % Situation 1. Track 1: D1->D3; Track 2: X->D2
                    after_score(1) = convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_ellipse_id(2)));
                    % Situation 2. Track 1: D1->D2+D3
                    if (curr_track1_ellipse_id(2) == curr_track2_ellipse_id(2) || all_shared_tracks(i-1, curr_track1_id) ~= 0 || ...
                            all_shared_tracks(i, curr_track1_id) ~= 0 || all_shared_tracks(i, curr_track2_id) ~= 0)
                        after_score(2) = -Inf;
                    else
                        after_score(2) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                    end
                    [max_val, max_id] = max(after_score-before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 1 && curr_track2_status == 1) % Track 1: M1->E1+E2; Track 2: M2->E3+E4
                    curr_track1_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track1_id}.daughters{i-1});
                    curr_track2_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track2_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    after_score = nan(5, 1);
                    % Situation 1: Track 1: M1->E1+E3; Track 2: M2->E2+E4;
                    if (curr_track1_daughters_ellipse_id(1) == curr_track2_daughters_ellipse_id(1) || curr_track1_daughters_ellipse_id(2) == curr_track2_daughters_ellipse_id(2))
                        after_score(1) = -Inf;
                    else
                        after_score(1) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 2: Track 1: M1->E1+E4; Track 2: M2->E2+E3;
                    if (curr_track1_daughters_ellipse_id(1) == curr_track2_daughters_ellipse_id(2) || curr_track1_daughters_ellipse_id(2) == curr_track2_daughters_ellipse_id(1))
                        after_score(2) = -Inf;
                    else
                        after_score(2) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 3: Track 1: M1->E2+E3; Track 2: M2->E1+E4;
                    if (curr_track1_daughters_ellipse_id(2) == curr_track2_daughters_ellipse_id(1) || curr_track1_daughters_ellipse_id(1) == curr_track2_daughters_ellipse_id(2))
                        after_score(3) = -Inf;
                    else
                        after_score(3) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 4: Track 1: M1->E2+E4; Track 2: M2->E1+E3;
                    if (curr_track1_daughters_ellipse_id(2) == curr_track2_daughters_ellipse_id(2) || curr_track1_daughters_ellipse_id(1) == curr_track2_daughters_ellipse_id(1))
                        after_score(4) = -Inf;
                    else
                        after_score(4) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    end
                    % Situation 5: Track 1: M1->E3+E4; Track 2: M2->E1+E2;
                    after_score(5) = convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    [max_val, max_id] = max(after_score - before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 1 && curr_track2_status == 2) % Track 1: M1->E1+E2; Track 2: M2->E3+E4 (exchange M1 and E3)
                    curr_track1_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track1_id}.daughters{i-1});
                    curr_track2_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track2_id));
                    curr_track2_other_ellipse_id = all_track_paths(i, setdiff(all_tracks{genealogy(curr_track2_id)}.daughters{i-1}, curr_track2_id));
                    if (~ismember(curr_track2_id, all_tracks{curr_track1_id}.daughters{i-1})) % separate tracks
                        before_score = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_mother_ellipse_id, 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_other_ellipse_id, 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                        % X->E1; X->E2; M1->E3; M2->E4
                        after_score = convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_daughters_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_daughters_ellipse_id(2))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                        score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                    else % E3 is the daughter of M1. M1->E1+E2
                        curr_track1_other_ellipse_id = setdiff(curr_track1_daughters_ellipse_id, curr_track2_ellipse_id(2));
                        before_score = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_other_ellipse_id, 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_other_ellipse_id, 1}(curr_track1_ellipse_id(1)));
                        % X->E1; M1->E2
                        after_score = convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_other_ellipse_id));
                        score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 2];
                    end
                elseif (curr_track1_status == 1 && curr_track2_status == 3) % Track 1: M->E1+E2; Track 2: D->X
                    curr_track1_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track1_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        max(convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 6)), ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1))));
                    after_score = nan(4, 1);
                    % Situation 1: Track 1: M->E1; Track 2: D->E2
                    after_score(1) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % Situation 2: Track 1: M->E2; Track 2: D->E1
                    after_score(2) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    % Situation 3-4
                    if (all_shared_tracks(i-1, curr_track2_id) ~= 0)
                        after_score(3:4) = -Inf;
                    else
                        % Situation 3: Track 1: M->X via apoptosis; Track 2: D->E1+E2
                        after_score(3) = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 6)) + ...
                            convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                        % Situation 4. Track 1: M->X via moving out; Track 2: D->E1+E2
                        after_score(4) = convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                            convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    end
                    [max_val, max_id] = max(after_score-before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 1 && curr_track2_status == 4) % Track 1: M->E1+E2; Track 2: X->D
                    curr_track1_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track1_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    % X->E1; X->E2; M->D
                    after_score = convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_daughters_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_daughters_ellipse_id(2))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 2 && curr_track2_status == 2) % Track 1: M1->E1+E2; Track 2: M2->E3+E4 (exchange E2 and E3)
                    curr_track1_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track1_id));
                    curr_track1_other_ellipse_id = all_track_paths(i, setdiff(all_tracks{genealogy(curr_track1_id)}.daughters{i-1}, curr_track1_id));
                    curr_track2_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track2_id));
                    curr_track2_other_ellipse_id = all_track_paths(i, setdiff(all_tracks{genealogy(curr_track2_id)}.daughters{i-1}, curr_track2_id));
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                    % Track 1: M1->E1+E3; Track 2: M2->E2+E4
                    if (curr_track1_other_ellipse_id == curr_track2_ellipse_id(2) || curr_track2_other_ellipse_id == curr_track1_ellipse_id(2))
                        after_score = -Inf;
                    else
                        after_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_mother_ellipse_id)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_mother_ellipse_id));
                    end
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 2 && curr_track2_status == 3) % Track 1: M1->E1+E2; Track 2: D->X (exchange E2)
                    curr_track1_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track1_id));
                    curr_track1_other_ellipse_id = all_track_paths(i, setdiff(all_tracks{genealogy(curr_track1_id)}.daughters{i-1}, curr_track1_id));
                    before_score = convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_mother_ellipse_id, 4)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_morphology_prob{i}(curr_track1_other_ellipse_id, 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        max(convert_probability_to_score(all_morphology_prob{i-1}(curr_track2_ellipse_id(1), 6)), ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1))));
                    % Track 1: M->E1; Track 2: D->E2
                    after_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 2 && curr_track2_status == 4) % Track 1: M->E1+E2; Track 2: X->D (exchange E2)
                    curr_track1_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track1_id));
                    curr_track1_other_ellipse_id = all_track_paths(i, setdiff(all_tracks{genealogy(curr_track1_id)}.daughters{i-1}, curr_track1_id));
                    before_score = convert_probability_to_score(all_morphology_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    % Track 1: M->E1+D; Track 2: X->E2
                    if (curr_track1_other_ellipse_id == curr_track2_ellipse_id(2) || all_shared_tracks(i, curr_track2_id) ~= 0)
                        after_score = -Inf;
                    else
                        after_score = convert_probability_to_score(all_morphology_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                            convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_ellipse_id(2)));
                    end
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 3 && curr_track2_status == 4) % Track 1: D1->X; Track 2: X->D2
                    before_score = max(convert_probability_to_score(all_morphology_prob{i-1}(curr_track1_ellipse_id(1), 6)), ...
                        convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track1_ellipse_id(1)))) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    % Track 1: D1->D2; Track2: X
                    after_score = convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                end
            end

            % search for the swap with the highest score
            if (any(score_diff(:, 1) >= track_para.min_swap_score))
                [~, temp] = max(score_diff(:, 1));
                done_track = cat(2, done_track, score_diff(temp, 2:3));
                track_to_swap = cat(1, track_to_swap, [i, score_diff(temp, 2:end)]);
                
                % also mothers and daughters/siblings to done_track list
                if (score_diff(temp, 4) == 1)
                    done_track = cat(2, done_track, find(genealogy==score_diff(temp, 2))');
                elseif (score_diff(temp, 4) == 2)
                    done_track = cat(2, done_track, [genealogy(score_diff(temp, 2)), find(genealogy==genealogy(score_diff(temp, 2)))']);
                end
                if (score_diff(temp, 5) == 1)
                    done_track = cat(2, done_track, find(genealogy==score_diff(temp, 3))');
                elseif (score_diff(temp, 5) == 2)
                    done_track = cat(2, done_track, [genealogy(score_diff(temp, 3)), find(genealogy==genealogy(score_diff(temp, 3)))']);
                end
            end
        end
    end
    
    % handle all swapping cases
    num_swap1 = size(track_to_swap, 1);
    for i=1:num_swap1
        curr_frame = track_to_swap(i, 1); 
        track1_id = track_to_swap(i, 2); track2_id = track_to_swap(i, 3);
        track1_status = track_to_swap(i, 4); track2_status = track_to_swap(i, 5);
        situation_id = track_to_swap(i, 6);
        id_to_swap = []; % nx2 matrix: col1: from track id; col2: to track id.

        % iterate over all possible situations
        if (track1_status == 0 && track2_status == 0) % Track 1: D1->D2; Track 2: D3->D4
            switch (situation_id)
                case 1 % Track 1: D1->D4; Track 2: D3->D2
                    all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                    id_to_swap = [track1_id, track2_id; track2_id, track1_id];
                case {2, 3} % Track 1: D1->D2+D4; Track 2: D3->X via apoptosis/moving out
                    all_tracks = cat(1, cat(1, all_tracks, empty_track), empty_track);
                    all_tracks = swap_tracks( all_tracks, track1_id, length(all_tracks)-1, curr_frame );
                    all_tracks = swap_tracks( all_tracks, track2_id, length(all_tracks), curr_frame );
                    all_tracks{track1_id}.daughters{curr_frame-1} = [length(all_tracks)-1, length(all_tracks)];
                    if (situation_id == 2)
                        all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 1;
                    end
                    id_to_swap = [track1_id, length(all_tracks)-1; track2_id, length(all_tracks)];
                case {4, 5} % Track 1: D1->X via apoptosis/moving out; Track 2: D3->D2+D4
                    all_tracks = cat(1, cat(1, all_tracks, empty_track), empty_track);
                    all_tracks = swap_tracks( all_tracks, track1_id, length(all_tracks)-1, curr_frame );
                    all_tracks = swap_tracks( all_tracks, track2_id, length(all_tracks), curr_frame );
                    all_tracks{track2_id}.daughters{curr_frame-1} = [length(all_tracks)-1, length(all_tracks)];
                    if (situation_id == 4)
                        all_tracks{track1_id}.if_apoptosis(curr_frame-1) = 1;
                    end
                    id_to_swap = [track1_id, length(all_tracks)-1; track2_id, length(all_tracks)];
                case {6, 7} % D1->D4; X->D2; D3->X via apoptosis/moving out
                    all_tracks = cat(1, all_tracks, empty_track);
                    all_tracks = swap_tracks( all_tracks, track1_id, length(all_tracks), curr_frame );
                    all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                    if (situation_id == 6)
                        all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 1;
                    end
                    id_to_swap = [track1_id, length(all_tracks); track2_id, track1_id];
                case {8, 9} % D2->D3; X->D4; D1->X via apoptosis/moving out
                    all_tracks = cat(1, all_tracks, empty_track);
                    all_tracks = swap_tracks( all_tracks, track2_id, length(all_tracks), curr_frame );
                    all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                    if (situation_id == 8)
                        all_tracks{track1_id}.if_apoptosis(curr_frame-1) = 1;
                    end
                    id_to_swap = [track2_id, length(all_tracks); track1_id, track2_id];
            end
        elseif (track1_status == 0 && track2_status == 1) % Track1: D->D; Track 2: M->E1+E2
            if (situation_id == 1) % Situation 1: Track 1: D->D+E1; Track 2: M->E2
                track2_daughters = all_tracks{track2_id}.daughters{curr_frame-1};
                all_tracks = swap_tracks( all_tracks, track2_daughters(2), track2_id, curr_frame );
                all_tracks{track2_id}.daughters{curr_frame-1} = [];
                all_tracks{track2_daughters(2)} = empty_track;
                all_tracks = swap_tracks( all_tracks, track1_id, track2_daughters(2), curr_frame);
                all_tracks{track1_id}.daughters{curr_frame-1} = track2_daughters;
                id_to_swap = [track2_daughters(2), track2_id; track1_id, track2_daughters(2)];
            elseif (situation_id == 2) % Situation 2: Track 1: D->D+E2; Track 2: M->E1
                track2_daughters = all_tracks{track2_id}.daughters{curr_frame-1};
                all_tracks = swap_tracks( all_tracks, track2_daughters(1), track2_id, curr_frame );
                all_tracks{track2_id}.daughters{curr_frame-1} = [];
                all_tracks{track2_daughters(1)} = empty_track;
                all_tracks = swap_tracks( all_tracks, track1_id, track2_daughters(1), curr_frame);
                all_tracks{track1_id}.daughters{curr_frame-1} = track2_daughters;
                id_to_swap = [track2_daughters(1), track2_id; track1_id, track2_daughters(1)];
            elseif (situation_id == 3) % Situation 3: Track 1: D->E1+E2; Track 2: M->D
                all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                all_tracks{track1_id}.daughters{curr_frame-1} = all_tracks{track2_id}.daughters{curr_frame-1};
                all_tracks{track2_id}.daughters{curr_frame-1} = [];
                id_to_swap = [track1_id, track2_id];
            end
        elseif (track1_status == 0 && track2_status == 2) % Track 1: D->D; Track 2: M->E1+E2
            % Track 1: D->E1; Track 2: M->D+E2
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            id_to_swap = [track1_id, track2_id; track2_id, track1_id];
        elseif (track1_status == 0 && track2_status == 3) % Track 1: D1->D2; Track 2: D3->X
            % Track 1: D1->X; Track 2: D3->D2 (but 2 ways for D1->X)
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            all_tracks{track1_id}.if_apoptosis(curr_frame-1) = 2-situation_id;
            all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 0;
            id_to_swap = [track1_id, track2_id];
        elseif (track1_status == 0 && track2_status == 4) % Track 1: D1->D2; Track 2: X->D3
            if (situation_id == 1) % Situation 1. Track 1: D1->D3; Track 2: X->D2
                all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                id_to_swap = [track1_id, track2_id; track2_id, track1_id];
            elseif (situation_id == 2) % Situation 2. Track 1: D1->D2+D3
                all_tracks = cat(1, all_tracks, empty_track);
                all_tracks = swap_tracks( all_tracks, track1_id, length(all_tracks), curr_frame );
                all_tracks{track1_id}.daughters{curr_frame-1} = [track2_id, length(all_tracks)];
                id_to_swap = [track1_id, length(all_tracks)];
            end
        elseif (track1_status == 1 && track2_status == 1) % Track 1: M1->E1+E2; Track 2: M2->E3+E4
            track1_daughters = all_tracks{track1_id}.daughters{curr_frame-1};
            track2_daughters = all_tracks{track2_id}.daughters{curr_frame-1};
            switch (situation_id)
                case 1 % Situation 1: Track 1: M1->E1+E3; Track 2: M2->E2+E4
                    all_tracks{track1_id}.daughters{curr_frame-1} = [track1_daughters(1), track2_daughters(1)];
                    all_tracks{track2_id}.daughters{curr_frame-1} = [track1_daughters(2), track2_daughters(2)];
                case 2 % Situation 2: Track 1: M1->E1+E4; Track 2: M2->E2+E3
                    all_tracks{track1_id}.daughters{curr_frame-1} = [track1_daughters(1), track2_daughters(2)];
                    all_tracks{track2_id}.daughters{curr_frame-1} = [track1_daughters(2), track2_daughters(1)];
                case 3 % Situation 3: Track 1: M1->E2+E3; Track 2: M2->E1+E4
                    all_tracks{track1_id}.daughters{curr_frame-1} = [track1_daughters(2), track2_daughters(1)];
                    all_tracks{track2_id}.daughters{curr_frame-1} = [track1_daughters(1), track2_daughters(2)];
                case 4 % Situation 4: Track 1: M1->E2+E4; Track 2: M2->E1+E3
                    all_tracks{track1_id}.daughters{curr_frame-1} = [track1_daughters(2), track2_daughters(2)];
                    all_tracks{track2_id}.daughters{curr_frame-1} = [track1_daughters(1), track2_daughters(1)];
                case 5 % Situation 5: Track 1: M1->E3+E4; Track 2: M2->E1+E2
                    all_tracks{track1_id}.daughters{curr_frame-1} = [track2_daughters(1), track2_daughters(2)];
                    all_tracks{track2_id}.daughters{curr_frame-1} = [track1_daughters(1), track1_daughters(2)];
            end
            id_to_swap = [];
        elseif (track1_status == 1 && track2_status == 2) % Track 1: M1->E1+E2; Track 2: M2->E3+E4 (exchange M1 and E3)
            if (situation_id == 1)
                % X->E1; X->E2; M1->E3; M2->E4
                track2_mother = []; track2_other_id = [];
                for j=1:length(all_tracks)
                    curr_daughters = all_tracks{j}.daughters{curr_frame-1};
                    if (ismember(track2_id, curr_daughters))
                        track2_mother = j; 
                        track2_other_id = setdiff(curr_daughters, track2_id);
                        break;
                    end
                end
                all_tracks = swap_tracks( all_tracks, track2_mother, track2_other_id, curr_frame );
                all_tracks{track2_mother}.daughters{curr_frame-1} = [];
                all_tracks{track2_other_id} = empty_track;
                all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                all_tracks{track1_id}.daughters{curr_frame-1} = [];
                all_tracks{track2_id} = empty_track;
                id_to_swap = [track2_other_id, track2_mother; track2_id, track1_id];
            elseif (situation_id == 2) % E3 is the daughter of M1. M1->E1+E2
                % X->E1; M1->E2
                all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
                all_tracks{track1_id}.daughters{curr_frame-1} = [];
                all_tracks{track2_id} = empty_track;
                id_to_swap = [track2_id, track1_id];
            end
        elseif (track1_status == 1 && track2_status == 3) % Track 1: M->E1+E2; Track 2: D->X
            track1_daughters = all_tracks{track1_id}.daughters{curr_frame-1};
            switch (situation_id)
                case 1 % Situation 1: Track 1: M->E1; Track 2: D->E2
                    all_tracks = swap_tracks( all_tracks, track1_id, track1_daughters(1), curr_frame );
                    all_tracks{track1_id}.daughters{curr_frame-1} = [];
                    all_tracks = swap_tracks( all_tracks, track1_daughters(2), track2_id, curr_frame );
                    all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 0;
                    all_tracks{track1_daughters(1)} = empty_track;
                    all_tracks{track1_daughters(2)} = empty_track;
                    id_to_swap = [track1_daughters(1), track1_id; track1_daughters(2), track2_id];
                case 2 % Situation 2: Track 1: M->E2; Track 2: D->E1
                    all_tracks = swap_tracks( all_tracks, track1_id, track1_daughters(2), curr_frame );
                    all_tracks{track1_id}.daughters{curr_frame-1} = [];
                    all_tracks = swap_tracks( all_tracks, track1_daughters(1), track2_id, curr_frame );
                    all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 0;
                    all_tracks{track1_daughters(1)} = empty_track;
                    all_tracks{track1_daughters(2)} = empty_track;
                    id_to_swap = [track1_daughters(2), track1_id; track1_daughters(1), track2_id];
                case 3 % Situation 3: Track 1: M->X via apoptosis; Track 2: D->E1+E2
                    all_tracks{track2_id}.daughters{curr_frame-1} = all_tracks{track1_id}.daughters{curr_frame-1};
                    all_tracks{track1_id}.daughters{curr_frame-1} = [];
                    all_tracks{track1_id}.if_apoptosis(curr_frame-1) = 1;
                    all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 0;
                    id_to_swap = [];
                case 4 % Situation 4. Track 1: M->X via moving out; Track 2: D->E1+E2
                    all_tracks{track2_id}.daughters{curr_frame-1} = all_tracks{track1_id}.daughters{curr_frame-1};
                    all_tracks{track1_id}.daughters{curr_frame-1} = [];
                    all_tracks{track1_id}.if_apoptosis(curr_frame-1) = 0;
                    all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 0;
                    id_to_swap = [];
            end
        elseif (track1_status == 1 && track2_status == 4) % Track 1: M->E1+E2; Track 2: X->D
            % X->E1; X->E2; M->D
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            all_tracks{track1_id}.daughters{curr_frame-1} = [];
            all_tracks{track2_id} = empty_track;
            id_to_swap = [track2_id, track1_id];
        elseif (track1_status == 2 && track2_status == 2) % Track 1: M1->E1+E2; Track 2: M2->E3+E4 (exchange E2 and E3)
            % Track 1: M1->E1+E3; Track 2: M2->E2+E4
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            id_to_swap = [track1_id, track2_id; track2_id, track1_id];
        elseif (track1_status == 2 && track2_status == 3) % Track 1: M1->E1+E2; Track 2: D->X (exchange E2)
            % Track 1: M->E1; Track 2: D->E2
            track1_mother = []; track1_other_id = [];
            for j=1:length(all_tracks)
                curr_daughters = all_tracks{j}.daughters{curr_frame-1};
                if (ismember(track1_id, curr_daughters))
                    track1_mother = j; 
                    track1_other_id = setdiff(curr_daughters, track1_id);
                    break;
                end
            end
            all_tracks = swap_tracks( all_tracks, track1_mother, track1_other_id, curr_frame );
            all_tracks{track1_other_id} = empty_track;
            all_tracks{track1_mother}.daughters{curr_frame-1} = [];
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            all_tracks{track2_id}.if_apoptosis(curr_frame-1) = 0;
            all_tracks{track1_id} = empty_track;
            id_to_swap = [track1_other_id, track1_mother; track1_id, track2_id];
        elseif (track1_status == 2 && track2_status == 4) % Track 1: M->E1+E2; Track 2: X->D (exchange E2)
            % Track 1: M->E1+D; Track 2: X->E2
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            id_to_swap = [track1_id, track2_id; track2_id, track1_id];
        elseif (track1_status == 3 && track2_status == 4) % Track 1: D1->X; Track 2: X->D2
            % Track 1: D1->D2; Track2: X
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            all_tracks{track1_id}.if_apoptosis(curr_frame-1) = 0;
            all_tracks{track2_id} = empty_track;
            id_to_swap = [track2_id, track1_id];
        end
        
        % swap the entries of track_to_swap
        temp = track_to_swap;
        for j=1:size(id_to_swap, 1)
            track_to_swap(temp(:,1)>curr_frame & temp(:,2)==id_to_swap(j,1), 2) = id_to_swap(j,2); %#ok<*AGROW>
            track_to_swap(temp(:,1)>curr_frame & temp(:,3)==id_to_swap(j,1), 3) = id_to_swap(j,2);
        end
    end
    all_tracks = remove_empty_tracks(all_tracks);
    
    %% PREMATURE MITOSIS
    % get track information
    [ all_track_paths, ~, ~, all_firstlast_frame_id ] = get_track_paths( all_tracks, 'firstlast' );
    [ ~, ~, ~, all_shared_tracks ] = get_track_paths( all_tracks, 'shared_ellipse' );
    mitosis_list = get_event_list( all_tracks, all_track_paths );

    % Requirement: Track 1 and Track 2 are siblings
    % (1) Track 1
    %   (a) Shorter than track_para.critical_length
    %   (b) Ends earlier than Track 2, and by mitosis
    %   (c) Daughters of Track 1 occupy the original cells of Track 1+2
    % (2) Track 2
    %   (a) Present at Track 1's death and Track 1 Daughters' birth frames
    %   (b) Migrates to a nearby but irrelevant cell
    % (3) During the lifetime of Track 1, either
    %   (a) Skip a frame
    %   (b) Overlap
    %   (c) Mutually closest ellipse, distance of centroid <= 3*nuc_radius, and not overlap with other tracks
    track_to_handle = []; % columns: Mother of Track 1+2, Track 1, Track 2, Daughters of Track 1
    for i=1:size(mitosis_list, 1)
        % sort daughter ID by their death/move-out time
        curr_track = mitosis_list(i, 2); 
        curr_daughter_tracks = all_tracks{curr_track}.daughters{mitosis_list(i, 1)};
        if (any(ismember(curr_daughter_tracks, track_to_handle)) || ismember(curr_track, track_to_handle))
            continue;
        end
        if (all_firstlast_frame_id(curr_daughter_tracks(1), 2) == all_firstlast_frame_id(curr_daughter_tracks(2), 2))
            continue;
        end
        [~, id] = sort(all_firstlast_frame_id(curr_daughter_tracks, 2)); curr_daughter_tracks = curr_daughter_tracks(id); 
        track1_id = curr_daughter_tracks(1); track2_id = curr_daughter_tracks(2);
        track1_first_frame_id = all_firstlast_frame_id(track1_id, 1);
        track1_last_frame_id = all_firstlast_frame_id(track1_id, 2);
        if (track1_last_frame_id-track1_first_frame_id+1 > track_para.critical_length || ...
                isempty(mitosis_list) || ~ismember(track1_id, mitosis_list(:, 2)) || ...
                any(isnan(all_track_paths(track1_first_frame_id, [track1_id, track2_id]))) || ...
                any(isnan(all_track_paths(track1_last_frame_id, [track1_id, track2_id]))) || ...
                isnan(all_track_paths(track1_last_frame_id+1, track2_id))) % (1ab, 2)
            continue;
        end
        track1_daughters_track_id = all_tracks{track1_id}.daughters{track1_last_frame_id};
        if any(ismember(track1_daughters_track_id, track_to_handle))
            continue;
        end
        
        % examine overlap status
        if_correct = 1;
        for j=track1_first_frame_id:track1_last_frame_id
            track1_ellipse_id = all_track_paths(j, track1_id);
            track2_ellipse_id = all_track_paths(j, track2_id);
            if (isnan(track1_ellipse_id) || isnan(track2_ellipse_id) || track1_ellipse_id == track2_ellipse_id)
                continue;
            end
            if (all_closest_ellipse_id{j}(track1_ellipse_id) == track2_ellipse_id && ...
                    all_closest_ellipse_id{j}(track2_ellipse_id) == track1_ellipse_id && ...
                    all_shared_tracks(j, track1_id) == 0 && all_shared_tracks(j, track2_id) == 0 && ...
                    norm(all_ellipse_positions{j}(track1_ellipse_id,:)-all_ellipse_positions{j}(track2_ellipse_id,:)) <= 3*nuc_radius)
                continue;
            end
            if_correct = 0;
            break;
        end
        
        % examine whether mitosis is fake
        if (~if_correct)
            continue;
        end
        before_prob = convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{all_track_paths(track1_last_frame_id+1, track2_id)}(all_track_paths(track1_last_frame_id, track2_id)));
        after_prob = [convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{all_track_paths(track1_last_frame_id+1, track1_daughters_track_id(1))}(all_track_paths(track1_last_frame_id, track2_id))), ...
            convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{all_track_paths(track1_last_frame_id+1, track1_daughters_track_id(2))}(all_track_paths(track1_last_frame_id, track2_id)))];
        if (max(after_prob) - before_prob >= track_para.min_swap_score)
            track_to_handle = cat(1, track_to_handle, [curr_track, track1_id, track2_id, track1_daughters_track_id]);
        end
    end
    
    % handle everything
    num_swap2 = size(track_to_handle, 1);
    for i=1:num_swap2
        % break track2
        track1_id = track_to_handle(i, 2); track1_last_frame_id = all_firstlast_frame_id(track1_id, 2);
        track2_id = track_to_handle(i, 3);
        track1_daughters_track_id = track_to_handle(i, 4:5);
        all_tracks = swap_tracks( all_tracks, track2_id, track1_daughters_track_id(1), track1_last_frame_id+1 );
        all_tracks = swap_tracks( all_tracks, track1_id, track1_daughters_track_id(2), track1_last_frame_id+1 );
        all_tracks{track1_id}.daughters{track1_last_frame_id} = [];
        all_tracks{track1_daughters_track_id(2)} = empty_track;
        
        % swap track1 and track2 if score improves
        track1_ellipse_id = all_tracks{track1_id}.current_id(track1_last_frame_id:track1_last_frame_id+1)';
        track2_ellipse_id = all_tracks{track2_id}.current_id(track1_last_frame_id:track1_last_frame_id+1)';
        before_score = convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{track1_ellipse_id(2)}(track1_ellipse_id(1))) + ...
            convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{track2_ellipse_id(2)}(track2_ellipse_id(1)));
        after_score = convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{track2_ellipse_id(2)}(track1_ellipse_id(1))) + ...
            convert_probability_to_score(all_prob_migration{track1_last_frame_id+1}{track1_ellipse_id(2)}(track2_ellipse_id(1)));
        if (after_score > before_score)
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, track1_last_frame_id+1);
        end
        
        % add to track_to_skip
        track_to_skip = cat(1, track_to_skip, ...
            [track1_last_frame_id+1, track1_ellipse_id;
            track1_last_frame_id+1, track2_ellipse_id;
            track1_last_frame_id+1, track1_ellipse_id(1), track2_ellipse_id(2);
            track1_last_frame_id+1, track2_ellipse_id(1), track1_ellipse_id(2)]);
    end
    all_tracks = remove_empty_tracks( all_tracks );

    if (num_swap1 + num_swap2 == 0)
        break;
    end
    disp(['Fixed ', num2str(num_swap1+num_swap2), ' mappings.']);

end

end
