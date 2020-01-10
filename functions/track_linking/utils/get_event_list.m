function [ mitosis_list, mitosis_exit_list, apoptosis_moveout_list, movein_list ] = get_event_list( all_tracks, all_track_paths )
%GET_EVENT_LIST Obtain information of special events. All outputs are nx2
%matrices. Each row represents an instance of one event. Column 1: Frame
%ID. Column 2: Track ID.
%
%   Input
%       all_tracks: Cell track
%       all_track_paths: Track path in the matrix form
%   Output
%       mitosis_list: Information of mitotic cells
%       mitosis_exit_list: Information of newly born cells.
%       apoptosis_moveout_list: Information of apoptotic/move-out cells
%       movein_list: Information of move-in cells

mitosis_list = []; mitosis_exit_list = [];
apoptosis_moveout_list = []; movein_list = [];
num_tracks = length(all_tracks); 
if (num_tracks == 0)
    error('get_event_list: no tracks available.');
end
num_frames = length(all_tracks{1}.current_id);

% mitosis and mitosis exit
for i=1:num_tracks
    mitosis_time = find(cellfun(@length, all_tracks{i}.daughters)>0, 1);
    if (isempty(mitosis_time)) % no mitosis
        continue;
    end
    mitosis_list = cat(1, mitosis_list, [mitosis_time, i]);
    mitosis_exit_list = cat(1, mitosis_exit_list, [mitosis_time+1, all_tracks{i}.daughters{mitosis_time}(1); mitosis_time+1, all_tracks{i}.daughters{mitosis_time}(2)]);
end

% apoptosis/move-out, move-in
for i=1:num_tracks 
    last_id = find(~isnan(all_track_paths(:, i)), 1, 'last');
    if (~isempty(last_id) && last_id < num_frames && (isempty(mitosis_list) || ~ismember(i, mitosis_list(:, 2))))
        apoptosis_moveout_list = cat(1, apoptosis_moveout_list, [last_id, i]);
    end

    first_id = find(~isnan(all_track_paths(:, i)), 1, 'first');
    if (~isempty(first_id) && first_id > 1 && (isempty(mitosis_exit_list) || ~ismember(i, mitosis_exit_list(:, 2))))
        movein_list = cat(1, movein_list, [first_id, i]);
    end
end
    
end