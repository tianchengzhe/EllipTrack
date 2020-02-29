function [ all_migration_sigma ] = compute_migration_sigma( prob_para, all_training_data, all_num_ellipses, all_ellipse_info, size_image, frames_to_track )
%COMPUTE_MIGRATION_SIGMA Compute the standard deviation of migration for
%each ellipse.
%
%   Input
%       prob_para: Parameters for prediction
%       all_num_ellipses: Number of ellipses in each frame
%       all_training_data: Training data
%       all_ellipse_info: Segmentation results
%       size_image: Dimension of images
%       frames_to_track: Frames to track
%   Output
%       all_migration_sigma: Standard deviation of random walk in one
%       direction and one frame

% preparation of data strucutre
num_frames = length(all_num_ellipses);
all_migration_sigma = cell(num_frames, 1);
training_data_size_image = all_training_data{1}.size_image; % dim may be different in training vs actual images

% fill in all_migration_sigma
if isnumeric(prob_para.migration_speed) % provided sigma value
    if (prob_para.migration_speed <= 0)
        error('compute_migration_sigma: Invalid user-provided migration_sigma. Should be a positive value.');
    end
    for i=1:num_frames
        all_migration_sigma{i} = prob_para.migration_speed * ones(all_num_ellipses(i), 1);
    end
else
    switch lower(prob_para.migration_speed)
        case 'global' % not sorted
            [ dist_x, dist_y, dist_t ] = aggr_training_data( all_training_data, 'global', training_data_size_image, prob_para.max_migration_dist_fold );
            global_sigma = infer_migration_sigma( dist_x, dist_y, dist_t, training_data_size_image );
            for i=1:num_frames
                all_migration_sigma{i} = global_sigma * ones(all_num_ellipses(i), 1);
            end
            
        case 'time' % sort by time
            [ dist_x, dist_y, dist_t, axis_id ] = aggr_training_data( all_training_data, 'time', training_data_size_image, prob_para.max_migration_dist_fold );
            sigma_val = infer_migration_sigma_axis( dist_x, dist_y, dist_t, axis_id, frames_to_track, training_data_size_image, prob_para.migration_inference_resolution, prob_para.migration_inference_min_samples );
            for i=1:num_frames
                all_migration_sigma{i} = sigma_val(i) * ones(all_num_ellipses(i), 1);
            end
            
        case 'density' % sort by density
            [ dist_x, dist_y, dist_t, axis_id ] = aggr_training_data( all_training_data, 'density', training_data_size_image, prob_para.max_migration_dist_fold );
            density_val = 1:ceil(max(axis_id));
            sigma_val = infer_migration_sigma_axis( dist_x, dist_y, dist_t, axis_id, density_val, training_data_size_image, prob_para.migration_inference_resolution, prob_para.migration_inference_min_samples );
            global_sigma = infer_migration_sigma( dist_x, dist_y, dist_t, training_data_size_image );
            threshold_distance = global_sigma * prob_para.max_migration_dist_fold;
            for i=1:num_frames
                % get ellipse positions in the frame
                all_ellipse_positions = cell2mat(all_ellipse_info{i}.all_parametric_para')';
                all_ellipse_positions = all_ellipse_positions(:, 3:4);
                all_ellipse_positions(:,1) = min(max(all_ellipse_positions(:,1), 1), size_image(2));
                all_ellipse_positions(:,2) = min(max(all_ellipse_positions(:,2), 1), size_image(1));
                
                % calculate density for every cell
                all_migration_sigma{i} = nan(all_num_ellipses(i), 1);
                for j=1:all_num_ellipses(i)
                    cell_pos = all_ellipse_positions(j, :);
                    num_cells = sum(abs(all_ellipse_positions(:, 1)-cell_pos(1)) <= threshold_distance & ...
                        abs(all_ellipse_positions(:, 2)-cell_pos(2)) <= threshold_distance);
                    area_coef = (min(cell_pos(1)+threshold_distance, size_image(2))-max(cell_pos(1)-threshold_distance, 1)) * ...
                    (min(cell_pos(2)+threshold_distance, size_image(1))-max(cell_pos(2)-threshold_distance, 1))/4/threshold_distance/threshold_distance;
                    num_cells = min(max(round(num_cells/area_coef), min(density_val)), max(density_val));
                    all_migration_sigma{i}(j) = sigma_val(density_val==num_cells);
                end
            end
            
        otherwise
            error('compute_migration_sigma: Unknown option');
    end
end

end