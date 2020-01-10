function [ all_track_paths, num_tracks, num_frames, option_output ] = get_track_paths( all_tracks, option )
%GET_TRACK_PATHS Get track paths in the matrix form
%
%   Input
%       all_tracks: Cell tracks
%       option: Control parameter for further calculation 
%   Output
%       all_track_path: Track path in the matrix form
%       num_tracks: Number of cell tracks
%       num_frames: Movie length
%       option_output: Output of option

% aggregate track paths
num_tracks = length(all_tracks);
num_frames = length(all_tracks{1}.current_id);
all_track_paths = nan(num_frames, num_tracks);
for i=1:num_tracks
    all_track_paths(:, i) = all_tracks{i}.current_id;
end

% calculate additional information
switch lower(option)
    case 'none'
        option_output = [];
        return;
    case 'shared_ellipse' 
        % option_output: For each track at each frame, record the track ID
        % that shares the same ellipse. Use 0 if not sharing. NaN if track
        % is not present.
        option_output = nan(num_frames, num_tracks);
        for i=1:num_frames
            ellipse_id = all_track_paths(i, :); unique_ellipse_id = unique(ellipse_id(~isnan(ellipse_id)));
            duplicated_ellipse_id = unique_ellipse_id(histc(ellipse_id, unique_ellipse_id) > 1);
            for j=1:num_tracks
                if isnan(ellipse_id(j)) % track is not present -> NaN
                    continue;
                elseif ismember(ellipse_id(j), duplicated_ellipse_id)
                    option_output(i, j) = setdiff(find(ellipse_id == ellipse_id(j)), j);
                else % not duplicated -> 0
                    option_output(i, j) = 0;
                end
            end
        end
        return;
    case 'firstlast'
        % option_output: nx2 matrix. Each row: First and last frame IDs.
        first_frame_id = nan(num_tracks, 1);
        last_frame_id = nan(num_tracks, 1);
        for i=1:num_tracks
            first_frame_id(i) = find(~isnan(all_track_paths(:, i)), 1, 'first');
            last_frame_id(i) = find(~isnan(all_track_paths(:, i)), 1, 'last');
        end
        option_output = [first_frame_id, last_frame_id];
        return;
    case 'genealogy'
        % option_output: nx1 array. Daughter to mother mapping
        option_output = nan(num_tracks, 1);
        for i=1:num_tracks
            option_output(cell2mat(all_tracks{i}.daughters)) = i;
        end
        return;
    otherwise
        error('get_track_paths: Unknown option.');
end

end