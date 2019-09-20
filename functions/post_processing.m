function [ all_tracks ] = post_processing ( all_ellipse_info, accumulated_jitters, all_morphology_posterior_prob, all_prob_migration, all_prob_inout_frame, all_tracks, motion_classifier, migration_sigma, track_para )
%POST_PROCESSING Correct tracking mistakes
%   Input
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       all_morphology_posterior_prob: Morphological probabilities
%       all_prob_migration: Migration probabilities
%       all_prob_inout_frame: Probabilities of moving in/out of the field
%       of view
%       all_tracks: Cell tracks
%       motion_classifier: Classifier for motion classification
%       migration_sigma: Standard deviation of random walk in one direction
%       and one frame
%       track_para: Parameters for track linking
%   Output
%       all_tracks: Modified cell tracks

%% PART 1. SYSTEMATIC EVALUATION OF SWAPPING
while 1
    % Step 1. Extract Relevant Information
    % extract all track paths
    num_tracks = length(all_tracks);
    num_frames = length(all_tracks{1}.current_id);
    all_track_paths = nan(num_frames, num_tracks);
    for i=1:num_tracks
        all_track_paths(:, i) = all_tracks{i}.current_id;
    end

    % record special events (mitosis, newly born, apoptotic/move out, move in)
    % all nx2 matrix. col1: frame id; col2: track id.
    mitosis_event_list = [];
    mitosis_exit_event_list = [];
    apoptosis_event_list = [];
    movein_event_list = [];
    genealogy = nan(num_tracks, 1);
    for i=1:num_tracks % mitosis and mitosis exit
        mitosis_time = find(cellfun(@length, all_tracks{i}.daughters)>0, 1);
        if (isempty(mitosis_time)) % no mitosis
            continue;
        end
        mitosis_event_list = cat(1, mitosis_event_list, [mitosis_time, i]);
        mitosis_exit_event_list = cat(1, mitosis_exit_event_list, [mitosis_time+1, all_tracks{i}.daughters{mitosis_time}(1); mitosis_time+1, all_tracks{i}.daughters{mitosis_time}(2)]);
        genealogy(all_tracks{i}.daughters{mitosis_time}) = i;
    end
    for i=1:num_tracks % apoptosis/move out, movie in
        last_id = find(~isnan(all_track_paths(:, i)), 1, 'last');
        if (~isempty(last_id) && last_id < num_frames && ~ismember(i, mitosis_event_list(:, 2)))
            apoptosis_event_list = cat(1, apoptosis_event_list, [last_id, i]);
        end

        first_id = find(~isnan(all_track_paths(:, i)), 1, 'first');
        if (~isempty(first_id) && first_id > 1 && ~ismember(i, mitosis_exit_event_list(:, 2)))
            movein_event_list = cat(1, movein_event_list, [first_id, i]);
        end
    end

    % record positions of every ellipses (not to compare cells with large distances)
    all_ellipse_positions = cell(num_frames, 1);
    for i=1:num_frames
        all_ellipse_positions{i} = cell2mat(all_ellipse_info{i}.all_parametric_para')';
        all_ellipse_positions{i} = all_ellipse_positions{i}(:, 3:4);
        all_ellipse_positions{i}(:,1) = all_ellipse_positions{i}(:,1) + accumulated_jitters(i,2);
        all_ellipse_positions{i}(:,2) = all_ellipse_positions{i}(:,2) + accumulated_jitters(i,1);
    end

    % define threshold distance and probabilities
    threshold_distance = migration_sigma * track_para.max_migration_distance_fold;

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
        for j=1:length(possible_track_list)
            curr_track = possible_track_list(j);
            % position at time point i-1
            try
                possible_track_pos{j} = all_ellipse_positions{i-1}(all_track_paths(i-1, curr_track), :);
            catch
                possible_track_pos{j} = [NaN, NaN];
            end
            % position at time point i
            try
                possible_track_pos{j} = cat(1, possible_track_pos{j}, all_ellipse_positions{i}(all_track_paths(i, curr_track), :));
            catch
                possible_track_pos{j} = cat(1, possible_track_pos{j}, [NaN, NaN]);
            end
            % status
            if (isnan(all_track_paths(i-1, curr_track))) % not present in the previous frame (mitosis exit or movein)
                if (~isempty(find(mitosis_exit_event_list(:, 1) == i & mitosis_exit_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 2; % mitosis exit
                elseif (~isempty(find(movein_event_list(:, 1) == i & movein_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 4; % move in
                end
            elseif (isnan(all_track_paths(i, curr_track))) % not present in the current frame (mitosis or apoptosis/move out)
                if (~isempty(find(mitosis_event_list(:, 1) == i-1 & mitosis_event_list(:, 2) == curr_track, 1)))
                    possible_track_status(j) = 1; % mitosis
                elseif (~isempty(find(apoptosis_event_list(:, 1) == i-1 & apoptosis_event_list(:, 2) == curr_track, 1)))
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
                if (all(pos_diff(~isnan(pos_diff)) <= threshold_distance))
                    valid_track_list{i1} = cat(1, valid_track_list{i1}, i2);
                    % valid_track_list{i2} = cat(1, valid_track_list{i2}, i1); % comment away to avoid repetition
                end
            end
        end

        for i1=1:length(possible_track_list)
            % this track should not be in the done_track list, and have possible tracks to swap
            track1_id = possible_track_list(i1); 
            track1_status = possible_track_status(i1);
            track1_ellipse_id = all_track_paths(i-1:i, track1_id);
            if (ismember(track1_id, done_track) || isempty(valid_track_list{i1}) || isnan(track1_status))
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
                if (ismember(track2_id, done_track) || isnan(track2_status))
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
                    % Track 1: D1->D3; Track 2: D2->D4
                    after_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 0 && curr_track2_status == 1) % Track1: D->D; Track 2: M->E1+E2
                    curr_track2_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track2_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    after_score = nan(3, 1);
                    % Situation 1: Track 1: D->D+E1; Track 2: M->E2
                    after_score(1) = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % Situation 2: Track 1: D->D+E2; Track 2: M->E1
                    after_score(2) = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    % Situation 3: Track 1: D->E1+E2; Track 2: M->D
                    after_score(3) = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % select the best
                    [max_val, max_id] = max(after_score - before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 0 && curr_track2_status == 2) % Track 1: D->D; Track 2: M->E1+E2
                    curr_track2_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track2_id));
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                    % Track 1: D->E1; Track 2: M->D+E2
                    after_score = convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 0 && curr_track2_status == 3) % Track 1: D1->D2; Track 2: D3->X
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        max(convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_ellipse_id(1), 6)), ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1))));
                    % Track 1: D1->X; Track 2: D3->D2 (but 2 ways for D1->X)
                    [max_val, max_id] = max([convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 6)), ...
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
                    after_score(2) = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
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
                    after_score(1) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % Situation 2: Track 1: M1->E1+E4; Track 2: M2->E2+E3;
                    after_score(2) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    % Situation 3: Track 1: M1->E2+E3; Track 2: M2->E1+E4;
                    after_score(3) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % Situation 4: Track 1: M1->E2+E4; Track 2: M2->E1+E3;
                    after_score(4) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
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
                    curr_track2_other_ellipse_id = all_track_paths(i, all_tracks{genealogy(curr_track2_id)}.daughters{i-1});
                    curr_track2_other_ellipse_id(find(curr_track2_other_ellipse_id==curr_track2_ellipse_id(2), 1)) = [];
                    if (~ismember(curr_track2_id, all_tracks{curr_track1_id}.daughters{i-1})) % separate tracks
                        before_score = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_mother_ellipse_id, 4)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_other_ellipse_id, 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                        % X->E1; X->E2; M1->E3; M2->E4
                        after_score = convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_daughters_ellipse_id(1))) + ...
                            convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_daughters_ellipse_id(2))) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_ellipse_id(1)));
                        score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                    else % E3 is the daughter of M1. M1->E1+E2
                        curr_track1_other_ellipse_id = curr_track1_daughters_ellipse_id; 
                        curr_track1_other_ellipse_id(find(curr_track1_other_ellipse_id==curr_track2_ellipse_id(2), 1)) = [];
                        before_score = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_other_ellipse_id, 5)) + ...
                            convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                            convert_probability_to_score(all_prob_migration{i}{curr_track1_other_ellipse_id, 1}(curr_track1_ellipse_id(1)));
                        % X->E1; M1->E2
                        after_score = convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_other_ellipse_id));
                        score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 2];
                    end
                elseif (curr_track1_status == 1 && curr_track2_status == 3) % Track 1: M->E1+E2; Track 2: D->X
                    curr_track1_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track1_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        max(convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_ellipse_id(1), 6)), ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1))));
                    after_score = nan(4, 1);
                    % Situation 1: Track 1: M->E1; Track 2: D->E2
                    after_score(1) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % Situation 2: Track 1: M->E2; Track 2: D->E1
                    after_score(2) = convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1)));
                    % Situation 3: Track 1: M->X via apoptosis; Track 2: D->E1+E2
                    after_score(3) = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 6)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    % Situation 4. Track 1: M->X via moving out; Track 2: D->E1+E2
                    after_score(4) = convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track1_ellipse_id(1))) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(1), 1}(curr_track2_ellipse_id(1))) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_daughters_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    [max_val, max_id] = max(after_score-before_score);
                    score_diff(i2, :) = [max_val, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, max_id];
                elseif (curr_track1_status == 1 && curr_track2_status == 4) % Track 1: M->E1+E2; Track 2: X->D
                    curr_track1_daughters_ellipse_id = all_track_paths(i, all_tracks{curr_track1_id}.daughters{i-1});
                    before_score = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(1), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_daughters_ellipse_id(2), 5)) + ...
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
                    curr_track2_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track2_id));
                    before_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track2_mother_ellipse_id));
                    % Track 1: M1->E1+E3; Track 2: M2->E2+E4
                    after_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_mother_ellipse_id)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_mother_ellipse_id));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 2 && curr_track2_status == 3) % Track 1: M1->E1+E2; Track 2: D->X (exchange E2)
                    curr_track1_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track1_id));
                    curr_track1_other_ellipse_id = all_track_paths(i, all_tracks{genealogy(curr_track1_id)}.daughters{i-1});
                    curr_track1_other_ellipse_id(find(curr_track1_other_ellipse_id==curr_track1_ellipse_id(2), 1)) = [];
                    before_score = convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_mother_ellipse_id, 4)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_other_ellipse_id, 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        max(convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track2_ellipse_id(1), 6)), ...
                            convert_probability_to_score(all_prob_inout_frame{i-1}(curr_track2_ellipse_id(1))));
                    % Track 1: M->E1; Track 2: D->E2
                    after_score = convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track2_ellipse_id(1)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 2 && curr_track2_status == 4) % Track 1: M->E1+E2; Track 2: X->D (exchange E2)
                    curr_track1_mother_ellipse_id = all_track_paths(i-1, genealogy(curr_track1_id));
                    before_score = convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track1_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track1_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track2_ellipse_id(2)));
                    % Track 1: M->E1+D; Track 2: X->E2
                    after_score = convert_probability_to_score(all_morphology_posterior_prob{i}(curr_track2_ellipse_id(2), 5)) + ...
                        convert_probability_to_score(all_prob_migration{i}{curr_track2_ellipse_id(2), 1}(curr_track1_mother_ellipse_id)) + ...
                        convert_probability_to_score(all_prob_inout_frame{i}(curr_track1_ellipse_id(2)));
                    score_diff(i2, :) = [after_score-before_score, curr_track1_id, curr_track2_id, curr_track1_status, curr_track2_status, 1];
                elseif (curr_track1_status == 3 && curr_track2_status == 4) % Track 1: D1->X; Track 2: X->D2
                    before_score = max(convert_probability_to_score(all_morphology_posterior_prob{i-1}(curr_track1_ellipse_id(1), 6)), ...
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

    if (isempty(track_to_swap))
        break;
    end
    
    % handle all swapping cases
    num_track_to_swap = size(track_to_swap, 1);
    empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
                'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
    for i=1:num_track_to_swap
        curr_frame = track_to_swap(i, 1); 
        track1_id = track_to_swap(i, 2); track2_id = track_to_swap(i, 3);
        track1_status = track_to_swap(i, 4); track2_status = track_to_swap(i, 5);
        situation_id = track_to_swap(i, 6);
        id_to_swap = []; % nx2 matrix: col1: from track id; col2: to track id.

        % iterate over all possible situations
        if (track1_status == 0 && track2_status == 0) % Track 1: D1->D2; Track 2: D3->D4
            % Track 1: D1->D3; Track 2: D2->D4
            all_tracks = swap_tracks( all_tracks, track1_id, track2_id, curr_frame );
            id_to_swap = [track1_id, track2_id; track2_id, track1_id];
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
                        track2_other_id = curr_daughters; track2_other_id(find(track2_other_id==track2_id, 1)) = [];
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
                    track1_other_id = curr_daughters; track1_other_id(find(track1_other_id==track1_id, 1)) = [];
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
    
    disp(['Part 1. Fix ', num2str(size(track_to_swap, 1)), ' mappings.']);
end

%% PART 2. ADJUST CELL ID ASSIGNMENT FOR ELLIPSES WITH MORE THAN 1 CELL
% aggregate all track values
num_tracks = length(all_tracks);
if (num_tracks == 0)
    return;
end
num_frames = length(all_tracks{1}.current_id);
all_track_paths = nan(num_frames, num_tracks);
for i=1:num_tracks
    all_track_paths(:,i) = all_tracks{i}.current_id;
end

% Realistic cases are very complicated. Here we only focus on cases
% satisfying the following conditions
% (1) two tracks are initially located in different ellipses, and both
% ellipses have only one cell
% (2) two tracks share one ellipse for a few frames, with no skipping
% frames
% (3) two tracks get separated into two ellipses in the next frame, and
% both ellipses have only one cell

% record which track the current track shares with
shared_ellipse_list = nan(num_frames, num_tracks);
for i=1:num_tracks
    valid_ellipse_id = find(~isnan(all_track_paths(:, i)));
    for j=1:length(valid_ellipse_id)
        temp = setdiff(find(all_track_paths(valid_ellipse_id(j),:) == all_track_paths(valid_ellipse_id(j),i)), i);
        if (isempty(temp))
            shared_ellipse_list(valid_ellipse_id(j), i) = 0;
        else
            shared_ellipse_list(valid_ellipse_id(j), i) = temp;
        end
    end
end

% examine every pair of tracks
track_to_swap = []; % nx3 matrix. frame to swap, track id 1, track id 2
for i=1:num_tracks
    % find all shared ellipses
    shared_frames = find(shared_ellipse_list(:,i) > 0)';
    if (isempty(shared_frames))
        continue;
    end
    shared_groups = label_consecutive_numbers(shared_frames);
    
    % examine every group, see whether fit requirement
    for j=1:max(shared_groups)
        % current track
        curr_shared_frames = shared_frames(shared_groups == j);
        if (curr_shared_frames(1) == 1 || curr_shared_frames(end) == num_frames) % need to have a previous and next frame
            continue;
        end
        
        % track which is shared with current track
        track_to_share_with = unique(shared_ellipse_list(curr_shared_frames, i));
        if (length(track_to_share_with) ~= 1 || track_to_share_with < i) % prevent duplication
            continue;
        end
        
        % examine sharing condition before and other curr_shared_frames 
        prev_frame_id = curr_shared_frames(1) - 1; prev_ellipse_id = all_track_paths(prev_frame_id, [i, track_to_share_with]);
        curr_frame_id = curr_shared_frames(end) + 1; curr_ellipse_id = all_track_paths(curr_frame_id, [i, track_to_share_with]);
        if (shared_ellipse_list(prev_frame_id, i) ~= 0 || shared_ellipse_list(curr_frame_id, i) ~= 0 || ...
                shared_ellipse_list(prev_frame_id, track_to_share_with) ~= 0 || shared_ellipse_list(curr_frame_id, track_to_share_with) ~= 0) % no duplication in previous and next frame
            continue;
        end
        
        % examine similarity score
        try
            curr_assignment_score = log(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(1)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(1)}', ...
                all_ellipse_info{curr_frame_id}.all_parametric_para{curr_ellipse_id(1)}(3:4)'+accumulated_jitters(curr_frame_id,[2,1]), all_ellipse_info{prev_frame_id}.all_parametric_para{prev_ellipse_id(1)}(3:4)'+accumulated_jitters(prev_frame_id,[2,1]), curr_frame_id-prev_frame_id, migration_sigma, track_para)) + ...
                log(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(2)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(2)}', ...
                all_ellipse_info{curr_frame_id}.all_parametric_para{curr_ellipse_id(2)}(3:4)'+accumulated_jitters(curr_frame_id,[2,1]), all_ellipse_info{prev_frame_id}.all_parametric_para{prev_ellipse_id(2)}(3:4)'+accumulated_jitters(prev_frame_id,[2,1]), curr_frame_id-prev_frame_id, migration_sigma, track_para));
            alternative_assignment_score = log(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(1)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(2)}', ...
                all_ellipse_info{curr_frame_id}.all_parametric_para{curr_ellipse_id(1)}(3:4)'+accumulated_jitters(curr_frame_id,[2,1]), all_ellipse_info{prev_frame_id}.all_parametric_para{prev_ellipse_id(2)}(3:4)'+accumulated_jitters(prev_frame_id,[2,1]), curr_frame_id-prev_frame_id, migration_sigma, track_para)) + ...
                log(migration_prob( motion_classifier, all_ellipse_info{curr_frame_id}.all_features{curr_ellipse_id(2)}', all_ellipse_info{prev_frame_id}.all_features{prev_ellipse_id(1)}', ...
                all_ellipse_info{curr_frame_id}.all_parametric_para{curr_ellipse_id(2)}(3:4)'+accumulated_jitters(curr_frame_id,[2,1]), all_ellipse_info{prev_frame_id}.all_parametric_para{prev_ellipse_id(1)}(3:4)'+accumulated_jitters(prev_frame_id,[2,1]), curr_frame_id-prev_frame_id, migration_sigma, track_para));
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
disp(['Part 2. Fix ', num2str(num_track_to_swap), ' track swapping.']);

