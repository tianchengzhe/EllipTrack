function [ global_jitters, parameters ] = compute_global_jitter( local_jitters )
%COMPUTE_GLOBAL_JITTER Compute the plate motion (global jitter)
%
%   Input
%       local_jitters: Image mismatch between neighboring frames
%   Output
%       global_jitters: Plate motion
%       parameters: 1x5 vector, stores (\Delta x, \Delta y,
%       \theta, h, v), which satisfy the following equations
%   Before: (x_{i,j}, y_{i,j}) = (x_{1,1}, y_{1,1}) + ((j-1)h, -(i-1)v)
%   After: (x'_{i,j}, y'_{i,j}) = (x'_{1,1}, y'_{1,1}) + R((j-1)h, -(i-1)v)
%       where R=[cos(\theta), -sin(\theta); sin(\theta), cos(\theta)] is
%       the rotation matrix.
%   Difference: (\Delta x_{i,j}, \Delta y_{i,j}) = (\Delta x, \Delta y) + 
%       (R-I) ((j-1)h, -(i-1)v)
%       where (\Delta x, \Delta y, \theta, h, v) are treated as
%       unknown variable, and (\Delta x_{i,j}, \Delta y_{i,j}) are
%       observables

% set up initial parameters
para0 = [ 0, 0, 0, 1000, 1000 ];
upper_bound = [ 1000, 1000, pi, Inf, Inf ];
lower_bound = [ -1000, -1000, -pi, -Inf, -Inf ];
opt = optimset('MaxFunEvals', 1e6, 'MaxIter', 1e6, 'TolFun', 1e-6, 'TolX', 1e-6, 'Display', 'off');
parameters = fmincon(@err_fitting_jitters, para0, [], [], [], [], lower_bound, upper_bound, [], opt, local_jitters);
[ ~, global_jitters ] = err_fitting_jitters( parameters, local_jitters );
global_jitters = round(global_jitters);

end

function [ err, computed_jitters ] = err_fitting_jitters( para, local_jitters )

% extract parameter values
delta_x = para(1); delta_y = para(2);
theta = para(3); R_minus_I = [cos(theta)-1, -sin(theta); sin(theta), cos(theta)-1];
h = para(4); v = para(5);

% compute predicted jitters
n_row = size(local_jitters, 1);
n_col = size(local_jitters, 2);
computed_jitters = nan(size(local_jitters));
all_x_shifts = (0:n_col-1)*h;
all_y_shifts = -(0:n_row-1)*v;
all_pair_shifts = allcomb(all_y_shifts, all_x_shifts)'; 
all_pair_shifts = all_pair_shifts([2, 1], :); % for every y, iterate over all x; then for next y, etc.
rotated_pair_shifts = R_minus_I * all_pair_shifts;
computed_jitters(:,:,1) = reshape(rotated_pair_shifts(1,:), n_col, n_row)' + delta_x;
computed_jitters(:,:,2) = reshape(rotated_pair_shifts(2,:), n_col, n_row)' + delta_y;

% compute difference between predicted and local jitters
temp = local_jitters(:) - computed_jitters(:);
temp = temp(~isnan(temp));
err = norm(temp);

end
