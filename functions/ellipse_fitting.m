function [ all_cartesian_para, all_parametric_para, all_boundary_points, all_internal_points ] = ellipse_fitting ( size_image, contourevidence, ellipse_para )
%ELLIPSE_FITTING Fitting ellipses to contours and partition overlapping
%ellipses
%   Ellipse fitting code is modified from mia_estimatecontour_lsf in the
%   MIA_ISVA method.
%   Input
%       size_image: size of the nuclear image
%       contourevidence: contour evidences, output from the last step
%       ellipse_para: Parameters for ellipse fitting
%   Output
%       all_cartesian_para: parameter values of the ellipse in cartesian
%       coordinate. In drawing coordinate order
%       all_parametric_para: parameter values of the ellipse in parameteric
%       coordinate. In drawing coordinate order
%       all_boundary_points: boundary points (in image coordinate order)
%       for drawing. Not necessarily integer
%       all_internal_points: internal points of the ellipse, in image
%       coordinate order

% Fit every contourevidence to ellipses and record good ones
max_cells_per_frame = 1000;
all_cartesian_para = cell(max_cells_per_frame, 1); % a(1)x^2 + a(2)xy + a(3)y^2 + a(4)x + a(5)y + a(6) = 0
all_parametric_para = cell(max_cells_per_frame, 1); % [r1 r2 cx cy theta] in ((x-cx)/r1)^2 + ((y-cy)/r2)^2 = 1
all_boundary_points = cell(max_cells_per_frame, 1); % boundary points of the ellipse
all_internal_points = cell(max_cells_per_frame, 1); % all points within the ellipse
curr_ellipse = 0; % counter for saving new ellipse
for i=1:length(contourevidence)
    contour_x = contourevidence{i}(:,2);
    contour_y = contourevidence{i}(:,1);
    if (length(contour_x) >= ellipse_para.min_ellipse_perimeter)
        % fit to ellipse and compute the parameters in two coordinates
        a = mia_fitellip_lsf(contour_x,contour_y);
        if (any(imag(a)~=0) || isempty(a) || any(isnan(a)))
            continue;
        end
        v = mia_solveellipse_lsf(a);
        if (isempty(v))
            continue;
        end
        % compute the boundary points
        [X,Y]=mia_drawellip_lsf(v);
        
        if (length(X) > 1 && (pi*v(1)*v(2) >= ellipse_para.min_ellipse_area) && max(v(1:2)) <= ellipse_para.max_major_axis && 4*norm(v(1:2)) >= ellipse_para.min_ellipse_perimeter)
            % save data
            curr_ellipse = curr_ellipse + 1;
            all_cartesian_para{curr_ellipse} = a;
            all_parametric_para{curr_ellipse} = v;
            all_boundary_points{curr_ellipse} = [Y', X']; % note that this is image order! opposite to drawing order!
            
            % examine all the bounding boxes to see which id is within the
            % ellipse
            cand_X = min(floor(Y)):max(ceil(Y)); cand_Y = min(floor(X)):max(ceil(X)); % get the range of pixels under consideration. Note that this is opposite to drawing order!
            cand_X = intersect(cand_X, 1:size_image(1)); cand_Y = intersect(cand_Y, 1:size_image(2));
            all_combn = allcomb(cand_X, cand_Y);
            in = inpolygon(all_combn(:,1), all_combn(:,2), [Y'; Y(1)], [X'; X(1)]);
            all_internal_points{curr_ellipse} = all_combn(in, :);
            
        end
    end
end

% remove empty entries
all_cartesian_para = all_cartesian_para(~cellfun(@isempty, all_cartesian_para));
all_parametric_para = all_parametric_para(~cellfun(@isempty, all_parametric_para));
all_boundary_points = all_boundary_points(~cellfun(@isempty, all_boundary_points));
all_internal_points = all_internal_points(~cellfun(@isempty, all_internal_points));

end

