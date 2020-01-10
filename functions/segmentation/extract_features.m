function [ all_features, invalid_entry ] = extract_features( image, all_parametric_para, all_boundary_points, all_internal_points )
%EXTRACT_FEATURES Extract features from all ellipses in an image
%   Input
%       image: image of the nuclear channel
%       all_parametric_para: parametric coordinates of all ellipses
%       all_boundary_points: boundary points (not pixel coordinates) of all
%       ellipses
%       all_internal_points: interal points (pixel coordinates) of all
%       ellipses
%   Output
%       all_features: features of ellipses
%       invalid_entry: IDs of ellipses with invalid feature valeus

% compute for every ellipse
num_ellipses = length(all_parametric_para);
all_features = cell(num_ellipses, 1);
invalid_entry = zeros(num_ellipses, 1);
for i=1:num_ellipses
    
    features = zeros(26, 1);
    
    % geometry-based features
    curr_parametric_para = all_parametric_para{i};
    features(1) = pi*curr_parametric_para(1)*curr_parametric_para(2); % area
    features(2) = max(curr_parametric_para(1:2)); % major axis
    features(3) = min(curr_parametric_para(1:2)); % minor axis
    features(4) = sqrt(features(2)^2-features(3)^2)/features(2); % eccentricity
    features(5) = sqrt(curr_parametric_para(1)*curr_parametric_para(2)); % equivalent radius
    features(6) = 2*pi*sqrt((features(2)^2+features(3)^2)/2); % approximated perimeter
    features(7) = features(2)*features(3)/sqrt(features(2)^2+features(3)^2);

    % internal intensity-based features
    curr_internal_pixels = all_internal_points{i};
    curr_internal_intensities = image(sub2ind(size(image), curr_internal_pixels(:,1), curr_internal_pixels(:,2)));
    curr_internal_intensities = curr_internal_intensities(~isnan(curr_internal_intensities));
    features(8) = mean(curr_internal_intensities); % mean intensity of nucleus
    features(9) = std(curr_internal_intensities); % std intensities of nucleus
    features(10) = kurtosis(curr_internal_intensities); % 3rd central moment
    features(11) = median(curr_internal_intensities); % median intensity
    features(12) = quantile(curr_internal_intensities, 0.75); % 75% percentile intensity

    % boundary intensity-based features
    curr_boundary_pixels = round(all_boundary_points{i});
    id = find(curr_boundary_pixels(:,1) >= 1 & curr_boundary_pixels(:,1) <= size(image, 1) &...
        curr_boundary_pixels(:,2) >= 1 & curr_boundary_pixels(:,2) <= size(image, 2));
    curr_boundary_pixels = unique(sub2ind(size(image), curr_boundary_pixels(id,1), curr_boundary_pixels(id,2)));
    curr_boundary_intensities = image(curr_boundary_pixels);
    curr_boundary_intensities = curr_boundary_intensities(~isnan(curr_boundary_intensities));
    features(13) = mean(curr_boundary_intensities); % mean of boundary intensities
    features(14) = std(curr_boundary_intensities); % std of boundary intensities
    features(15) = median(curr_boundary_intensities); % median of boundary intensities
    features(16) = features(8) / features(13); % ratio of internal to boundary mean intensities
    features(17) = (features(8) - features(13)) ./ features(5); % approximate gradient

    % center intensity-based features
    center_pixel = round(curr_parametric_para(3:4));
    center_pixel(1) = min(max(center_pixel(1), 1), size(image, 2));
    center_pixel(2) = min(max(center_pixel(2), 1), size(image, 1));
    center_intensity = image(center_pixel(2), center_pixel(1));
    features(18) = center_intensity; % intensity of the center point
    features(19) = features(18) / features(13); % ratio of center to boundary mean
    features(20) = (features(18) - features(13)) ./ features(5); % approximate gradient
    features(21) = features(18) / features(8); % ratio of center to internal mean
    features(22) = (features(18) - features(8)) ./ features(5); % approximate gradient

    % features based on ratios, nuclear intensities
    features(23) = features(9) ./ features(8); % std over mean
    features(24) = features(10) ./ features(8); % 3rd central moment over mean
    features(25) = features(11) ./ features(8); % median over mean
    features(26) = features(12) ./ features(8); % 75% over mean
    
    % remove unreasonable values
    features(isinf(features)) = NaN;
    features(imag(features)~=0) = NaN;
    if any(isnan(features))
        invalid_entry(i) = 1;
    end
    
    % put into cell array
    all_features{i} = features;
end

end
