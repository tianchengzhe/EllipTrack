function [ ellipse_info, id_no_cell, id_two_cells ] = seg_correction( image, mask, ellipse_info, morphology_training_features, morphology_training_labels, segmentation_para )
%SEG_CORRECTION Correcting segmentation mistakes with training datasets
%
%   Input
%       image: Image of the nuclear channel
%       mask: Mask used to do ellipse fitting
%       ellipse_info: Existing information about ellipses
%       morphology_training_features: Features of training data
%       morphology_training_labels: Labels of training data
%       segmentation_para: Parameters for segmentation
%   Output
%       ellipse_info: Ellipses after correction
%       id_no_cell: Original ID containing no cell
%       id_two_cell: Original ID containing two cells

% compute the probability
cell_count_prob = classify_num_cells_per_ellipse(morphology_training_features, morphology_training_labels, {ellipse_info});
cell_count_prob = cell_count_prob{1};

% filter out list of id
id_no_cell = find(cell_count_prob(:,1) >= segmentation_para.seg_correction_para.min_corr_prob);
id_two_cells = find(cell_count_prob(:,3) >= segmentation_para.seg_correction_para.min_corr_prob);

% analyze every ellipse
size_image = size(image);
failed_id = [];
for i=1:length(id_two_cells)
    % get indices for the current ellipses
    curr_ellipse_id = id_two_cells(i);
    temp = false(size_image);
    temp(sub2ind(size_image, ellipse_info.all_internal_points{curr_ellipse_id}(:,1), ellipse_info.all_internal_points{curr_ellipse_id}(:,2))) = true;
    temp = temp & mask; temp = find(temp(:));
    
    % exclude cases where the number of pixels for the detection is too
    % small
    if (length(temp) < segmentation_para.nonspecific_para.allowed_ellipse_size(1)*2)
        failed_id = cat(2, failed_id, curr_ellipse_id);
        continue;
    end
    [ind_x, ind_y] = ind2sub(size_image, temp);
    
    % perform k-means clustering
    ind_decision = kmeans([ind_x, ind_y], 2, 'Replicates', 5);
    
    % run twice just to see whether the kmeans result is consistent
    ind_decision2 = kmeans([ind_x, ind_y], 2, 'Replicates', 5);
    if (sum(ind_decision ~= ind_decision2)/length(ind_decision) > 0.1)
        warning(['Two runs of K-Means on ellipse No. ', num2str(curr_ellipse_id), ' show inconsistent results. Will not partition this ellipse.']);
        failed_id = cat(2, failed_id, curr_ellipse_id);
        continue;
    end
    
    % create the first and second ellipses
    try
        nuc_sub1 = [ind_x(ind_decision == 1), ind_y(ind_decision == 1)];
        new_ellipse_info1 = create_new_ellipse(nuc_sub1, image, segmentation_para);
        
        nuc_sub2 = [ind_x(ind_decision == 2), ind_y(ind_decision == 2)];
        new_ellipse_info2 = create_new_ellipse(nuc_sub2, image, segmentation_para);
    catch
        warning(['Failed to partition ellipse No. ', num2str(curr_ellipse_id), '. Will not partition this ellipse.']);
        failed_id = cat(2, failed_id, curr_ellipse_id);
        continue;
    end
    
    % assign values
    ellipse_info.all_cartesian_para{end+1} = new_ellipse_info1.all_cartesian_para{1};
    ellipse_info.all_parametric_para{end+1} = new_ellipse_info1.all_parametric_para{1};
    ellipse_info.all_boundary_points{end+1} = new_ellipse_info1.all_boundary_points{1};
    ellipse_info.all_internal_points{end+1} = new_ellipse_info1.all_internal_points{1};
    ellipse_info.all_features{end+1} = new_ellipse_info1.all_features{1};
    
    ellipse_info.all_cartesian_para{end+1} = new_ellipse_info2.all_cartesian_para{1};
    ellipse_info.all_parametric_para{end+1} = new_ellipse_info2.all_parametric_para{1};
    ellipse_info.all_boundary_points{end+1} = new_ellipse_info2.all_boundary_points{1};
    ellipse_info.all_internal_points{end+1} = new_ellipse_info2.all_internal_points{1};
    ellipse_info.all_features{end+1} = new_ellipse_info2.all_features{1};
end
id_two_cells = setdiff(id_two_cells, failed_id);

% remove duplicated terms
num_entries = size(ellipse_info.all_cartesian_para, 1);
selected_entries = setdiff(setdiff(1:num_entries, id_no_cell), id_two_cells);
ellipse_info.all_cartesian_para = ellipse_info.all_cartesian_para(selected_entries);
ellipse_info.all_parametric_para = ellipse_info.all_parametric_para(selected_entries);
ellipse_info.all_boundary_points = ellipse_info.all_boundary_points(selected_entries);
ellipse_info.all_internal_points = ellipse_info.all_internal_points(selected_entries);
ellipse_info.all_features = ellipse_info.all_features(selected_entries);

end

function [ ellipse_info ] = create_new_ellipse ( nuc_subs, image, segmentation_para )
%CREATE_NEW_ELLIPSE Create a new ellipse after partitioning old ellipses
%
%   Input
%       nuc_subs: subscripts of the new ellipse
%       image: source image
%       segmentation_para: parameters for segmentation
%   Output
%       ellipse_info: produced ellipse_info struct for the new ellipse

% create a mask
size_image = size(image);
mask = false(size_image); mask(sub2ind(size_image, nuc_subs(:,1), nuc_subs(:,2))) = true;

% ellipse fitting
contourevidence = mia_cmpcontourevidence( mask, segmentation_para );
[ all_cartesian_para, all_parametric_para, all_boundary_points, all_internal_points ] = ellipse_fitting( size_image, contourevidence, segmentation_para );
    
% compute features
[ all_features, if_invalid ] = extract_features( image, all_parametric_para, all_boundary_points, all_internal_points );
if (if_invalid)
    error('');
end
ellipse_info = struct('all_cartesian_para', {all_cartesian_para}, 'all_parametric_para', {all_parametric_para}, 'all_boundary_points', {all_boundary_points}, ...
    'all_internal_points', {all_internal_points}, 'all_features', {all_features});

end