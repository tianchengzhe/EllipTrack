function contourevidence = mia_cmpcontourevidence(I, segmentation_para)
% mia_contourevidence performs contour evidenc extraction step of the method.

%   Synopsis
%       contourevidence = mia_cmpcontourevidence(I,k,thd1,thd2,thdn,vis)
%   Description
%        Returns the contour evidences (visible parts of the objects ) 
%        to infernce the visible parts. It involves two separate tasks:
%        contour segmentation and segment grouping
%   Inputs 
%          - I           binary image
%          - k           kth adjucnet points to the corner point
%          - thd1        Euclidean distance between ellipse centroid of the 
%                        combined contour segments and ellipse fitted to each segment
%          - thd2        Euclidean distance between between the centroids of ellipse
%                        fitted to each segment.
%          - thdn        Euclidean distance between contour center points
%                        to define neighbouring segments 
%          - vis         0 or 1 for visualization puropose
%   Outputs
%         - contourevidence    a cell array contating the visile objects boundaries 

%   Authors
%          Sahar Zafari <sahar.zafari(at)lut(dot)fi>
%
%   Changes
%       14/01/2016  First Edition
%
%   Modification by Chengzhe Tian
%       Remove visualization, pass parameters (and min_ellipse_perimeter)
%       from the main program

% extract parameters
k = segmentation_para.ellipse_para.k;
thd1 = segmentation_para.ellipse_para.thd1;
thd2 = segmentation_para.ellipse_para.thd2;
thdn = segmentation_para.ellipse_para.thdn;
C = segmentation_para.ellipse_para.C;
T_angle = segmentation_para.ellipse_para.T_angle;
sig = segmentation_para.ellipse_para.sig;
Endpoint = segmentation_para.ellipse_para.Endpoint;
Gap_size = segmentation_para.ellipse_para.Gap_size;
min_ellipse_perimeter = 2*sqrt(pi*segmentation_para.nonspecific_para.allowed_ellipse_size(1));

    % concave point extraction
     % parameters for css method
    [curve,idxconcavepoints]= mia_cmpconcavepoint_css(I,C,T_angle,sig,Endpoint,Gap_size,k,min_ellipse_perimeter);
    % segment the curve by the detetcted concave points
    [segments,centers] = mia_segmentcurve_concave(I,curve,idxconcavepoints);
    % segmnet grouping
    contourevidence = mia_groupsegments(I,segments,centers,thdn,thd1,thd2);
end
