function [ image ] = background_subtraction( image, segmentation_para )
%BACKGROUND_SUBTRACTION Perform background subtraction
% 
%   Input
%       image: Image before operation
%       segmentation_para: Parameters used for segmentation
%   Output
%       image: Image after operation

% determine method
if strcmpi(segmentation_para.image_binarization_para.background_subtraction_method, 'none') % do nothing
    return;
else
    % image binarization using thresholding
    temp_para = segmentation_para;
    temp_para.image_binarization_para.binarization_method = 'threshold';
    mask = image_binarization( image, temp_para );
    
    % calculate value to subtract
    switch lower(segmentation_para.image_binarization_para.background_subtraction_method)
        case 'min'
            image = max(image - min(image(~mask)), 1);
        case 'median'
            image = max(image - median(image(~mask)), 1);
        case 'mean'
            image = max(image - mean(image(~mask)), 1);
        otherwise
            error('background_subtraction: unknown option.');
    end            
end

end
