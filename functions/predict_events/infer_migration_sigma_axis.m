function [ sigma_val, errmsg ] = infer_migration_sigma_axis( dist_x, dist_y, dist_t, axis_id, inferred_axis_id, size_image, migration_inference_resolution, migration_inference_min_samples )
%INFER_MIGRATION_SIGMA_AXIS Infer migration sigma if training data is
%sorted by time or density
%
%   Input
%       dist_x: Migration distances in x direction
%       dist_y: Migration distances in y direction
%       dist_t: Migration time (in frames)
%       axis_id: Time/Density value
%       inferred_axis_id: Time/Density points to infer
%       size_image: Dimension of the image
%       migration_inference_resolution: Resolution of inference
%       migration_inference_min_samples: Minimal number of samples for
%       inference
%   Output
%       sigma_val: Inferred standard deviation of random walk at each axis
%       errmsg: Error Message

% calculate sigma at every frame
sigma_val = nan(length(inferred_axis_id), 1);
trained_axis_id = sort(unique(round(axis_id)));
for i=1:length(inferred_axis_id)
    if (~ismember(inferred_axis_id(i), trained_axis_id))
        continue;
    end
    
    id = find(axis_id >= inferred_axis_id(i)-migration_inference_resolution & ...
        axis_id <= inferred_axis_id(i)+migration_inference_resolution);
    if (length(id) >= migration_inference_min_samples)
        sigma_val(i) = infer_migration_sigma(dist_x(id), dist_y(id), dist_t(id), size_image);
    end
end
if (all(isnan(sigma_val)) || any(sigma_val <= 0))
    errmsg = 'infer_migration_sigma_axis: Inference failed. Use the default value of 10.'; 
    warning(errmsg);
    sigma_val(:) = 10;
    return;
end

% fill in beginning and end NaNs
first_id = find(~isnan(sigma_val), 1, 'first'); sigma_val(1:first_id-1) = sigma_val(first_id);
last_id = find(~isnan(sigma_val), 1, 'last'); sigma_val(last_id+1:end) = sigma_val(last_id);

% linearly interpolate intermediate NaN values
sigma_val(isnan(sigma_val)) = interp1(inferred_axis_id(~isnan(sigma_val)), sigma_val(~isnan(sigma_val)), inferred_axis_id(isnan(sigma_val)));
errmsg = '';

end