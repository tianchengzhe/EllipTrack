function [ mask ] = image_binarization( image, segmentation_para )
%IMAGE BINARIZATION Binarize image
% 
%   Input
%       image: Image of the nuclear channel
%       segmentation_para: Parameters used for segmentation
%   Output
%       mask: Binary image

% determine method
switch lower(segmentation_para.image_binarization_para.binarization_method)
    case 'blob' % blob detection, adapted from Cappell et al 2016
        % log transform of the image
        if (segmentation_para.image_binarization_para.if_log)
            image = log(max(image, 1));
        end

        % sharpen the image
        blur = imfilter(image, fspecial('disk', segmentation_para.nonspecific_para.blur_radius), 'symmetric');
        sharpened = image + 2*(image-blur);

        % blob detection
        sigma = 0.75/sqrt(2)*segmentation_para.nonspecific_para.nuc_radius;
        h = sigma^2 * fspecial('log', segmentation_para.nonspecific_para.nuc_radius*ones(1,2)*2, sigma);
        mask = imfilter(sharpened, h, 'symmetric') <= segmentation_para.image_binarization_para.blob_threshold;

    case 'threshold' %  thresholding
        % blur the image
        blur = max(imfilter(image, fspecial('disk', segmentation_para.nonspecific_para.blur_radius), 'symmetric'), 0);

        % log transformation
        if (segmentation_para.image_binarization_para.if_log)
            grayscale_image = mat2gray(log(max(blur, 1)));
        else
            grayscale_image = mat2gray(blur);
        end

        % thresholding
        mask = imbinarize(grayscale_image);
        
    otherwise
        error('image_binarization: unknown option');
end

% fill in holes
if (isinf(segmentation_para.nonspecific_para.max_hole_size_to_fill))
    mask = imfill(mask, 'holes');
else
    mask = ~bwareaopen(~mask, segmentation_para.nonspecific_para.max_hole_size_to_fill);
end

% keep component within a size
mask = bwareafilt(mask, [segmentation_para.nonspecific_para.allowed_nuc_size(1), segmentation_para.nonspecific_para.allowed_nuc_size(2)*2]);

end
