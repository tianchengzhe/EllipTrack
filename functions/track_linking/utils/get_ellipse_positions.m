function [ all_ellipse_positions, option_output ] = get_ellipse_positions( num_frames, all_ellipse_info, accumulated_jitters, option )
%GET_ELLIPSE_POSITIONS Get positions of ellipse centroids. Jitter adjusted.
%
%   Input
%       num_frames: Movie length
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first frame
%       option: Control parameter
%   Output
%       all_ellipse_positions: Position of ellipse centroids
%       option_output: Output for option

all_ellipse_positions = cell(num_frames, 1);
for i=1:num_frames
    all_ellipse_positions{i} = cell2mat(all_ellipse_info{i}.all_parametric_para')';
    all_ellipse_positions{i} = all_ellipse_positions{i}(:, 3:4);
    all_ellipse_positions{i}(:,1) = all_ellipse_positions{i}(:,1) + accumulated_jitters(i,2);
    all_ellipse_positions{i}(:,2) = all_ellipse_positions{i}(:,2) + accumulated_jitters(i,1);
end

switch lower(option)
    case 'none'
        option_output = [];
        return;
    case 'area'
        % option_output: Store nuclear area. 
        option_output = cell(num_frames, 1);
        for i=1:num_frames
            temp = cell2mat(all_ellipse_info{i}.all_parametric_para')';
            option_output{i} = temp(:, 1).*temp(:, 2) * pi;
        end
        return;
    case 'closest_ellipse'
        % option_output: Store ID of the closest ellipse in the same frame
        option_output = cell(num_frames, 1);
        for i=1:num_frames
            curr_dist = squareform(pdist(all_ellipse_positions{i}));
            curr_dist(1:size(curr_dist,1)+1:end) = Inf;
            [~, option_output{i}] = min(curr_dist);
        end
        return;
    otherwise
        error('get_ellipse_positions: unknown option.');
end

end