%% PART 3. LINK MISSING MITOSIS
% Step 1. Prepare necessary data structure
% define threshold distance and probabilities
threshold_distance = migration_sigma * track_para.max_migration_distance_fold;
min_prob_before_mitosis = track_para.fixation_min_prob_before_mitosis;
min_prob_after_mitosis = track_para.fixation_min_prob_after_mitosis;
if (track_para.if_switch_off_before_mitosis)
    min_prob_before_mitosis = 0.5;
end
if (track_para.if_switch_off_after_mitosis)
    min_prob_after_mitosis = 0.5;
end

% aggregate all track values
num_tracks = length(all_tracks);
num_frames = length(all_tracks{1}.current_id);
all_track_paths = nan(num_frames, num_tracks);
for i=1:num_tracks
    all_track_paths(:,i) = all_tracks{i}.current_id;
end

% extract positions of all ellipses
all_ellipse_positions = cell(num_frames, 1);
for i=1:num_frames
    all_ellipse_positions{i} = cell2mat(all_ellipse_info{i}.all_parametric_para')';
    all_ellipse_positions{i} = all_ellipse_positions{i}(:, 3:4);
    all_ellipse_positions{i}(:,1) = all_ellipse_positions{i}(:,1) + accumulated_jitters(i,2);
    all_ellipse_positions{i}(:,2) = all_ellipse_positions{i}(:,2) + accumulated_jitters(i,1);
end

% cells generated by mitosis
mitosis_exit_event_list = [];
for i=1:num_tracks
    temp = find(cellfun(@length, all_tracks{i}.daughters) > 0);
    if (isempty(temp))
        continue;
    end
    mitosis_exit_event_list = cat(1, mitosis_exit_event_list, [temp+1, all_tracks{i}.daughters{temp}(1); temp+1, all_tracks{i}.daughters{temp}(2)]);
end

% Step 2. find possible instances of missing mitosis
% 1st col: frame (of daughter id), 2nd col: mother/daughter track id, 3rd col: missing daughter track id
missing_mitosis = []; 

% iterate over all frames except for the 1st (otherwise no mother)
for i=2:num_frames
    % find the ellipses with high probabilities of being a mitotic exit
    % cell
    valid_ellipse_id = find(all_morphology_posterior_prob{i}(:, 5) >= min_prob_after_mitosis);
    
    % go over each possible missing daughter cell
    for j=1:length(valid_ellipse_id)
        % this track is newly generated, but not belonging to the mitosis exit list
        curr_ellipse_id = valid_ellipse_id(j);
        curr_track_id = find(all_track_paths(i, :) == curr_ellipse_id);
        if (isempty(curr_track_id) || length(curr_track_id) >= 2) % skip if no track or multiple tracks passes this ellipse 
            continue;
        end
        if (find(~isnan(all_track_paths(:, curr_track_id)), 1, 'first') ~= i || ismember(curr_track_id, mitosis_exit_event_list(:, 2))) % skip if it's not newly born or it's already a mitotic cell
            continue;
        end
        
        % find all candidate daughter cells
        candidate_ellipse_id = find( ...
            abs(all_ellipse_positions{i}(:, 1) - all_ellipse_positions{i}(curr_ellipse_id, 1)) <= threshold_distance & ...
            abs(all_ellipse_positions{i}(:, 2) - all_ellipse_positions{i}(curr_ellipse_id, 2)) <= threshold_distance & ...
            all_morphology_posterior_prob{i}(:, 5) >= min_prob_after_mitosis);
        
        % go over each candidate daughter cell
        valid_info = [];
        for k=1:length(candidate_ellipse_id)
            % find the candidate's track, must not have any special events
            curr_candidate_ellipse_id = candidate_ellipse_id(k);
            curr_candidate_track_id = find(all_track_paths(i, :) == curr_candidate_ellipse_id);
            curr_candidate_mother_ellipse_id = all_track_paths(i-1, curr_candidate_track_id);
            if (isempty(curr_candidate_track_id) || length(curr_candidate_track_id) >= 2 || isnan(curr_candidate_mother_ellipse_id))
                continue;
            end
            
            % the candidate must not be an existing instance
            if (~isempty(missing_mitosis) && ~isempty(find(missing_mitosis(:, 1) == i & missing_mitosis(:, 2) == curr_candidate_track_id, 1)))
                continue;
            end
            
            % mother must have a high probability of being a mitotic cell
            if (all_morphology_posterior_prob{i-1}(curr_candidate_mother_ellipse_id, 4) < min_prob_before_mitosis)
                continue;
            end
            
            % record migration probability to the mother
            valid_info = cat(1, valid_info, [curr_candidate_track_id, all_prob_migration{i}{curr_ellipse_id, 1}(curr_candidate_mother_ellipse_id)]);
        end
        
        % create an instance of missing mitosis
        if (~isempty(valid_info))
            [~, temp] = max(valid_info(:, 2));
            missing_mitosis = cat(1, missing_mitosis, [i, valid_info(temp, 1), curr_track_id]);
        end
    end
end

% Step 3. Create new tracks
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
        'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
for i=1:size(missing_mitosis, 1)
    curr_frame = missing_mitosis(i, 1); track1_id = missing_mitosis(i, 2); track2_id = missing_mitosis(i, 3);
    all_tracks = cat(1, all_tracks, empty_track); new_track_id = length(all_tracks);
    all_tracks = swap_tracks( all_tracks, track1_id, new_track_id, curr_frame );
    all_tracks{track1_id}.daughters{curr_frame-1} = [track2_id, new_track_id];
    
    % change track_to_swap
    missing_mitosis(missing_mitosis(:, 1) > curr_frame & missing_mitosis(:, 2) == track1_id, 2) = new_track_id;
    missing_mitosis(missing_mitosis(:, 1) > curr_frame & missing_mitosis(:, 3) == track1_id, 3) = new_track_id;
end

disp(['Part 3. Find ', num2str(size(missing_mitosis, 1)), ' missing mitoses.']);

%% PART 4. FIXING APOPTOSIS DUE TO PRESENCE OF MULTIPLE CELL TRACKS
% same cell, but two cell tracks co-exist in some frames

% extract track paths
num_tracks = length(all_tracks);
num_frames = length(all_tracks{1}.current_id);
all_track_paths = nan(num_frames, num_tracks);
all_first_id = nan(1, num_tracks);
all_last_id = nan(1, num_tracks);
for i=1:num_tracks
    all_track_paths(:, i) = all_tracks{i}.current_id;
    temp = find(~isnan(all_track_paths(:, i)), 1, 'first');
    if (~isempty(temp))
        all_first_id(i) = temp;
        all_last_id(i) = find(~isnan(all_track_paths(:, i)), 1, 'last');
    end
end

% find mitosis and mitosis exit cell tracks
mitosis_track_id = [];
mitosis_exit_track_id = [];
for i=1:length(all_tracks)
    temp = cell2mat(all_tracks{i}.daughters);
    if (~isempty(temp))
        mitosis_track_id = cat(2, mitosis_track_id, i);
        mitosis_exit_track_id = cat(2, mitosis_exit_track_id, temp);
    end
end

% iteration over everything
track_to_correct = []; % nx4 matrix, track1 id and track2 id, track1 end frame, track2 start frame
valid_track1_id = setdiff(find(isnan(all_track_paths(end, :)) & ~isnan(all_last_id)), mitosis_track_id);
for i1=1:length(valid_track1_id)
    % get track1 info
    track1_id = valid_track1_id(i1);
    track1_first_id = all_first_id(track1_id);
    track1_last_id = all_last_id(track1_id);
    if (~isempty(track_to_correct) && ismember(track1_id, track_to_correct(:, 1)))
        continue;
    end
    
    valid_track2_id = find(isnan(all_track_paths(1, :)) & ~isnan(all_first_id) & all_first_id > track1_first_id & all_last_id > track1_last_id & all_first_id <= track1_last_id );
    valid_track2_id = setdiff(setdiff(valid_track2_id, mitosis_exit_track_id), track1_id); % track2: premature initiation
    for i2=1:length(valid_track2_id)
        track2_id = valid_track2_id(i2);
        track2_first_id = all_first_id(track2_id);
        if (~isempty(track_to_correct) && ismember(track2_id, track_to_correct(:, 2)))
            continue;
        end
        
        % both tracks need to present at track1_end_frame and track2_start_frame
        if (isnan(all_track_paths(track2_first_id, track1_id)) || isnan(all_track_paths(track1_last_id, track2_id)))
            continue;
        end
        
        % check whether both tracks share the same ellipse when overlapping
        temp = all_track_paths(track2_first_id:track1_last_id, track1_id) ~= all_track_paths(track2_first_id:track1_last_id, track2_id) & ...
            ~isnan(all_track_paths(track2_first_id:track1_last_id, track1_id)) & ~isnan(all_track_paths(track2_first_id:track1_last_id, track2_id));
        if (sum(temp) == 0) % do have overlapping, record
            track_to_correct = cat(1, track_to_correct, [track1_id, track2_id, track1_last_id, track2_first_id]);
            break;
        end
    end
end

% perform correction
num_track_to_correct = size(track_to_correct, 1);
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
        'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
for i=1:num_track_to_correct
    track1_id = track_to_correct(i, 1); track1_last_id = track_to_correct(i, 3);
    track2_id = track_to_correct(i, 2); track2_first_id = track_to_correct(i, 4);
    
    % swap data
    all_tracks = swap_tracks( all_tracks, track1_id, track2_id, track1_last_id+1 );
    all_tracks{track1_id}.if_apoptosis(track1_last_id) = 0;
    for j=track2_first_id:track1_last_id
        if (isnan(all_tracks{track1_id}.current_id(j)) && ~isnan(all_tracks{track2_id}.current_id(j))) % get info from track2
            all_tracks{track1_id}.current_id(j) = all_tracks{track2_id}.current_id(j);
        end
    end
    all_tracks{track2_id} = empty_track;
    track_to_correct(track_to_correct(:,1) == track2_id, 1) = track1_id;
end
disp(['Part 4. Fix ', num2str(num_track_to_correct), ' premature termination.']);

%% PART 5. DETERMINE AND REMOVE INVALID TRACKS
% define empty track
empty_track = struct('current_id', {nan(num_frames, 1)}, 'gap_to_previous_id', {nan(num_frames, 1)}, ...
        'gap_to_next_id', {nan(num_frames, 1)}, 'if_apoptosis', {zeros(num_frames, 1)}, 'daughters', {cell(num_frames, 1)});
while 1
    % get genealogy information
    num_tracks = length(all_tracks);
    num_frames = length(all_tracks{1}.current_id);
    genealogy = nan(num_tracks, 1);
    for i=1:num_tracks
        genealogy(cell2mat(all_tracks{i}.daughters)) = i;
    end
    
    % label all tracks not satisfying the requirement
    invalid_track_list = [];
    for i=1:num_tracks
        id_first = find(~isnan(all_tracks{i}.current_id), 1, 'first');
        if (isempty(id_first))
            invalid_track_list = cat(2, invalid_track_list, i);
            continue;
        end
        id_last = find(~isnan(all_tracks{i}.current_id), 1, 'last');
        num_NaN_inbetween = sum(isnan(all_tracks{i}.current_id(id_first:id_last)));
        if (id_last-id_first+1 < track_para.min_track_length || num_NaN_inbetween > track_para.max_num_frames_to_skip)
            if ((isempty(all_tracks{i}.daughters{id_last}) && isnan(genealogy(i))) || (id_first > 1 && id_last < num_frames))
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
    num_tracks = length(all_tracks);
    mitosis_to_remove = []; % nx3 matrix. mitosis frame id, mother track, daughter track
    for i=1:num_tracks
        % re-assign daughter id, remove invalid daughter tracks
        mitosis_frame_id = find(cellfun(@length, all_tracks{i}.daughters) > 0, 1, 'first');
        if (isempty(mitosis_frame_id))
            continue;
        end
        new_daughters_id = [];
        for j=1:2
            new_daughters_id = cat(2, new_daughters_id, find(all_tracks{i}.daughters{mitosis_frame_id}(j) == valid_track_list));
        end
        all_tracks{i}.daughters{mitosis_frame_id} = new_daughters_id;
        
        % if only one daughter cell exists, remove the mitosis event
        if (length(new_daughters_id) == 1)
            mitosis_to_remove = cat(1, mitosis_to_remove, [mitosis_frame_id, i, new_daughters_id]);
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
    
    disp(['Part 5. Remove ', num2str(length(invalid_track_list)), ' invalid tracks.']);
end

% fixing gap_to_previous_id and gap_to_next_id
for i=1:length(all_tracks)
    id = find(~isnan(all_tracks{i}.current_id));
    all_tracks{i}.gap_to_previous_id = nan(num_frames, 1);
    all_tracks{i}.gap_to_next_id = nan(num_frames, 1);
    all_tracks{i}.gap_to_previous_id(id(2:end)) = diff(id);
    all_tracks{i}.gap_to_next_id(id(1:end-1)) = diff(id);
end

%% PART 6. SWITCH TRACK ID FOR EASIER VIEWING
% preparation
num_tracks = length(all_tracks);

while 1
    % Step 1. Change newly born daughters to get consecutive numbers
    old_to_new_mapping = 1:num_tracks;
    for i=1:length(all_tracks)
        daughter_id = sort(cell2mat(all_tracks{i}.daughters));
        if (isempty(daughter_id))
            continue;
        end
        if (daughter_id(2)>daughter_id(1)+1 && old_to_new_mapping(daughter_id(2))==daughter_id(2) && old_to_new_mapping(daughter_id(1)+1)==daughter_id(1)+1) % swap daughter_id(2) with daughter_id(1)+1
            old_to_new_mapping([daughter_id(1)+1, daughter_id(2)]) = old_to_new_mapping([daughter_id(2), daughter_id(1)+1]);
        end
    end
    
    num_swap1 = sum(old_to_new_mapping ~= 1:num_tracks);
    all_tracks = all_tracks(old_to_new_mapping);
    for i=1:length(all_tracks)
        id = find(cellfun(@length, all_tracks{i}.daughters)>0);
        if (isempty(id))
            continue;
        end
        all_tracks{i}.daughters{id} = sort(arrayfun(@(x) find(x==old_to_new_mapping), all_tracks{i}.daughters{id}));
    end
    
    % Step 2. Change the Track ID at first frame according to ellipse positions
    old_to_new_mapping = 1:num_tracks;
    first_frame_info = [];
    for i=1:num_tracks
        if (~isnan(all_tracks{i}.current_id(1)))
            first_frame_info = cat(1, first_frame_info, [i, all_tracks{i}.current_id(1)]);
        end
    end
    
    if (isempty(first_frame_info))
        break;
    end
    
    temp = cell2mat(all_ellipse_info{1}.all_parametric_para')';
    [~, sort_id] = sort(temp(first_frame_info(:, 2), 3));
    old_to_new_mapping(first_frame_info(:, 1)) = old_to_new_mapping(first_frame_info(sort_id, 1));

    num_swap2 = sum(old_to_new_mapping ~= 1:num_tracks);
    all_tracks = all_tracks(old_to_new_mapping);
    for i=1:length(all_tracks)
        id = find(cellfun(@length, all_tracks{i}.daughters)>0);
        if (isempty(id))
            continue;
        end
        all_tracks{i}.daughters{id} = sort(arrayfun(@(x) find(x==old_to_new_mapping), all_tracks{i}.daughters{id}));
    end
    if (num_swap1 + num_swap2 == 0)
        break;
    end
    disp(['Part 6. Switch ', num2str(num_swap1 + num_swap2), ' track IDs for easier viewing.']);
end

%% PART 7. ADDING LABELS
% aggregate all track values
num_tracks = length(all_tracks); 
num_frames = length(all_tracks{1}.current_id);
all_track_paths = nan(num_frames, num_tracks);
for i=1:num_tracks
    all_track_paths(:,i) = all_tracks{i}.current_id;
end

% select the duplicated ones
if_multiple = zeros(1, num_tracks);
for i=1:num_frames
    ellipse_id = all_track_paths(i,:);
    unique_ellipse_id = unique(ellipse_id(~isnan(ellipse_id)));
    duplicated_ellipse_id = unique_ellipse_id(histc(ellipse_id, unique_ellipse_id) > 1);
    if_multiple(ismember(ellipse_id, duplicated_ellipse_id)) = 1;
end

% add label
for i=1:num_tracks
    all_tracks{i}.if_multiple = if_multiple(i);
end

end

function [ ii ] = label_consecutive_numbers( a )
%LABEL_CONSECUTIVE_NUMBERS Assign a unique label for consecutive numbers in
%a vector. Copied from https://se.mathworks.com/matlabcentral/answers/34302-how-to-find-consecutive-numbers
%
%   Input
%       a: input vector, sorted
%   Output
%       ii: unique labels

t = diff(a) == 1;
y = [t,false];
x = xor(y,[false,t]);
ii = cumsum(~(x|y) + y.*x);

end

function [ all_tracks ] = swap_tracks( all_tracks, track1_id, track2_id, frame_id )
%SWAP_TRACKS Swap the contents of two tracks from a specified frame
%
%   Input
%   all_tracks: tracks before swapping
%       track1_id: id of the first track
%       track2_id: id of the second track
%       frame_id: swapping point
%   Output
%   all_tracks: tracks after swapping

% swap the content from frame_id
temp = all_tracks{track1_id};
all_tracks{track1_id}.current_id(frame_id:end) = all_tracks{track2_id}.current_id(frame_id:end);
all_tracks{track1_id}.gap_to_previous_id(frame_id:end) = all_tracks{track2_id}.gap_to_previous_id(frame_id:end);
all_tracks{track1_id}.gap_to_next_id(frame_id:end) = all_tracks{track2_id}.gap_to_next_id(frame_id:end);
all_tracks{track1_id}.if_apoptosis(frame_id:end) = all_tracks{track2_id}.if_apoptosis(frame_id:end);
all_tracks{track1_id}.daughters(frame_id:end) = all_tracks{track2_id}.daughters(frame_id:end);

all_tracks{track2_id}.current_id(frame_id:end) = temp.current_id(frame_id:end);
all_tracks{track2_id}.gap_to_previous_id(frame_id:end) = temp.gap_to_previous_id(frame_id:end);
all_tracks{track2_id}.gap_to_next_id(frame_id:end) = temp.gap_to_next_id(frame_id:end);
all_tracks{track2_id}.if_apoptosis(frame_id:end) = temp.if_apoptosis(frame_id:end);
all_tracks{track2_id}.daughters(frame_id:end) = temp.daughters(frame_id:end);

end

function [ score ] = convert_probability_to_score( prob )
%COMVERT_PROBABILITY_TO_SCORE Convert a probability to a score
%
%   Input
%       prob: probability
%   Output
%       score: converted score

score = log(prob) - log(1-prob);

end