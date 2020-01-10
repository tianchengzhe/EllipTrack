function [ ac_mask ] = run_active_contour( image, mask, segmentation_para )
%RUN_ACTIVE_CONTOUR Use the active contour method to refine mask
%
%   Input
%       image: Image of the nuclear channel
%       mask: Binary image
%       segmentation_para: Parameters used for segmentation
%   Output
%       ac_mask: refined mask

% if chosen, compute the logarithm of the image
if (segmentation_para.active_contour_para.if_log)
    image = log(max(image, 1));
end
image = mat2gray(image);

% if chosen, perform active contour to whole image
switch lower(segmentation_para.active_contour_para.active_contour_method)
    case 'global'
        ac_mask = activecontour(image, mask);

    case 'local'
        [max_x, max_y] = size(mask);
        ac_mask = false(max_x, max_y);
        all_segment_info = regionprops(mask, 'BoundingBox');
        gap_pixel = 5;
        for i=1:length(all_segment_info)
            temp = all_segment_info(i).BoundingBox;
            start_x = floor(temp(2)) - gap_pixel; start_y = floor(temp(1)) - gap_pixel;
            end_x = start_x + temp(4) + 1 + 2*gap_pixel; end_y = start_y + temp(3) + 1 + 2*gap_pixel;
            start_x = max(1, start_x); start_y = max(1, start_y);
            end_x = min(end_x, max_x); end_y = min(end_y, max_y);
            cropped_image = image(start_x:end_x, start_y:end_y);
            cropped_mask = mask(start_x:end_x, start_y:end_y);
            cropped_contour = activecontour(cropped_image, cropped_mask);
            ac_mask(start_x:end_x, start_y:end_y) = cropped_contour;
        end
    otherwise
        error('run_active_contour: unknown option');
end

% smooth the mask
ac_mask = imfilter(ac_mask, fspecial('disk', round(segmentation_para.nonspecific_para.blur_radius*2/3)), 'symmetric');

% fill in small holes
if (isinf(segmentation_para.nonspecific_para.max_hole_size_to_fill))
    ac_mask = imfill(ac_mask, 'holes');
else
    ac_mask = ~bwareaopen(~ac_mask, segmentation_para.nonspecific_para.max_hole_size_to_fill);
end

% remove too small components
ac_mask = bwareafilt(ac_mask, [segmentation_para.nonspecific_para.allowed_nuc_size(1), segmentation_para.nonspecific_para.allowed_nuc_size(2)*2]);

end

