function [ inferred_sigma ] = infer_migration_sigma(dist_x, dist_y, dist_t, size_image)
%INFER_MIGRATION_SIGMA Infer standard deviation of random walk based on
%training data
%
%   Input
%       dist_x: Migration distance in x direction
%       dist_y: Migration distance in y direction
%       dist_t: Migration time (in frames)
%       size_image: Dimension of images
%   Output
%       inferred_sigma: Inferred standard deviation of random walk in one
%       direction and one frame

all_distances = [dist_x; dist_y]; all_times = [dist_t; dist_t];
f = @(x) -sum(log(normpdf(all_distances, 0, x*sqrt(all_times))));
inferred_sigma = fminbnd(f, 0, min(size_image));

end