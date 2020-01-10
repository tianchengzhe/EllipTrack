function [ dist_x, dist_y, dist_t, axis_id ] = aggr_training_data( all_training_data, option, size_image, max_migration_dist_fold )
%AGGR_TRAINING_DATA Aggregate motion training data to infer migration sigma
%
%   Input
%       all_training_data: Training data
%       option: Whether to sort by time or density
%       size_image: Dimension of images
%       max_migration_dist_fold: Max migration distance
%   Output
%       dist_x: Migration distance in x direction
%       dist_y: Migration distance in y direction
%       dist_t: Migration time (Frames)
%       axis_id: Time or density id

% extract dist_x, dist_y, and dist_t
dist_x = []; dist_y = []; dist_t = []; 
for i=1:length(all_training_data)
    dist_x = cat(1, dist_x, cat(1, all_training_data{i}.motion_distances.dist_x));
    dist_y = cat(1, dist_y, cat(1, all_training_data{i}.motion_distances.dist_y));
    dist_t = cat(1, dist_t, cat(1, all_training_data{i}.motion_distances.dist_t));
end

% calculate axis_id
switch lower(option)
    case 'global' % not sort
        axis_id = zeros(size(dist_x));
        
    case 'time' % sort by time
        axis_id = [];
        for i=1:length(all_training_data)
            temp = cat(2, all_training_data{i}.motion_training_info.source_frame);
            axis_id = cat(1, axis_id, all_training_data{i}.imported_frame_id(temp(1, 1:length(all_training_data{i}.motion_distances)))');
        end
        
    case 'density' % sort by cell density
        % first infer global sigma
        global_sigma = infer_migration_sigma(dist_x, dist_y, dist_t, size_image);
        threshold_distance = global_sigma * max_migration_dist_fold;

        % count number of cells within the threshold distance
        axis_id = [];
        for i=1:length(all_training_data)
            temp = nan(length(all_training_data{i}.motion_distances), 1);
            for j=1:length(all_training_data{i}.motion_distances)
                % count number of cells within the square
                frame_id = all_training_data{i}.motion_training_info(j).source_frame(1);
                cell_pos = all_training_data{i}.ellipse_positions{frame_id}(all_training_data{i}.motion_training_info(j).source_id(1), :);
                if (cell_pos(1)+threshold_distance > size_image(2) || cell_pos(1)-threshold_distance <= 0 || ...
                        cell_pos(2)+threshold_distance > size_image(1) || cell_pos(2)-threshold_distance <= 0)
                    continue;
                end
                temp(j) = sum(abs(all_training_data{i}.ellipse_positions{frame_id}(:,1) - cell_pos(1)) <= threshold_distance & ...
                    abs(all_training_data{i}.ellipse_positions{frame_id}(:,2) - cell_pos(2)) <= threshold_distance);
            end
            axis_id = cat(1, axis_id, temp);
        end
        id = find(~isnan(axis_id));
        dist_x = dist_x(id); dist_y = dist_y(id); dist_t = dist_t(id); axis_id = axis_id(id);
        
    otherwise
        error('aggr_training_data: Unknown option.');
end

end