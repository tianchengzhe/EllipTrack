function [ mask_watershed ] = run_watershed( mask, segmentation_para )
%ADAPTIVE_WATERSHED Separating overlapping cells using watershed
%   Modification of Cappell et al 2016, by introducing adaptative image
%   erosion
%
%   Input:
%       mask: original mask
%       segmentation_para: Parameters for watershed
%   Output:
%       mask_watershed: mask after watershed
%

% for original image, compute the distance of this pixel to the closest
% background pixel
valleys = -bwdist(~mask); % negative distance from foreground to bg
big_valleys = bwdist(mask); % positive distance from bg to foreground
outer_ridges=watershed(big_valleys); outer_ridges=outer_ridges==0; % compute the boundaries between objects with watershed algorithm

% erode the image recursively to compute basins (or marker for every
% nucleus)
final_basins = false(size(mask));
curr_basins = mask;
num_iteration = segmentation_para.nonspecific_para.nuc_radius * 2;
for i=1:num_iteration
    % erode image once
    curr_basins = imerode(curr_basins, strel('disk', 1, 0));
    
    % find components with area smaller than the threshold
    after_removal = bwareaopen(curr_basins, segmentation_para.nonspecific_para.allowed_nuc_size(1));
    id = xor(curr_basins, after_removal);
    final_basins(id(:)) = true; % put this component into final_basins
    curr_basins = after_removal; % remove it from the curr_basins to avoid further erosion
end

% put everything left in curr_basins to final_basins
final_basins = final_basins | curr_basins;

% dilate the image to reasonable size
num_iteration = round(segmentation_para.nonspecific_para.nuc_radius / 3);
for i=1:num_iteration
    final_basins = imdilate(final_basins, strel('disk', 1, 0));
end

% compute the boundary of refined image
final_valleys=imimposemin(valleys,final_basins | outer_ridges);
final_ridges=watershed(final_valleys);

% compute final mask
mask_watershed=mask;
mask_watershed(final_ridges==0)=0;

end
