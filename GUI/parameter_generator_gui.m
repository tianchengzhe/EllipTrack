function varargout = parameter_generator_gui(varargin)
% PARAMETER_GENERATOR_GUI MATLAB code for parameter_generator_gui.fig
%      PARAMETER_GENERATOR_GUI, by itself, creates a new PARAMETER_GENERATOR_GUI or raises the existing
%      singleton*.
%
%      H = PARAMETER_GENERATOR_GUI returns the handle to a new PARAMETER_GENERATOR_GUI or the handle to
%      the existing singleton*.
%
%      PARAMETER_GENERATOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMETER_GENERATOR_GUI.M with the given input arguments.
%
%      PARAMETER_GENERATOR_GUI('Property','Value',...) creates a new PARAMETER_GENERATOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before parameter_generator_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to parameter_generator_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help parameter_generator_gui

% Last Modified by GUIDE v2.5 28-Dec-2019 05:07:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @parameter_generator_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @parameter_generator_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

end

% BEGIN copy: https://groups.google.com/forum/#!topic/comp.soft-sys.matlab/JjsKfUb8r8k
% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try 
    % normalize fonts 
    fnames = fieldnames(handles);   % get all GUI elements 
    d1 = handles.(fnames{1}).Position(3)/handles.GUIfiguresize(1); 
    d2 = handles.(fnames{1}).Position(4)/handles.GUIfiguresize(2); 
    pixelfactor = min(d1,d2); 
    for i=1:length(fnames) 
        field = handles.(fnames{i}); 
        try field.FontSize; 
            if strcmp(field.Type,'uitable') 
                % not yet supported cause FontSize change does not effect 
                % all part of the table 
            else 
                set(field,'FontSize',pixelfactor*field.UserData.GUIfontsize); 
            end 
        catch 
        end 
    end 
catch 
end 
guidata(hObject, handles);

end
% END copy

% --- Executes just before parameter_generator_gui is made visible.
function parameter_generator_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to parameter_generator_gui (see VARARGIN)

addpath('utils');
addpath(genpath('../functions'));
addpath(genpath('../third_party_functions/'));

% BEGIN copy: https://groups.google.com/forum/#!topic/comp.soft-sys.matlab/JjsKfUb8r8k
% Center figure on screen and store origin figure size (GUIfiguresize) 
set(hObject,'Units','pixels');    % force for top figure 
figuresize = get(hObject,'Position'); 
handles.GUIfiguresize = figuresize(3:4); % only need [xsize,ysize] 
screensize = get(0,'ScreenSize'); 
xpos = ceil((screensize(3)-figuresize(3))/2); % center horizontally 
ypos = ceil((screensize(4)-figuresize(4))/2); % center vertically 
set(hObject,'Position',[xpos,ypos,figuresize(3:4)]); 

% For all GUI-elements except top figure: 
fnames = fieldnames(handles); 
for i=2:length(fnames) 
    field = handles.(fnames{i}); 
    % set Units to 'normalized' 
    try field.Units; 
        field.Units = 'normalized'; 
    catch 
    end 
    % set FontUnits to 'points' and store origin font size (UserData.GUIfontsize) 
    try field.FontUnits; 
        field.FontUnits = 'points'; 
        if strcmp(field.Type,'uitable') 
            % not yet supported cause UserData can't be used and layout 
            % doesn't react completely on FontSize changes 
        else 
            field.UserData.GUIfontsize = field.FontSize; 
        end 
    catch 
    end 
end 
set(hObject,'Units','pixels');    % might be changed before 
% END copy

% set TooltipString properties
% outer
set(handles.radiobutton_outer_new, 'TooltipString', 'Create a new parameter file.');
set(handles.radiobutton_outer_load, 'TooltipString', 'Load an existing parameter file.');
set(handles.edit_outer_load, 'TooltipString', 'Enter the path to an existing parameter file.');
set(handles.pushbutton_outer_load, 'TooltipString', 'Select an existing parameter file.');
set(handles.pushbutton_outer_start, 'TooltipString', 'Load parameter values and start editing.');
set(handles.pushbutton_outer_previous, 'TooltipString', 'Go to the previous panel.');
set(handles.pushbutton_outer_next, 'TooltipString', 'Go to the next panel.');
set(handles.pushbutton_outer_save, 'TooltipString', 'Save parameter values and exit.');

% sec 1, page 1
set(handles.text3, 'TooltipString', sprintf('Movie format.\nRelated to movie_definition.image_type'));
set(handles.radiobutton_sec1_imagetype_seq, 'TooltipString', sprintf('Movies are stored as image sequences.\nEach image contains one channel at one frame.'));
set(handles.radiobutton_sec1_imagetype_stack, 'TooltipString', sprintf('Movies are stored as image stacks.\nEach stack contains one channel at all frames.'));
set(handles.radiobutton_sec1_imagetype_nd2, 'TooltipString', sprintf('Movies are stored in the Nikon ND2 format.\nMovies can be stored in multiple segments (files).\nEach segment contains images of all channels.'));
set(handles.text41, 'TooltipString', sprintf('Number of channels in the movie.'));
set(handles.text40, 'TooltipString', sprintf('Names of the fluorescent channels.\nRelated to movie_definition.channel_names'));
set(handles.text42, 'TooltipString', sprintf('Names of the signals to measure.\nRelated to movie_definition.signal_names'));
set(handles.text43, 'TooltipString', sprintf('Paths to the folders storing the images.\nRelated to movie_definition.image_path'));
set(handles.text44, 'TooltipString', sprintf('Paths to the MAT files storing the illumination biases.\nRelated to movie_definition.bias_paths'));
set(handles.text45, 'TooltipString', sprintf('Whether to compute signals in the cytoplasmic ring.\nRelated to movie_definition.if_compute_cytoring'));
for i=1:6
    temp = matlab.lang.makeValidName(['radiobutton_sec1_numchannel_', num2str(i)]);
    set(handles.(temp), 'TooltipString', sprintf('Movie has %g channel(s).', i));
    temp = matlab.lang.makeValidName(['text', num2str(45+i)]);
    set(handles.(temp), 'TooltipString', sprintf('Information of Channel %g.', i));
    temp = matlab.lang.makeValidName(['edit_sec1_ch', num2str(i), '_channel']);
    set(handles.(temp), 'TooltipString', sprintf('Enter the channel name.'));
    temp = matlab.lang.makeValidName(['edit_sec1_ch', num2str(i), '_signal']);
    set(handles.(temp), 'TooltipString', sprintf('Enter the signal name.\nOnly use letters, numbers, and _.\nMust not start with a number.'));
    temp = matlab.lang.makeValidName(['edit_sec1_ch', num2str(i), '_path']);
    set(handles.(temp), 'TooltipString', sprintf('Enter the path to the folder.'));
    temp = matlab.lang.makeValidName(['pushbutton_sec1_ch', num2str(i), '_path']);
    set(handles.(temp), 'TooltipString', sprintf('Select the folder.'));
    temp = matlab.lang.makeValidName(['edit_sec1_ch', num2str(i), '_bias']);
    set(handles.(temp), 'TooltipString', sprintf('Enter the path to the MAT file.'));
    temp = matlab.lang.makeValidName(['pushbutton_sec1_ch', num2str(i), '_bias_select']);
    set(handles.(temp), 'TooltipString', sprintf('Select the MAT file.'));
    temp = matlab.lang.makeValidName(['pushbutton_sec1_ch', num2str(i), '_bias_delete']);
    set(handles.(temp), 'TooltipString', sprintf('Remove the path.'));
    temp = matlab.lang.makeValidName(['checkbox_sec1_ch', num2str(i), '_cytoring']);
    set(handles.(temp), 'TooltipString', sprintf('Check to calculate signals in the cytoplasmic ring.'));
end
set(handles.text52, 'TooltipString', sprintf('Formats of image filenames.\nImage Sequences or Stacks: Full filenames are required.\nnd2: First few characters of filenames are sufficient.\nRelated to movie_definition.filename_format'));
set(handles.edit_sec1_filename, 'TooltipString', sprintf('Enter the format of filenames.'));
set(handles.edit_sec1_filename_delete, 'TooltipString', sprintf('Remove the format.'));
set(handles.pushbutton_sec1_filename_check, 'TooltipString', sprintf('Check validity of the format.'));
set(handles.pushbutton_sec1_filename_row, 'TooltipString', sprintf('Add Row ID to the format.'));
set(handles.pushbutton_sec1_filename_column, 'TooltipString', sprintf('Add Column ID to the format.'));
set(handles.pushbutton_sec1_filename_site, 'TooltipString', sprintf('Add Site ID to the format.'));
set(handles.pushbutton_sec1_filename_frame, 'TooltipString', sprintf('Add Frame ID to the format.'));
set(handles.pushbutton_sec1_filename_channel, 'TooltipString', sprintf('Add Channel to the format.'));

% sec 1, page 2
set(handles.text27, 'TooltipString', sprintf('Movie coordinates in a multi-well plate.\nRelated to movie_definition.wells_to_track'));
set(handles.edit_sec1_row_from, 'TooltipString', sprintf('Enter ID of the first row.\nMust be a positive integer.'));
set(handles.edit_sec1_row_to, 'TooltipString', sprintf('Enter ID of the last row.\nMust be a positive integer.'));
set(handles.edit_sec1_column_from, 'TooltipString', sprintf('Enter ID of the first column.\nMust be a positive integer.'));
set(handles.edit_sec1_column_to, 'TooltipString', sprintf('Enter ID of the last column.\nMust be a positive integer.'));
set(handles.edit_sec1_site_from, 'TooltipString', sprintf('Enter ID of the first site.\nMust be a positive integer.'));
set(handles.edit_sec1_site_to, 'TooltipString', sprintf('Enter ID of the last site.\nMust be a positive integer.'));
set(handles.checkbox_sec1_well, 'TooltipString', sprintf('Check if the experiment is not performed in a multi-well plate.'));
set(handles.text28, 'TooltipString', sprintf('Frame IDs.\nRelated to movie_definition.frames_to_track'));
set(handles.edit_sec1_frame_from, 'TooltipString', sprintf('Enter ID of the first frame.\nMust be a non-negative integer.'));
set(handles.edit_sec1_frame_to, 'TooltipString', sprintf('Enter ID of the last frame.\nMust be a non-negative integer.'));
set(handles.text36, 'TooltipString', sprintf('Path to the MAT file storing the camera dark noises.\nRelated to movie_definition.cmosoffset_path'));
set(handles.edit_sec1_cmos, 'TooltipString', sprintf('Enter the path to the MAT file.'));
set(handles.pushbutton_sec1_cmos_select, 'TooltipString', sprintf('Select the MAT file.'));
set(handles.pushbutton_sec1_delete, 'TooltipString', sprintf('Remove the path.'));
set(handles.text37, 'TooltipString', sprintf('Method of jitter correction.\nRelated to movie_definition.jitter_correction_method'));
set(handles.radiobutton_sec1_jitter_none, 'TooltipString', sprintf('No jitter correction will be performed.\nSuggested if jitters are negligible.'));
set(handles.radiobutton_sec1_jitter_local, 'TooltipString', sprintf('Local method.\nJitter correction will be performed on each movie, independent from other movies.\nSuggested if movies have big jitters.'));
set(handles.radiobutton_sec1_jitter_global, 'TooltipString', sprintf('Global method. First perform the Local method.\nJitters will then be corrected by the locations of wells on the multi-well plate.\nSuggested for improving the accuracy of jitter inference.\nRequire at least 6 wells.'));
set(handles.text38, 'TooltipString', sprintf('Number of logical cores for parallel computing.\nRelated to movie_definition.num_cores'));
set(handles.edit_sec1_core, 'TooltipString', sprintf('Enter the number of cores to use.\nMust be a positive integer between 1 and the maximal number of cores.'));
set(handles.text206, 'TooltipString', sprintf('Row ID of the movie for extraction.'));
set(handles.edit_sec1_extract_row, 'TooltipString', sprintf('Enter Row ID.\nMust be a positive integer.'));
set(handles.text208, 'TooltipString', sprintf('Column ID of the movie for extraction.'));
set(handles.edit_sec1_extract_column, 'TooltipString', sprintf('Enter Column ID.\nMust be a positive integer.'));
set(handles.text209, 'TooltipString', sprintf('Site ID of the movie for extraction.'));
set(handles.edit_sec1_extract_site, 'TooltipString', sprintf('Enter Site ID.\nMust be a positive integer.'));
set(handles.text210, 'TooltipString', sprintf('Frames to extract.'));
set(handles.edit_sec1_extract_frame_from, 'TooltipString', sprintf('Enter ID of the first frame.\nMust be a non-negative integer.'));
set(handles.edit_sec1_extract_frame_to, 'TooltipString', sprintf('Enter ID of the last frame.\nMust be a non-negative integer.'));
set(handles.text212, 'TooltipString', sprintf('Folder to store the extracted images.'));
set(handles.edit_sec1_extract_path, 'TooltipString', sprintf('Enter the path to the folder.'));
set(handles.pushbutton_sec1_extract_path, 'TooltipString', sprintf('Select the folder.'));
set(handles.pushbutton_sec1_extract, 'TooltipString', sprintf('Extract images.'));

% sec 2
set(handles.text64, 'TooltipString', sprintf('Paths to the training datasets.\nRelated to inout_para.training_data_path'));
set(handles.edit_sec2_training, 'TooltipString', sprintf('Enter the path to a training dataset.'));
set(handles.pushbutton_sec2_training_select, 'TooltipString', sprintf('Select a training dataset.'));
set(handles.pushbutton_sec2_training_load_delete, 'TooltipString', sprintf('Remove the path.'));
set(handles.pushbutton_sec2_training_load_add, 'TooltipString', sprintf('Add the training dataset to the loaded list.'));
set(handles.listbox_sec2_training, 'TooltipString', sprintf('Loaded training datasets.'));
set(handles.pushbutton_sec2_training_delete, 'TooltipString', sprintf('Remove the selected training dataset from the list.'));
set(handles.text82, 'TooltipString', sprintf('Types of outputs.'));
set(handles.text83, 'TooltipString', sprintf('Path to the folder storing the outputs.'));
set(handles.text84, 'TooltipString', sprintf('Whether to generate the outputs.'));
set(handles.text81, 'TooltipString', sprintf('Outputs of EllipTrack modules.'));
set(handles.text76, 'TooltipString', sprintf('Binarized nuclear image before Ellipse Fitting.\nSuggested for evaluating the accuracy of segmentation.'));
set(handles.text77, 'TooltipString', sprintf('Autoscaled nuclear image overlaid by fitted ellipses.\nSuggested for evaluating the accuracy of segmentation.'));
set(handles.text79, 'TooltipString', sprintf('Ellipse information of one frame.\nSuggested if training datasets will be constructed from this movie.'));
set(handles.text80, 'TooltipString', sprintf('Autoscaled nuclear image overlaid by fitted ellipses and cell track IDs.\nSuggested for evaluating the accuracy of tracking.'));
suffix = {'output', 'mask', 'ellipse', 'seginfo', 'vistrack'};
for i=1:length(suffix)
    temp = matlab.lang.makeValidName(['edit_sec2_', suffix{i}]);
    set(handles.(temp), 'TooltipString', sprintf('Enter the path to the folder.'));
    temp = matlab.lang.makeValidName(['pushbutton_sec2_', suffix{i}]);
    set(handles.(temp), 'TooltipString', sprintf('Select the folder.'));
    temp = matlab.lang.makeValidName(['checkbox_sec2_', suffix{i}]);
    set(handles.(temp), 'TooltipString', sprintf('Check to generate this output.'));
end

% sec 3
set(handles.text163, 'TooltipString', sprintf('Row ID of the image for display.'));
set(handles.text164, 'TooltipString', sprintf('Column ID of the image for display.'));
set(handles.text165, 'TooltipString', sprintf('Site ID of the image for display.'));
set(handles.text166, 'TooltipString', sprintf('Frame ID of the image for display.'));
set(handles.edit_sec3_axes_row, 'TooltipString', sprintf('Enter Row ID.\nMust be a positive integer.'));
set(handles.edit_sec3_axes_column, 'TooltipString', sprintf('Enter Column ID.\nMust be a positive integer.'));
set(handles.edit_sec3_axes_site, 'TooltipString', sprintf('Enter Site ID.\nMust be a positive integer.'));
set(handles.edit_sec3_axes_frame, 'TooltipString', sprintf('Enter Frame ID.\nMust be a non-negative integer.'));
set(handles.pushbutton_sec3_axes_load, 'TooltipString', sprintf('Load image into the GUI.'));
set(handles.text214, 'TooltipString', sprintf('Intensity range for display.'));
set(handles.edit_sec3_intensity_from, 'TooltipString', sprintf('Enter the lower bound.\nMust be a non-negative number.'));
set(handles.edit_sec3_intensity_to, 'TooltipString', sprintf('Enter the upper bound.\nMust be a non-negative number.'));
set(handles.text213, 'TooltipString', sprintf('Require advanced knowledge of the algorithm.\nDefault values usually work well.'));
set(handles.pushbutton_sec3_nav_nonspec, 'TooltipString', sprintf('Switch to Non-Specific Parameters.'));
set(handles.pushbutton_sec3_nav_binarization, 'TooltipString', sprintf('Switch to Image Binarization.'));
set(handles.pushbutton_sec3_nav_activecontour, 'TooltipString', sprintf('Switch to Active Contour.'));
set(handles.pushbutton_sec3_nav_watershed, 'TooltipString', sprintf('Switch to Watershed.'));
set(handles.pushbutton_sec3_nav_ellipse, 'TooltipString', sprintf('Switch to Ellipse Fitting.'));
set(handles.pushbutton_sec3_nav_correction, 'TooltipString', sprintf('Switch to Correction with Training Data.'));
set(handles.text176, 'TooltipString', sprintf('Average radius (in pixels) of a nucleus.\nRelated to segmentation_para.nonspecific_para.nuc_radius'));
set(handles.edit_sec3_nonspec_nucradius, 'TooltipString', sprintf('Enter the average radius.\nMust be a positive integer.'));
set(handles.text177, 'TooltipString', sprintf('Acceptable areas (in pixels) of a nucleus.\nRelated to segmentation_para.nonspecific_para.allowed_nuc_size'));
set(handles.edit_sec3_nonspec_nucarea_from, 'TooltipString', sprintf('Enter the lower bound.\nMust be a positive integer.'));
set(handles.edit_sec3_nonspec_nucarea_to, 'TooltipString', sprintf('Enter the upper bound.\nMust be a positive integer.'));
set(handles.text179, 'TooltipString', sprintf('Acceptable areas (in pixels) of an ellipse.\nRelated to segmentation_para.nonspecific_para.allowed_ellipse_size'));
set(handles.edit_sec3_nonspec_elliparea_from, 'TooltipString', sprintf('Enter the lower bound.\nMust be a positive integer.'));
set(handles.edit_sec3_nonspec_elliparea_to, 'TooltipString', sprintf('Enter the upper bound.\nMust be a positive integer.'));
set(handles.text181, 'TooltipString', sprintf('Maximal aspect ratio (>1) of an ellipse.\nRelated to segmentation_para.nonspecific_para.max_ellipse_aspect_ratio'));
set(handles.edit_sec3_nonspec_aspect, 'TooltipString', sprintf('Enter the maximal aspect ratio.\nMust be >= 1.'));
set(handles.text182, 'TooltipString', sprintf('Maximal hole area (in pixels) to fill.\nA hole is defined as a set of background pixels surrounded by foreground pixels in a mask.\nRelated to segmentation_para.nonspecific_para.max_hole_size_to_fill'));
set(handles.edit_sec3_nonspec_hole, 'TooltipString', sprintf('Enter the maximal hole area.\nMust be a positive integer.'));
set(handles.text183, 'TooltipString', sprintf('Radius (in pixels) of the disk for image smoothing.\nRelated to segmentation_para.nonspecific_para.blur_radius'));
set(handles.edit_sec3_nonspec_blur, 'TooltipString', sprintf('Enter the blur radius.\nMust be a positive integer.'));
set(handles.pushbutton_sec3_nonspec_next, 'TooltipString', sprintf('Go to the next step.'));
set(handles.text186, 'TooltipString', sprintf('Whether to log-transform the images.\nRelated to segmentation_para.image_binarization_para.if_log'));
set(handles.checkbox_sec3_binarization_log, 'TooltipString', sprintf('Check to log-transform the images.\nSuggested if nuclei have heterogeneous brightness.'));
set(handles.text185, 'TooltipString', sprintf('Method of Background Subtraction.\nRelated to segmentation_para.image_binarization_para.background_subtraction_method'));
set(handles.popupmenu_sec3_binarization_bgsub, 'TooltipString', sprintf('Select the method.\nNone: No background subtraction will be performed.\nMin,Median,Mean: Images will be subtracted by the minimal,median,mean intensity of the background.')); 
set(handles.text188, 'TooltipString', sprintf('Method of Image Binarization.\nRelated to segmentation_para.image_binarization_para.binarization_method'));
set(handles.popupmenu_sec3_binarization_method, 'TooltipString', sprintf('Select the method.\nThresholding: A threshold is applied to the image intensities.\nBlob Detection: A threshold is applied to the hessian of image intensities.'));
set(handles.text187, 'TooltipString', sprintf('Blob Detection only. Threshold of the hessian.\nRelated to segmentation_para.image_binarization_para.blob_threshold'));
set(handles.edit_sec3_binarization_threshold, 'TooltipString', sprintf('Enter the blob threshold.\nMust be a negative number.'));
set(handles.pushbutton_sec3_binarization_update, 'TooltipString', sprintf('Update segmentation result.'));
set(handles.pushbutton_sec3_binarization_next, 'TooltipString', sprintf('Go to the next step.'));
set(handles.text190, 'TooltipString', sprintf('Whether to run Active Contour.\nRelated to segmentation_para.active_contour_para.if_run'));
set(handles.checkbox_sec3_activecontour_ifrun, 'TooltipString', sprintf('Check to run Active Contour.\nSuggested if Image Binarization does not detect accurate nuclear boundary.'));
set(handles.text192, 'TooltipString', sprintf('Whether to log-transform the images.\nRelated to segmentation_para.active_contour_para.if_log'));
set(handles.checkbox_sec3_activecontour_log, 'TooltipString', sprintf('Check to log-transform the images.\nSuggested if nuclei have heterogeneous brightness.'));
set(handles.text191, 'TooltipString', sprintf('Method of active contour.\nRelated to segmentation_para.active_contour_para.active_contour_method'));
set(handles.popupmenu_sec3_activecontour_method, 'TooltipString', sprintf('Select the method.\nLocal: Active contour is applied to the neighborhood of every nucleus.\nGlobal: Active contour is applied to the entire image at once.'));
set(handles.pushbutton_sec3_activecontour_update, 'TooltipString', sprintf('Update segmentation result.'));
set(handles.pushbutton_sec3_activecontour_next, 'TooltipString', sprintf('Go to the next step.'));
set(handles.text193, 'TooltipString', sprintf('Whether to run Watershed.\nRelated to segmentation_para.watershed_para.if_run'));
set(handles.checkbox_sec3_watershed_ifrun, 'TooltipString', sprintf('Check to run Watershed.\nSuggested if nuclei overlap frequently.'));
set(handles.pushbutton_sec3_watershed_update, 'TooltipString', sprintf('Update segmentation result.'));
set(handles.pushbutton_sec3_watershed_next, 'TooltipString', sprintf('Go to the next step.'));
set(handles.text168, 'TooltipString', sprintf('Consider up to k-th adjacent points to the corner point.\nRelated to segmentation_para.ellipse_para.k'));
set(handles.edit_sec3_ellipse_k, 'TooltipString', sprintf('Enter the value of k.\nMust be a positive integer.'));
set(handles.text197, 'TooltipString', sprintf('Distance (in pixels) between the ellipse centroid of the\ncombined contour segments and the ellipse fitted to each segment.\nRelated to segmentation_para.ellipse_para.thd1'));
set(handles.edit_sec3_ellipse_thd1, 'TooltipString', sprintf('Enter the value of thd1.\nMust be a positive integer.'));
set(handles.text194, 'TooltipString', sprintf('Distance (in pixels) between the centroids of ellipse fitted to each segment.\nRelated to segmentation_para.ellipse_para.thd2'));
set(handles.edit_sec3_ellipse_thd2, 'TooltipString', sprintf('Enter the value of thd2.\nMust be a positive integer.'));
set(handles.text198, 'TooltipString', sprintf('Distance (in pixels) between contour center points.\nRelated to segmentation_para.ellipse_para.thdn'));
set(handles.edit_sec3_ellipse_thdn, 'TooltipString', sprintf('Enter the value of thdn.\nMust be a positive integer.'));
set(handles.text199, 'TooltipString', sprintf('Minimal aspect ratio for corner detection.\nRelated to segmentation_para.ellipse_para.C'));
set(handles.edit_sec3_ellipse_C, 'TooltipString', sprintf('Enter the value of C.\nMust be >= 1.'));
set(handles.text200, 'TooltipString', sprintf('Standard deviation (in pixels) of the Gaussian filter.\nRelated to segmentation_para.ellipse_para.sig'));
set(handles.edit_sec3_ellipse_sig, 'TooltipString', sprintf('Enter the value of sig.\nMust be a positive integer.'));
set(handles.text201, 'TooltipString', sprintf('Maximal angle (in degrees) of a corner.\nRelated to segmentation_para.ellipse_para.T_angle'));
set(handles.edit_sec3_ellipse_Tangle, 'TooltipString', sprintf('Enter the value of T_angle.\nMust be a positive integer.'));
set(handles.text202, 'TooltipString', sprintf('Whether to add the end points of a curve as corner.\nRelated to segmentation_para.ellipse_para.Endpoint'));
set(handles.edit_sec3_ellipse_endpoint, 'TooltipString', sprintf('Enter 1 for add, 0 for not add.'));
set(handles.text203, 'TooltipString', sprintf('Maximal length of gaps (in pixels) in the contours to fill.\nRelated to segmentation_para.ellipse_para.Gap_size'));
set(handles.edit_sec3_ellipse_gapsize, 'TooltipString', sprintf('Enter the value of Gap_size.\nMust be a positive integer.'));
set(handles.pushbutton_sec3_ellipse_update, 'TooltipString', sprintf('Update segmentation result.'));
set(handles.pushbutton_sec3_ellipse_next, 'TooltipString', sprintf('Go to the next step.'));
set(handles.text195, 'TooltipString', sprintf('Whether to run Correction with Training Data.\nRelated to segmentation_para.seg_correction_para.if_run'));
set(handles.checkbox_sec3_correction_ifrun, 'TooltipString', sprintf('Check to run Correction with Training Data.\nSuggested if training datasets are available and well-predict the number of nuclei in each ellipse.'));
set(handles.text196, 'TooltipString', sprintf('Minimal probability (0 to 1) for correction.\nRelated to segmentation_para.seg_correction_para.min_corr_prob'));
set(handles.edit_sec3_correction_minprob, 'TooltipString', sprintf('Enter the minimal probability.\nMust be between 0 and 1.'));

% sec 4, page 1
set(handles.text140, 'TooltipString', sprintf('Migration speed.\nRelated to prob_para.migration_speed'));
set(handles.radiobutton_sec4_speed_global, 'TooltipString', sprintf('All cells have the same migration speed.\nSuggested if cells migrate independently of other cells and factors.'));
set(handles.radiobutton_sec4_speed_time, 'TooltipString', sprintf('Migration speed is dependent on time.\nSuggested if cell migration mode changes, such as due to drug addition.'));
set(handles.radiobutton_sec4_speed_density, 'TooltipString', sprintf('Migration speed is dependent on local cell density.\nSuggested if cell migration is limited by the available space\nor controlled by cell-cell communication.'));
set(handles.radiobutton_sec4_speed_custom, 'TooltipString', sprintf('Customized migration speed.\nSuggested if training datasets are unavailable\nor the other options do not produce satisfactory results.'));
set(handles.edit_sec4_speed_custom, 'TooltipString', sprintf('Enter the migration speed.\nMust be a positive number.'));
set(handles.pushbutton_sec4_speed, 'TooltipString', sprintf('Calculate migration speed.'));
set(handles.text154, 'TooltipString', sprintf('Related to prob_para.max_migration_dist_fold'));
set(handles.edit_sec4_migfold, 'TooltipString', sprintf('Enter the maximal fold.\nMust be a positive number.\n'));
set(handles.text142, 'TooltipString', sprintf('Related to prob_para.migration_inference_resolution'));
set(handles.edit_sec4_inf_resolution, 'TooltipString', sprintf('Enter the resolution.\nMust be a positive number.'));
set(handles.text143, 'TooltipString', sprintf('Related to prob_para.migration_inference_min_samples.'));
set(handles.edit_sec4_inf_sample, 'TooltipString', sprintf('Enter the minimal number of samples.\nMust be a positive integer.'));

% sec 4, page 2
set(handles.text126, 'TooltipString', sprintf('Related to prob_para.mitosis_inference_option'));
set(handles.radiobutton_sec4_mito_all, 'TooltipString', sprintf('Mother cells need to have high probabilities of being mitotic,\nand daughter cells need to have high probabilities of being newly born.'));
set(handles.radiobutton_sec4_mito_before, 'TooltipString', sprintf('Mother cells need to have high probabilities of being mitotic.\nNo requirement on daughter cells.'));
set(handles.radiobutton_sec4_mito_after, 'TooltipString', sprintf('Daughter cells need to have high probabilities of being newly born.\nNo requirement on mother cells.'));
set(handles.radiobutton_sec4_mito_none, 'TooltipString', sprintf('No requirement on either mother or daughter cells.'));
set(handles.text139, 'TooltipString', sprintf('Related to prob_para.migration_option'));
set(handles.radiobutton_sec4_migsim_both, 'TooltipString', sprintf('Consider both the migration distance and\nthe probability that the two ellipses belong to the same cell.'));
set(handles.radiobutton_sec4_migsim_dist, 'TooltipString', sprintf('Consider only the migration distance.'));
set(handles.text133, 'TooltipString', sprintf('Related to prob_para.empty_prob'));
set(handles.edit_sec4_empty, 'TooltipString', sprintf('Enter the probability.\nMust be between 0 and 1.'));
set(handles.text135, 'TooltipString', sprintf('Related to prob_para.prob_nonmigration'));
set(handles.edit_sec4_null, 'TooltipString', sprintf('Enter the probability.\nMust be between 0 and 1.'));
set(handles.text136, 'TooltipString', sprintf('Related to prob_para.min_inout_prob'));
set(handles.edit_sec4_inout, 'TooltipString', sprintf('Enter the probability.\nMust be between 0 and 1.'));
set(handles.text137, 'TooltipString', sprintf('Equals to prob_para.max_migration_time-1'));
set(handles.edit_sec4_gap, 'TooltipString', sprintf('Enter the maximal number.\nMust be a non-negative integer.'));

% sec5
set(handles.edit_sec5_minlength, 'TooltipString', sprintf('Enter the value.\nMust be a non-negative integer.\nRelated to track_para.min_track_length'));
set(handles.edit_sec5_maxskip, 'TooltipString', sprintf('Enter the value.\nMust be a non-negative integer.\nRelated to track_para.max_num_frames_to_skip'));
set(handles.text87, 'TooltipString', sprintf('Related to track_para.min_track_score'));
set(handles.edit_sec5_minscore_overall, 'TooltipString', sprintf('Enter the score.\nMust be a non-negative number.'));
set(handles.text99, 'TooltipString', sprintf('Related to track_para.min_track_score_per_step'));
set(handles.edit_sec5_minscore_neighbor, 'TooltipString', sprintf('Enter the score.'));
set(handles.text100, 'TooltipString', sprintf('Related to track_para.multiple_cells_penalty'));
set(handles.edit_sec5_coexist, 'TooltipString', sprintf('Enter the score.\nMust be a non-negative number.'));
set(handles.text101, 'TooltipString', sprintf('Related to track_para.skip_penalty'));
set(handles.edit_sec5_skip, 'TooltipString', sprintf('Enter the score.\nMust be a non-negative number.'));
set(handles.text105, 'TooltipString', sprintf('Related to track_para.min_swap_score'));
set(handles.edit_sec5_swap, 'TooltipString', sprintf('Enter the score.\nMust be a non-negative number.'));
set(handles.text106, 'TooltipString', sprintf('Related to track_para.mitosis_detection_min_prob'));
set(handles.edit_sec5_swap, 'TooltipString', sprintf('Enter the probability.\nMust be between 0 and 1.'));
set(handles.text216, 'TooltipString', sprintf('Suggested to be 10-20%% of a typical cell cycle duration.\nRelated to track_para.critical_length'));
set(handles.edit_sec5_critical, 'TooltipString', sprintf('Enter the critical length.\nMust be a non-negative integer.'));

% sec 6
set(handles.text122, 'TooltipString', sprintf('Related to signal_extraction_para.nuc_region_dist'));
set(handles.edit_sec6_nucdist, 'TooltipString', sprintf('Enter the distance.\nMust be a non-negative integer.'));
set(handles.text123, 'TooltipString', sprintf('Related to signal_extraction_para.cytoring_region_dist'));
set(handles.edit_sec6_cytodist_inner, 'TooltipString', sprintf('Enter the distance.\nMust be a non-negative integer.'));
set(handles.text124, 'TooltipString', sprintf('Related to signal_extraction_para.cytoring_region_dist'));
set(handles.edit_sec6_cytodist_outer, 'TooltipString', sprintf('Enter the distance.\nMust be a non-negative integer.'));
set(handles.text125, 'TooltipString', sprintf('Related to signal_extraction_para.background_dist'));
set(handles.edit_sec6_memdist, 'TooltipString', sprintf('Enter the distance.\nMust be a non-negative integer.'));
set(handles.text120, 'TooltipString', sprintf('Related to signal_extraction_para.intensity_percentile'));
set(handles.edit_sec6_percentile, 'TooltipString', sprintf('Enter the percentiles.\nMust be between 0 and 100.'));
set(handles.text112, 'TooltipString', sprintf('Related to signal_extraction_para.outlier_percentile'));
set(handles.edit_sec6_outlier, 'TooltipString', sprintf('Enter the percentile.\nMust be between 0 and 50.'));

% Choose default command line output for parameter_generator_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes parameter_generator_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

end

% --- Outputs from this function are returned to the command line.
function varargout = parameter_generator_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(hObject);
% % Hint: delete(hObject) closes the figure
% if isequal(get(hObject, 'waitstatus'), 'waiting')
%     % The GUI is still in UIWAIT, us UIRESUME
%     uiresume(hObject);
% else
%     % The GUI is no longer waiting, just close it
%     delete(hObject);
% end

end

%% OUTER
% --- Executes on button press in radiobutton_outer_new.
function radiobutton_outer_new_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_outer_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_outer_new

set(handles.uibuttongroup_outer, 'SelectedObject', handles.radiobutton_outer_new);
set(handles.edit_outer_load, 'Visible', 'off');
set(handles.pushbutton_outer_load, 'Visible', 'off');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_outer_load.
function radiobutton_outer_load_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_outer_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_outer_load

set(handles.uibuttongroup_outer, 'SelectedObject', handles.radiobutton_outer_load);
set(handles.edit_outer_load, 'Visible', 'on');
set(handles.pushbutton_outer_load, 'Visible', 'on');
guidata(hObject, handles);

end

function edit_outer_load_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outer_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_outer_load as text
%        str2double(get(hObject,'String')) returns contents of edit_outer_load as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_outer_load_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outer_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_outer_load.
function pushbutton_outer_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outer_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.m;*.M');
if ~isequal(file, 0)
    set(handles.edit_outer_load, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_outer_start.
function pushbutton_outer_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outer_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = waitbar(0, 'Processing');
% load images
try
    if (get(handles.uibuttongroup_outer, 'SelectedObject') == handles.radiobutton_outer_new)
        temp = function_handle('utils/default_para.m');
        loaded_para = temp();
    else
        temp = function_handle(get(handles.edit_outer_load, 'String'));
        loaded_para = temp();
    end
catch
    close(f);
    waitfor(errordlg('Parameter files not loaded.', 'Error'));
    return;
end

% update parameter value
try
    handles = paragenGUI_update_para(handles, loaded_para);
catch err
    set(handles.uipanel_sec1_page1, 'Visible', 'off');
    close(f);
    waitfor(errordlg(err.message, 'Error'));
    return;
end

% update visibility
set(handles.radiobutton_outer_new, 'Enable', 'off');
set(handles.radiobutton_outer_load, 'Enable', 'off');
set(handles.edit_outer_load, 'Enable', 'off');
set(handles.pushbutton_outer_load, 'Enable', 'off');
set(handles.pushbutton_outer_start, 'Enable', 'off');
set(handles.pushbutton_outer_previous, 'Visible', 'on');
set(handles.pushbutton_outer_next, 'Visible', 'on');
set(handles.pushbutton_outer_save, 'Visible', 'on');

handles.current_panel = 1;
handles = switch_panel(handles);
close(f);

guidata(hObject, handles)

end

% --- Executes on button press in pushbutton_outer_previous.
function pushbutton_outer_previous_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outer_previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.current_panel = handles.current_panel - 1;
handles = switch_panel(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_outer_next.
function pushbutton_outer_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outer_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.current_panel = handles.current_panel + 1;
handles = switch_panel(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_outer_save.
function pushbutton_outer_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_outer_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

paragenGUI_save_para( handles, pwd() );
figure1_CloseRequestFcn(handles.figure1, eventdata, handles);

end

%% MOVIE DEFINITION, PAGE 1
% --- Executes on button press in radiobutton_sec1_imagetype_seq.
function radiobutton_sec1_imagetype_seq_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_imagetype_seq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_imagetype_seq

handles = switch_image_type(handles, 'seq');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_imagetype_stack.
function radiobutton_sec1_imagetype_stack_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_imagetype_stack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_imagetype_stack

handles = switch_image_type(handles, 'stack');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_imagetype_nd2.
function radiobutton_sec1_imagetype_nd2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_imagetype_nd2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_imagetype_nd2

handles = switch_image_type(handles, 'nd2');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_numchannel_1.
function radiobutton_sec1_numchannel_1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_numchannel_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_numchannel_1

handles = adjust_num_channels(handles, 1);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_numchannel_2.
function radiobutton_sec1_numchannel_2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_numchannel_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_numchannel_2

handles = adjust_num_channels(handles, 2);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_numchannel_3.
function radiobutton_sec1_numchannel_3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_numchannel_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_numchannel_3

handles = adjust_num_channels(handles, 3);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_numchannel_4.
function radiobutton_sec1_numchannel_4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_numchannel_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_numchannel_4

handles = adjust_num_channels(handles, 4);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_numchannel_5.
function radiobutton_sec1_numchannel_5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_numchannel_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_numchannel_5

handles = adjust_num_channels(handles, 5);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec1_numchannel_6.
function radiobutton_sec1_numchannel_6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec1_numchannel_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec1_numchannel_6

handles = adjust_num_channels(handles, 6);
guidata(hObject, handles);

end

function edit_sec1_ch1_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch1_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch1_channel as a double

hObject = check_channel_name(hObject, 0);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch1_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch2_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch2_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch2_channel as a double

hObject = check_channel_name(hObject, 0);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch2_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch3_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch3_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch3_channel as a double

hObject = check_channel_name(hObject, 0);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch3_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch4_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch4_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch4_channel as a double

hObject = check_channel_name(hObject, 0);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch4_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch5_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch5_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch5_channel as a double

hObject = check_channel_name(hObject, 0);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch5_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch6_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch6_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch6_channel as a double

hObject = check_channel_name(hObject, 0);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch6_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch1_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch1_signal as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch1_signal as a double

hObject = check_channel_name(hObject, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch1_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch2_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch2_signal as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch2_signal as a double

hObject = check_channel_name(hObject, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch2_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch3_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch3_signal as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch3_signal as a double

hObject = check_channel_name(hObject, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch3_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch4_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch4_signal as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch4_signal as a double

hObject = check_channel_name(hObject, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch4_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch5_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch5_signal as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch5_signal as a double

hObject = check_channel_name(hObject, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch5_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch6_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch6_signal as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch6_signal as a double

hObject = check_channel_name(hObject, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch6_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch1_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch1_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch1_path as a double

hObject = check_path_name(hObject);
if (handles.if_same_path)
    for i=2:handles.num_channels
        set(handles.(handles.channel_operator{i}{3}), 'String', get(hObject, 'String'));
    end
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch1_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch2_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch2_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch2_path as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch2_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch3_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch3_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch3_path as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch3_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch4_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch4_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch4_path as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch4_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch5_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch5_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch5_path as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch5_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch6_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch6_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch6_path as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch6_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec1_ch1_path.
function pushbutton_sec1_ch1_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch1_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch lower(handles.image_type)
    case {'seq', 'stack'}
        selpath = uigetdir();
        if ~isequal(selpath, 0)
            set(handles.edit_sec1_ch1_path, 'String', adjust_path(selpath, 0));
        end
        if (handles.if_same_path)
            for i=2:handles.num_channels
                set(handles.(handles.channel_operator{i}{3}), 'String', get(handles.edit_sec1_ch1_path, 'String'));
            end
        end
    case 'nd2'
        handles.nd2_image_path = nd2_path(handles.nd2_image_path);
        if ~iscell(handles.nd2_image_path)
            handles.nd2_image_path = {};
        end
        switch length(handles.nd2_image_path)
            case 0
                for i=1:handles.num_channels
                    set(handles.(handles.channel_operator{i}{3}), 'String', '');
                end
            case 1
                for i=1:handles.num_channels
                    set(handles.(handles.channel_operator{i}{3}), 'String', handles.nd2_image_path{1});
                end
            otherwise
                for i=1:handles.num_channels
                    set(handles.(handles.channel_operator{i}{3}), 'String', [num2str(length(handles.nd2_image_path)), ' Folders']);
                end
        end
    otherwise
        error('pushbutton_sec1_ch1_path_Callback: unknown option.');
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch2_path.
function pushbutton_sec1_ch2_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch2_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec1_ch2_path, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch3_path.
function pushbutton_sec1_ch3_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch3_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec1_ch3_path, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch4_path.
function pushbutton_sec1_ch4_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch4_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec1_ch4_path, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch5_path.
function pushbutton_sec1_ch5_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch5_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec1_ch5_path, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch6_path.
function pushbutton_sec1_ch6_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch6_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec1_ch6_path, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

function edit_sec1_ch1_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch1_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch1_bias as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch1_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch1_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch2_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch2_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch2_bias as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch2_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch2_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch3_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch3_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch3_bias as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch3_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch3_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch4_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch4_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch4_bias as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch4_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch4_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch5_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch5_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch5_bias as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch5_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch5_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_ch6_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_ch6_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_ch6_bias as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_ch6_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_ch6_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec1_ch1_bias_select.
function pushbutton_sec1_ch1_bias_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch1_bias_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_ch1_bias, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch2_bias_select.
function pushbutton_sec1_ch2_bias_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch2_bias_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_ch2_bias, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch3_bias_select.
function pushbutton_sec1_ch3_bias_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch3_bias_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_ch3_bias, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch4_bias_select.
function pushbutton_sec1_ch4_bias_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch4_bias_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_ch4_bias, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch5_bias_select.
function pushbutton_sec1_ch5_bias_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch5_bias_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_ch5_bias, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch6_bias_select.
function pushbutton_sec1_ch6_bias_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch6_bias_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_ch6_bias, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch1_bias_delete.
function pushbutton_sec1_ch1_bias_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch1_bias_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_ch1_bias, 'String', '');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch2_bias_delete.
function pushbutton_sec1_ch2_bias_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch2_bias_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_ch2_bias, 'String', '');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch3_bias_delete.
function pushbutton_sec1_ch3_bias_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch3_bias_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_ch3_bias, 'String', '');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch4_bias_delete.
function pushbutton_sec1_ch4_bias_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch4_bias_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_ch4_bias, 'String', '');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch5_bias_delete.
function pushbutton_sec1_ch5_bias_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch5_bias_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_ch5_bias, 'String', '');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_ch6_bias_delete.
function pushbutton_sec1_ch6_bias_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_ch6_bias_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_ch6_bias, 'String', '');
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec1_ch1_cytoring.
function checkbox_sec1_ch1_cytoring_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_ch1_cytoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_ch1_cytoring

end

% --- Executes on button press in checkbox_sec1_ch2_cytoring.
function checkbox_sec1_ch2_cytoring_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_ch2_cytoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_ch2_cytoring

end

% --- Executes on button press in checkbox_sec1_ch3_cytoring.
function checkbox_sec1_ch3_cytoring_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_ch3_cytoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_ch3_cytoring

end

% --- Executes on button press in checkbox_sec1_ch4_cytoring.
function checkbox_sec1_ch4_cytoring_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_ch4_cytoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_ch4_cytoring

end

% --- Executes on button press in checkbox_sec1_ch5_cytoring.
function checkbox_sec1_ch5_cytoring_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_ch5_cytoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_ch5_cytoring

end

% --- Executes on button press in checkbox_sec1_ch6_cytoring.
function checkbox_sec1_ch6_cytoring_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_ch6_cytoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_ch6_cytoring

end

% --- Executes on button press in checkbox_sec1_path.
function checkbox_sec1_path_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_path

if (get(hObject, 'Value') == 1) % not same -> same
    handles.if_same_path = 1;
    for i=2:handles.num_channels
        set(handles.(handles.channel_operator{i}{3}), 'Enable', 'off', 'String', get(handles.(handles.channel_operator{1}{3}), 'String'));
        set(handles.(handles.channel_operator{i}{4}), 'Enable', 'off');
    end
else
    handles.if_same_path = 0;
    for i=2:handles.num_channels
        set(handles.(handles.channel_operator{i}{3}), 'Enable', 'on');
        set(handles.(handles.channel_operator{i}{4}), 'Enable', 'on');
    end
end
guidata(hObject, handles);

end

function edit_sec1_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_filename as a double

if isempty(get(hObject, 'String'))
    set(handles.pushbutton_sec1_filename_check, 'Enable', 'off');
else
    set(handles.pushbutton_sec1_filename_check, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in edit_sec1_filename_delete.
function edit_sec1_filename_delete_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_filename_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_filename, 'String', '');
set(handles.pushbutton_sec1_filename_check, 'Enable', 'off');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_filename_check.
function pushbutton_sec1_filename_check_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_filename_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

movie_definition = struct('filename_format', get(handles.edit_sec1_filename, 'String'), 'image_type', handles.image_type);
try
    [ filename_format, image_info_order ] = convert_filename_format(movie_definition);
catch
    waitfor(errordlg('Filename contains illegal operators.', 'Error'));
    return;
end
image_info = {1, 2, 3, 4, 5, 'mCherry', 'a', 'A'};
if strcmpi(handles.image_type, 'nd2')
    waitfor(msgbox({'Filename for Row 1, Column 2, Site 3, Channel 4 (mCherry), and Frame 5 starts with';
        sprintf(filename_format, image_info{image_info_order})}, 'Filename Check'));
else
    waitfor(msgbox({'Filename for Row 1, Column 2, Site 3, Channel 4 (mCherry), and Frame 5 is';
        sprintf(filename_format, image_info{image_info_order})}, 'Filename Check'));
end

end

% --- Executes on button press in pushbutton_sec1_filename_row.
function pushbutton_sec1_filename_row_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_filename_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Select representation.', 'Add Row ID', ...
    'Numeric ID', 'Letter ID (Lower)', 'Letter ID (Upper)', 'Numeric ID');
switch answer
    case 'Numeric ID'
        while 1
            answer = inputdlg('Please enter the minimal number of digits', 'Add Row ID');
            if isempty(answer)
                return;
            end
            answer = str2double(answer{1});
            if (isnan(answer) || answer ~= floor(answer) || answer < 0)
                waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
            else
                break;
            end
        end
        if (answer > 1)
            set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%0', num2str(answer), 'r']);
        else
            set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%r']);
        end
        
    case 'Letter ID (Lower)'
        set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%a']);
    case 'Letter ID (Upper)'
        set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%b']);
    otherwise
        return;
end

set(handles.pushbutton_sec1_filename_check, 'Enable', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_filename_column.
function pushbutton_sec1_filename_column_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_filename_column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% obtain input
while 1
    answer = inputdlg('Please enter the minimal number of digits', 'Add Column ID');
    if isempty(answer)
        return;
    end
    answer = str2double(answer{1});
    if (isnan(answer) || answer ~= floor(answer) || answer < 0)
        waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
    else
        break;
    end
end

% add string
if (answer > 1)
    set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%0', num2str(answer), 'c']);
else
    set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%c']);
end
set(handles.pushbutton_sec1_filename_check, 'Enable', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_filename_site.
function pushbutton_sec1_filename_site_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_filename_site (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% obtain input
while 1
    answer = inputdlg('Please enter the minimal number of digits', 'Add Site ID');
    if isempty(answer)
        return;
    end
    answer = str2double(answer{1});
    if (isnan(answer) || answer ~= floor(answer) || answer < 0)
        waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
    else
        break;
    end
end

% add string
if (answer > 1)
    set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%0', num2str(answer), 's']);
else
    set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%s']);
end
set(handles.pushbutton_sec1_filename_check, 'Enable', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_filename_frame.
function pushbutton_sec1_filename_frame_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_filename_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% obtain input
while 1
    answer = inputdlg('Please enter the minimal number of digits', 'Add Frame ID');
    if isempty(answer)
        return;
    end
    answer = str2double(answer{1});
    if (isnan(answer) || answer ~= floor(answer) || answer < 0)
        waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
    else
        break;
    end
end

% add string
if (answer > 1)
    set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%0', num2str(answer), 't']);
else
    set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%t']);
end

set(handles.pushbutton_sec1_filename_check, 'Enable', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_filename_channel.
function pushbutton_sec1_filename_channel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_filename_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = questdlg('Select representation.', 'Add Channel', ...
    'Channel ID', 'Channel Name', 'Channel Name');
switch answer
    case 'Channel ID'
        while 1
            answer = inputdlg('Please enter the minimal number of digits', 'Add Channel ID');
            if isempty(answer)
                return;
            end
            answer = str2double(answer{1});
            if (isnan(answer) || answer ~= floor(answer) || answer < 0)
                waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
            else
                break;
            end
        end
        if (answer > 1)
            set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%0', num2str(answer), 'i']);
        else
            set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%i']);
        end
        
    case 'Channel Name'
        set(handles.edit_sec1_filename, 'String', [get(handles.edit_sec1_filename, 'String'), '%n']);
    otherwise
        return;
end

set(handles.pushbutton_sec1_filename_check, 'Enable', 'on');
guidata(hObject, handles);

end

%% MOVIE DEFINITION, PAGE 2
function edit_sec1_row_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_row_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structurex with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_row_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_row_from as a double

hObject = check_number_value(hObject, 'pos_int', []);
handles = swap_from_to(handles, 'edit_sec1_row_from', 'edit_sec1_row_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_row_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_row_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_row_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_row_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_row_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_row_to as a double

hObject = check_number_value(hObject, 'pos_int', []);
handles = swap_from_to(handles, 'edit_sec1_row_from', 'edit_sec1_row_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_row_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_row_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_column_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_column_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_column_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_column_from as a double

hObject = check_number_value(hObject, 'pos_int', []);
handles = swap_from_to(handles, 'edit_sec1_column_from', 'edit_sec1_column_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_column_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_column_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_column_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_column_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_column_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_column_to as a double

hObject = check_number_value(hObject, 'pos_int', []);
handles = swap_from_to(handles, 'edit_sec1_column_from', 'edit_sec1_column_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_column_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_column_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_site_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_site_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_site_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_site_from as a double

hObject = check_number_value(hObject, 'pos_int', []);
handles = swap_from_to(handles, 'edit_sec1_site_from', 'edit_sec1_site_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_site_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_site_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_site_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_site_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_site_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_site_to as a double

hObject = check_number_value(hObject, 'pos_int', []);
handles = swap_from_to(handles, 'edit_sec1_site_from', 'edit_sec1_site_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_site_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_site_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in checkbox_sec1_well.
function checkbox_sec1_well_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec1_well (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec1_well

entries = {'edit_sec1_row_from', 'edit_sec1_row_to', 'edit_sec1_column_from', ...
    'edit_sec1_column_to', 'edit_sec1_site_from', 'edit_sec1_site_to', ...
    'edit_sec1_extract_row', 'edit_sec1_extract_column', 'edit_sec1_extract_site', ...
    'edit_sec3_axes_row', 'edit_sec3_axes_column', 'edit_sec3_axes_site'};
entries = matlab.lang.makeValidName(entries);
if get(hObject, 'Value') == 1
    val = 'off';
else
    val = 'on';
end
for i=1:length(entries)
    set(handles.(entries{i}), 'Enable', val);
end
guidata(hObject, handles);

end

function edit_sec1_frame_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_frame_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_frame_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_frame_from as a double

hObject = check_number_value(hObject, 'nonneg_int', []);
handles = swap_from_to(handles, 'edit_sec1_frame_from', 'edit_sec1_frame_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_frame_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_frame_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_frame_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_frame_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_frame_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_frame_to as a double

hObject = check_number_value(hObject, 'nonneg_int', []);
handles = swap_from_to(handles, 'edit_sec1_frame_from', 'edit_sec1_frame_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_frame_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_frame_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_cmos_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_cmos as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_cmos as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_cmos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec1_cmos_select.
function pushbutton_sec1_cmos_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_cmos_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile('*.mat;*.MAT');
if ~isequal(file, 0)
    set(handles.edit_sec1_cmos, 'String', adjust_path(fullfile(path,file), 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_delete.
function pushbutton_sec1_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_sec1_cmos, 'String', '');
guidata(hObject, handles);

end

function edit_sec1_core_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_core (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_core as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_core as a double

val = str2double(get(hObject, 'String'));
if (isnan(val) || ~ismember(val, 1:handles.max_cores))
    waitfor(errordlg('Invalid value. Please enter an integer between 1 and the maximal number of cores.','Error'));
    set(hObject, 'String', '1');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_core_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_core (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_extract_row_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_extract_row as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_extract_row as a double

hObject = check_number_value(hObject, 'pos_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_extract_row_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_extract_column_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_extract_column as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_extract_column as a double

hObject = check_number_value(hObject, 'pos_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_extract_column_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_extract_site_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_site (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_extract_site as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_extract_site as a double

hObject = check_number_value(hObject, 'pos_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_extract_site_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_site (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_extract_frame_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_frame_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_extract_frame_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_extract_frame_from as a double

hObject = check_number_value(hObject, 'nonneg_int', []);
handles = swap_from_to(handles, 'edit_sec1_extract_frame_from', 'edit_sec1_extract_frame_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_extract_frame_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_frame_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_extract_frame_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_frame_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_extract_frame_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_extract_frame_to as a double

hObject = check_number_value(hObject, 'nonneg_int', []);
handles = swap_from_to(handles, 'edit_sec1_extract_frame_from', 'edit_sec1_extract_frame_to');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_extract_frame_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_frame_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec1_extract_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec1_extract_path as text
%        str2double(get(hObject,'String')) returns contents of edit_sec1_extract_path as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec1_extract_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec1_extract_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec1_extract_path.
function pushbutton_sec1_extract_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_extract_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec1_extract_path, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec1_extract.
function pushbutton_sec1_extract_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec1_extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get row, col, site id
switch lower(get(handles.edit_sec1_extract_row, 'Enable'))
    case 'on'
        row_id = str2double(get(handles.edit_sec1_extract_row, 'String'));
        col_id = str2double(get(handles.edit_sec1_extract_column, 'String'));
        site_id = str2double(get(handles.edit_sec1_extract_site, 'String'));
    case 'off'
        row_id = 1; col_id = 1; site_id = 1;
end
frame_from = str2double(get(handles.edit_sec1_extract_frame_from, 'String'));
frame_to = str2double(get(handles.edit_sec1_extract_frame_to, 'String'));
if (isnan(row_id) || isnan(col_id) || isnan(site_id) || isnan(frame_from) || isnan(frame_to))
    waitfor(errordlg('Row, Column, Site, and/or Frame ID is not defined.','Error'));
    return;
end

% examine path
if (isempty(get(handles.edit_sec1_extract_path, 'String')))
    waitfor(errordlg('Undefined folder to store extracted images.','Error'));
    return;
end

% get nd2 frame range and bfReaders
f = waitbar(0, 'Extract Images'); pause(0.01);
try
    % get nd2_frame_range and bfReaders
    [ nd2_frame_range, all_bfReaders ] = get_nd2_frame_range(handles, row_id, col_id);
catch
    close(f);
    waitfor(errordlg('Unable to read ND2 files.','Error'));
    return;
end

% examine whether Frame ID is valid
if (frame_from < min(nd2_frame_range(:)) || frame_to > max(nd2_frame_range(:)))
    close(f);
    waitfor(errordlg('Input Frame IDs is beyond the range of ND2 files.','Error'));
    return;
end

% write images
try
    % extract image
    channel_name = get(handles.edit_sec1_ch1_channel, 'String');
    for i=frame_from:frame_to
        % update progress bar
        waitbar((i-frame_from+1)/(frame_to-frame_from+1), f);
        pause(0.01);
        
        % determine channel id
        reader_id = find(i>=nd2_frame_range(:,1) & i<=nd2_frame_range(:,2), 1);
        channel_id = [];
        for j=1:length(all_bfReaders{row_id, col_id}{reader_id}.channelNames)
            if (strcmpi(all_bfReaders{row_id, col_id}{reader_id}.channelNames{j}, channel_name))
                channel_id = j;
                break;
            end
        end
        if (isempty(channel_id))
            close(f);
            waitfor(errordlg('Nuclear channel not found.','Error'));
            return;
        end

        % save image
        I = all_bfReaders{row_id, col_id}{reader_id}.getXYplane(channel_id, site_id, i-nd2_frame_range(reader_id,1)+1);
        imwrite(I, [get(handles.edit_sec1_extract_path, 'String'), num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', channel_name, '_', num2str(i), '.tif']);
    end
    close(f);
    waitfor(msgbox(['Extraction completed. Type the filename ', num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', channel_name, '_%t.tif in Training Data Generator GUI.']))
catch
    close(f);
    waitfor(errordlg('Image not found.','Error'));
    return;
end

end

%% INPUT/OUTPUT
function edit_sec2_training_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec2_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec2_training as text
%        str2double(get(hObject,'String')) returns contents of edit_sec2_training as a double

hObject = check_path_name(hObject);
handles.curr_training_path = {get(hObject, 'String')};
if isempty(get(hObject, 'String'))
    set(handles.pushbutton_sec2_training_load_add, 'Enable', 'off');
else
    set(handles.pushbutton_sec2_training_load_add, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec2_training_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec2_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_training_select.
function pushbutton_sec2_training_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_training_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat;*.MAT', 'MultiSelect', 'on');
if ~isequal(file, 0)
    if (iscell(file)) % multiple files selected
        set(handles.edit_sec2_training, 'String', [num2str(length(file)), ' Files Selected'], 'Enable', 'off');
        handles.curr_training_path = adjust_path(fullfile(path, file)', 0);
    else
        set(handles.edit_sec2_training, 'String', adjust_path(fullfile(path, file), 0), 'Enable', 'on');
        handles.curr_training_path = {adjust_path(fullfile(path, file), 0)};
    end
    set(handles.pushbutton_sec2_training_load_add, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec2_training_load_delete.
function pushbutton_sec2_training_load_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_training_load_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_training_path = {};
set(handles.edit_sec2_training, 'String', '', 'Enable', 'on');
set(handles.pushbutton_sec2_training_load_add, 'Enable', 'off');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec2_training_load_add.
function pushbutton_sec2_training_load_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_training_load_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% add training data
num_entries = length(handles.curr_training_path);
if_dup = zeros(num_entries, 1);
for i=1:num_entries
    if_dup(i) = any(cellfun(@(x) isequal(x, handles.curr_training_path{i}), handles.all_training_path));
end
if all(if_dup)
    waitfor(errordlg('Training datasets have been imported.', 'Error'));
    return;
elseif any(if_dup)
    waitfor(warndlg('Some training datasets have been imported.', 'Error'));
    handles.curr_training_path = handles.curr_training_path(~if_dup);
end

if isempty(handles.all_training_path)
    handles.all_training_path = handles.curr_training_path;
else
    handles.all_training_path = cat(1, handles.all_training_path, handles.curr_training_path);
end
set(handles.listbox_sec2_training, 'String', handles.all_training_path, 'Value', length(handles.all_training_path));

% resume to initial state
handles.curr_training_path = {};
set(handles.edit_sec2_training, 'String', '', 'Enable', 'on');
set(hObject, 'Enable', 'off');
guidata(hObject, handles);

end

% --- Executes on selection change in listbox_sec2_training.
function listbox_sec2_training_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_sec2_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_sec2_training contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_sec2_training

if (isempty(get(hObject, 'String')))
    return;
end
set(handles.pushbutton_sec2_training_delete, 'Enable', 'on');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function listbox_sec2_training_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_sec2_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_training_delete.
function pushbutton_sec2_training_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_training_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.listbox_sec2_training, 'Value');
handles.all_training_path = handles.all_training_path([1:val-1, val+1:length(handles.all_training_path)]);
if ~isempty(handles.all_training_path)
    set(handles.listbox_sec2_training, 'String', handles.all_training_path, 'Value', max(1,val-1));
else
    set(handles.listbox_sec2_training, 'String', handles.all_training_path, 'Value', []);
    set(hObject, 'Enable', 'off');
end
guidata(hObject, handles);

end

function edit_sec2_output_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec2_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec2_output as text
%        str2double(get(hObject,'String')) returns contents of edit_sec2_output as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec2_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec2_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_output.
function pushbutton_sec2_output_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec2_output, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec2_output.
function checkbox_sec2_output_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec2_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec2_output

end

function edit_sec2_mask_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec2_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec2_mask as text
%        str2double(get(hObject,'String')) returns contents of edit_sec2_mask as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec2_mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec2_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_mask.
function pushbutton_sec2_mask_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec2_mask, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec2_mask.
function checkbox_sec2_mask_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec2_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec2_mask

if (get(hObject, 'Value') == 1)
    set(handles.edit_sec2_mask, 'Enable', 'on');
    set(handles.pushbutton_sec2_mask, 'Enable', 'on');
else
    set(handles.edit_sec2_mask, 'Enable', 'off');
    set(handles.pushbutton_sec2_mask, 'Enable', 'off');
end
guidata(hObject, handles);

end

function edit_sec2_ellipse_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec2_ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec2_ellipse as text
%        str2double(get(hObject,'String')) returns contents of edit_sec2_ellipse as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec2_ellipse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec2_ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_ellipse.
function pushbutton_sec2_ellipse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec2_ellipse, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec2_ellipse.
function checkbox_sec2_ellipse_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec2_ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec2_ellipse

if (get(hObject, 'Value') == 1)
    set(handles.edit_sec2_ellipse, 'Enable', 'on');
    set(handles.pushbutton_sec2_ellipse, 'Enable', 'on');
else
    set(handles.edit_sec2_ellipse, 'Enable', 'off');
    set(handles.pushbutton_sec2_ellipse, 'Enable', 'off');
end
guidata(hObject, handles);

end

function edit_sec2_seginfo_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec2_seginfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec2_seginfo as text
%        str2double(get(hObject,'String')) returns contents of edit_sec2_seginfo as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec2_seginfo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec2_seginfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_seginfo.
function pushbutton_sec2_seginfo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_seginfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec2_seginfo, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec2_seginfo.
function checkbox_sec2_seginfo_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec2_seginfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec2_seginfo

if (get(hObject, 'Value') == 1)
    set(handles.edit_sec2_seginfo, 'Enable', 'on');
    set(handles.pushbutton_sec2_seginfo, 'Enable', 'on');
else
    set(handles.edit_sec2_seginfo, 'Enable', 'off');
    set(handles.pushbutton_sec2_seginfo, 'Enable', 'off');
end
guidata(hObject, handles);

end

function edit_sec2_vistrack_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec2_vistrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec2_vistrack as text
%        str2double(get(hObject,'String')) returns contents of edit_sec2_vistrack as a double

hObject = check_path_name(hObject);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec2_vistrack_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec2_vistrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec2_vistrack.
function pushbutton_sec2_vistrack_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec2_vistrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_sec2_vistrack, 'String', adjust_path(selpath, 0));
end
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec2_vistrack.
function checkbox_sec2_vistrack_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec2_vistrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec2_vistrack

if (get(hObject, 'Value') == 1)
    set(handles.edit_sec2_vistrack, 'Enable', 'on');
    set(handles.pushbutton_sec2_vistrack, 'Enable', 'on');
else
    set(handles.edit_sec2_vistrack, 'Enable', 'off');
    set(handles.pushbutton_sec2_vistrack, 'Enable', 'off');
end
guidata(hObject, handles);

end

%% SEGMENTATION
function edit_sec3_axes_row_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_axes_row as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_axes_row as a double

hObject = check_number_value(hObject, 'pos_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_axes_row_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_row (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_axes_column_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_axes_column as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_axes_column as a double

hObject = check_number_value(hObject, 'pos_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_axes_column_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_column (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_axes_site_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_site (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_axes_site as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_axes_site as a double

hObject = check_number_value(hObject, 'pos_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_axes_site_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_site (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_axes_frame_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_axes_frame as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_axes_frame as a double

hObject = check_number_value(hObject, 'nonneg_int', []);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_axes_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_axes_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_axes_load.
function pushbutton_sec3_axes_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_axes_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = waitbar(0, 'Loading Image.'); pause(0.01);

% get row, col, site, frame ID
switch lower(get(handles.edit_sec3_axes_row, 'Enable'))
    case 'on'
        row_id = str2double(get(handles.edit_sec3_axes_row, 'String'));
        col_id = str2double(get(handles.edit_sec3_axes_column, 'String'));
        site_id = str2double(get(handles.edit_sec3_axes_site, 'String'));
    case 'off'
        row_id = 1;
        col_id = 1;
        site_id = 1;
end
frame_id = str2double(get(handles.edit_sec3_axes_frame, 'String'));
if (isnan(row_id) || isnan(col_id) || isnan(site_id) || isnan(frame_id))
    close(f);
    waitfor(errordlg('Row, Column, Site, and/or Frame ID is not defined.','Error'));
    return;
end

% get path and filename
image_path = get(handles.edit_sec1_ch1_path, 'String');
filename_format = get(handles.edit_sec1_filename, 'String');
if (isempty(image_path) || isempty(filename_format))
    close(f);
    waitfor(errordlg('Image path and/or filename is not defined.', 'Error'));
    return;
end

% get cmosoffset and nuclear bias
try
    h = load(get(handles.edit_sec1_cmos, 'String')); cmosoffset = h.cmosoffset;
catch
    if (~isempty(get(handles.edit_sec1_cmos, 'String')))
        waitfor(warndlg('Fail to load cmosoffset. Will not correct camera dark noise.', 'Warning'));
    end
    cmosoffset = 0;
end
try
    h = load(get(handles.edit_sec1_ch1_bias, 'String')); bias = h.bias;
catch
    if (~isempty(get(handles.edit_sec1_ch1_bias, 'String')))
        waitfor(warndlg('Fail to load bias for the nuclear channel. Will not correct illumination bias.', 'Warning'));
    end
    bias = 1;
end

% load image
try
    [filename_format, image_info_order] = convert_filename_format(struct('filename_format', filename_format, 'image_type', handles.image_type));
    image_info = {row_id, col_id, site_id, 1, frame_id};
    
    switch lower(handles.image_type)
        case {'seq', 'stack'}
            movie_definition = struct('image_type', handles.image_type, 'channel_names', {{get(handles.edit_sec1_ch1_channel, 'String')}}, ...
                'image_path', {{image_path}}, 'filename_format', filename_format, 'image_info_order', image_info_order);
            I = read_image( movie_definition, image_info, cmosoffset, bias );
       
        case 'nd2'
            % get nd2_frame_range and bfReaders
            [ nd2_frame_range, all_bfReaders ] = get_nd2_frame_range(handles, row_id, col_id);
            if (frame_id < min(nd2_frame_range(:)) || frame_id > max(nd2_frame_range(:)))
                close(f);
                waitfor(errordlg('Input Frame ID is beyond the range of ND2 files.','Error'));
                return;
            end
            
            % read image
            movie_definition = struct('image_type', handles.image_type, 'channel_names', {{get(handles.edit_sec1_ch1_channel, 'String')}}, ...
                'image_path', {handles.nd2_image_path}, 'filename_format', filename_format, 'image_info_order', image_info_order, ...
                'nd2_frame_range', nd2_frame_range, 'nd2_readers', {all_bfReaders});
            I = read_image( movie_definition, image_info, cmosoffset, bias );
            
        otherwise
            error('pushbutton_sec3_axes_load_Callback: unknown option.');
    end
    
    if (isempty(get(handles.edit_sec3_intensity_from, 'String')))
        set(handles.edit_sec3_intensity_from, 'String', num2str(round(min(min(I)))), 'Enable', 'on');
    end
    if (isempty(get(handles.edit_sec3_intensity_to, 'String')))
        set(handles.edit_sec3_intensity_to, 'String', num2str(round(max(max(I)))), 'Enable', 'on');
    end
catch
    close(f);
    waitfor(errordlg('Image can not be loaded.', 'Error'));
    return;
end
close(f);

% process data until current page
if (isempty(handles.seg_raw_image))
    handles.seg_disp_step = 1;
end
handles.seg_raw_image = I;
handles.seg_curr_calculated_step = 0;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

function edit_sec3_intensity_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_intensity_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_intensity_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_intensity_from as a double

hObject = check_number_value(hObject, 'nonneg_real', round(min(min(handles.seg_raw_image))));
handles = swap_from_to( handles, 'edit_sec3_intensity_from', 'edit_sec3_intensity_to' );
handles = display_seg_step( handles );
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_intensity_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_intensity_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_intensity_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_intensity_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_intensity_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_intensity_to as a double

hObject = check_number_value(hObject, 'nonneg_real', round(max(max(handles.seg_raw_image))));
handles = swap_from_to( handles, 'edit_sec3_intensity_from', 'edit_sec3_intensity_to' );
handles = display_seg_step( handles );
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_intensity_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_intensity_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_nav_nonspec.
function pushbutton_sec3_nav_nonspec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nav_nonspec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 1;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end


function edit_sec3_nonspec_nucradius_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_nucradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_nucradius as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_nucradius as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.nuc_radius);
handles.seg_para.nonspecific_para.nuc_radius = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_nucradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_nucradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_nucarea_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_nucarea_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_nucarea_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_nucarea_from as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.allowed_nuc_size(1));
handles.seg_para.nonspecific_para.allowed_nuc_size(1) = str2double(get(hObject, 'String'));
handles = swap_from_to( handles, 'edit_sec3_nonspec_nucarea_from', 'edit_sec3_nonspec_nucarea_to' );
handles.seg_para.nonspecific_para.allowed_nuc_size = sort(handles.seg_para.nonspecific_para.allowed_nuc_size);
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_nucarea_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_nucarea_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_nucarea_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_nucarea_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_nucarea_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_nucarea_to as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.allowed_nuc_size(2));
handles.seg_para.nonspecific_para.allowed_nuc_size(2) = str2double(get(hObject, 'String'));
handles = swap_from_to( handles, 'edit_sec3_nonspec_nucarea_from', 'edit_sec3_nonspec_nucarea_to' );
handles.seg_para.nonspecific_para.allowed_nuc_size = sort(handles.seg_para.nonspecific_para.allowed_nuc_size);
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_nucarea_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_nucarea_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_elliparea_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_elliparea_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_elliparea_from as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_elliparea_from as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.allowed_ellipse_size(1));
handles.seg_para.nonspecific_para.allowed_ellipse_size(1) = str2double(get(hObject, 'String'));
handles = swap_from_to( handles, 'edit_sec3_nonspec_elliparea_from', 'edit_sec3_nonspec_elliparea_to' );
handles.seg_para.nonspecific_para.allowed_ellipse_size = sort(handles.seg_para.nonspecific_para.allowed_ellipse_size);
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_elliparea_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_elliparea_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_elliparea_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_elliparea_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_elliparea_to as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_elliparea_to as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.allowed_ellipse_size(2));
handles.seg_para.nonspecific_para.allowed_ellipse_size(2) = str2double(get(hObject, 'String'));
handles = swap_from_to( handles, 'edit_sec3_nonspec_elliparea_from', 'edit_sec3_nonspec_elliparea_to' );
handles.seg_para.nonspecific_para.allowed_ellipse_size = sort(handles.seg_para.nonspecific_para.allowed_ellipse_size);
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_elliparea_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_elliparea_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_aspect_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_aspect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_aspect as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_aspect as a double

hObject = check_number_value(hObject, 'greaterequal1', handles.seg_para.nonspecific_para.max_ellipse_aspect_ratio);
handles.seg_para.nonspecific_para.max_ellipse_aspect_ratio = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_aspect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_aspect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_hole_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_hole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_hole as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_hole as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.max_hole_size_to_fill);
handles.seg_para.nonspecific_para.max_hole_size_to_fill = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_hole_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_hole (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_nonspec_blur_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_blur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_nonspec_blur as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_nonspec_blur as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.nonspecific_para.blur_radius);
handles.seg_para.nonspecific_para.blur_radius = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = 0;
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_nonspec_blur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_nonspec_blur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_nonspec_next.
function pushbutton_sec3_nonspec_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nonspec_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 2;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_nav_binarization.
function pushbutton_sec3_nav_binarization_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nav_binarization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 2;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec3_binarization_log.
function checkbox_sec3_binarization_log_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec3_binarization_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec3_binarization_log

handles.seg_para.image_binarization_para.if_log = get(hObject, 'Value');
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 1);
guidata(hObject, handles);

end

% --- Executes on selection change in popupmenu_sec3_binarization_bgsub.
function popupmenu_sec3_binarization_bgsub_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sec3_binarization_bgsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sec3_binarization_bgsub contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sec3_binarization_bgsub

switch get(hObject, 'Value')
    case 1
        handles.seg_para.image_binarization_para.background_subtraction_method = 'none';
    case 2
        handles.seg_para.image_binarization_para.background_subtraction_method = 'min';
    case 3
        handles.seg_para.image_binarization_para.background_subtraction_method = 'mean';
    case 4
        handles.seg_para.image_binarization_para.background_subtraction_method = 'median';
    otherwise
        error('popupmenu_sec3_binarization_bgsub_Callback: unknown option.');
end
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function popupmenu_sec3_binarization_bgsub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sec3_binarization_bgsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on selection change in popupmenu_sec3_binarization_method.
function popupmenu_sec3_binarization_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sec3_binarization_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sec3_binarization_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sec3_binarization_method

if (get(hObject, 'Value') == 1) % Thresholding
    set(handles.edit_sec3_binarization_threshold, 'Enable', 'off');
    handles.seg_para.image_binarization_para.binarization_method = 'threshold';
else
    set(handles.edit_sec3_binarization_threshold, 'Enable', 'on');
    handles.seg_para.image_binarization_para.binarization_method = 'blob';
end
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function popupmenu_sec3_binarization_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sec3_binarization_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_binarization_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_binarization_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_binarization_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_binarization_threshold as a double

hObject = check_number_value(hObject, 'neg_real', handles.seg_para.image_binarization_para.blob_threshold);
handles.seg_para.image_binarization_para.blob_threshold = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 1);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_binarization_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_binarization_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_binarization_update.
function pushbutton_sec3_binarization_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_binarization_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 2;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_binarization_next.
function pushbutton_sec3_binarization_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_binarization_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 3;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_nav_activecontour.
function pushbutton_sec3_nav_activecontour_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nav_activecontour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 3;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec3_activecontour_ifrun.
function checkbox_sec3_activecontour_ifrun_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec3_activecontour_ifrun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec3_activecontour_ifrun

if (get(hObject, 'Value') == 1)
    set(handles.checkbox_sec3_activecontour_log, 'Enable', 'on');
    set(handles.popupmenu_sec3_activecontour_method, 'Enable', 'on');
    handles.seg_para.active_contour_para.if_run = 1;
else
    set(handles.checkbox_sec3_activecontour_log, 'Enable', 'off');
    set(handles.popupmenu_sec3_activecontour_method, 'Enable', 'off');
    handles.seg_para.active_contour_para.if_run = 0;
end
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 2);
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec3_activecontour_log.
function checkbox_sec3_activecontour_log_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec3_activecontour_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec3_activecontour_log

handles.seg_para.active_contour_para.if_log = get(hObject, 'Value');
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 2);
guidata(hObject, handles);

end

% --- Executes on selection change in popupmenu_sec3_activecontour_method.
function popupmenu_sec3_activecontour_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_sec3_activecontour_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_sec3_activecontour_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_sec3_activecontour_method

switch (get(hObject, 'Value'))
    case 1
        handles.seg_para.active_contour_para.active_contour_method = 'local';
    case 2
        handles.seg_para.active_contour_para.active_contour_method = 'global';
    otherwise
        error('popupmenu_sec3_activecontour_method_Callback: unknown option.');
end
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 2);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function popupmenu_sec3_activecontour_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_sec3_activecontour_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_activecontour_update.
function pushbutton_sec3_activecontour_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_activecontour_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 3;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_activecontour_next.
function pushbutton_sec3_activecontour_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_activecontour_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 4;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_nav_watershed.
function pushbutton_sec3_nav_watershed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nav_watershed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 4;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec3_watershed_ifrun.
function checkbox_sec3_watershed_ifrun_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec3_watershed_ifrun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec3_watershed_ifrun

handles.seg_para.watershed_para.if_run = get(hObject, 'Value');
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 3);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_watershed_update.
function pushbutton_sec3_watershed_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_watershed_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 4;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_watershed_next.
function pushbutton_sec3_watershed_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_watershed_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 5;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_nav_ellipse.
function pushbutton_sec3_nav_ellipse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nav_ellipse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 5;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

function edit_sec3_ellipse_thd2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_thd2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_thd2 as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_thd2 as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.thd2);
handles.seg_para.ellipse_para.thd2 = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_thd2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_thd2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_k_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_k as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_k as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.k);
handles.seg_para.ellipse_para.k = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_k_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_k (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_thd1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_thd1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_thd1 as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_thd1 as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.thd1);
handles.seg_para.ellipse_para.thd1 = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_thd1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_thd1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_thdn_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_thdn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_thdn as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_thdn as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.thdn);
handles.seg_para.ellipse_para.thdn = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_thdn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_thdn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_C_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_C as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_C as a double

hObject = check_number_value(hObject, 'greaterequal1', handles.seg_para.ellipse_para.C);
handles.seg_para.ellipse_para.C = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_sig_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_sig as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_sig as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.sig);
handles.seg_para.ellipse_para.sig = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_sig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_sig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_Tangle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_Tangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_Tangle as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_Tangle as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.T_angle);
handles.seg_para.ellipse_para.T_angle = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_Tangle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_Tangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_endpoint_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_endpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_endpoint as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_endpoint as a double

hObject = check_number_value(hObject, 'binary', handles.seg_para.ellipse_para.Endpoint);
handles.seg_para.ellipse_para.Endpoint = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_endpoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_endpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec3_ellipse_gapsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_gapsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_ellipse_gapsize as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_ellipse_gapsize as a double

hObject = check_number_value(hObject, 'pos_int', handles.seg_para.ellipse_para.Gap_size);
handles.seg_para.ellipse_para.Gap_size = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 4);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_ellipse_gapsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_ellipse_gapsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_ellipse_update.
function pushbutton_sec3_ellipse_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_ellipse_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 5;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_ellipse_next.
function pushbutton_sec3_ellipse_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_ellipse_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 6;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_sec3_nav_correction.
function pushbutton_sec3_nav_correction_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_nav_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 6;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

% --- Executes on button press in checkbox_sec3_correction_ifrun.
function checkbox_sec3_correction_ifrun_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sec3_correction_ifrun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sec3_correction_ifrun

if (get(hObject, 'Value') == 1)
    set(handles.edit_sec3_correction_minprob, 'Enable', 'on');
    handles.seg_para.seg_correction_para.if_run = 1;
else
    set(handles.edit_sec3_correction_minprob, 'Enable', 'off');
    handles.seg_para.seg_correction_para.if_run = 0;
end
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 5);
guidata(hObject, handles);

end

function edit_sec3_correction_minprob_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec3_correction_minprob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec3_correction_minprob as text
%        str2double(get(hObject,'String')) returns contents of edit_sec3_correction_minprob as a double

hObject = check_number_value(hObject, 'zeroone', handles.seg_para.seg_correction_para.min_corr_prob);
handles.seg_para.seg_correction_para.min_corr_prob = str2double(get(hObject, 'String'));
handles.seg_curr_calculated_step = min(handles.seg_curr_calculated_step, 5);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec3_correction_minprob_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec3_correction_minprob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec3_correction_update.
function pushbutton_sec3_correction_update_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec3_correction_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.seg_disp_step = 6;
handles = process_seg_step(handles);
handles = switch_seg_step(handles);
guidata(hObject, handles);

end

%% PREDICTION OF EVENTS, PAGE 1
% --- Executes on button press in radiobutton_sec4_speed_global.
function radiobutton_sec4_speed_global_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec4_speed_global (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec4_speed_global

set(handles.edit_sec4_speed_custom, 'Enable', 'off');
set(handles.pushbutton_sec4_speed, 'Enable', 'on');
set(handles.edit_sec4_inf_resolution, 'Enable', 'off');
set(handles.edit_sec4_inf_sample, 'Enable', 'off');
handles.migration_speed = 'global';
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec4_speed_time.
function radiobutton_sec4_speed_time_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec4_speed_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec4_speed_time

set(handles.edit_sec4_speed_custom, 'Enable', 'off');
set(handles.pushbutton_sec4_speed, 'Enable', 'on');
set(handles.edit_sec4_inf_resolution, 'Enable', 'on');
set(handles.edit_sec4_inf_sample, 'Enable', 'on');
handles.migration_speed = 'time';
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec4_speed_density.
function radiobutton_sec4_speed_density_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec4_speed_density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec4_speed_density

set(handles.edit_sec4_speed_custom, 'Enable', 'off');
set(handles.pushbutton_sec4_speed, 'Enable', 'on');
set(handles.edit_sec4_inf_resolution, 'Enable', 'on');
set(handles.edit_sec4_inf_sample, 'Enable', 'on');
handles.migration_speed = 'density';
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_sec4_speed_custom.
function radiobutton_sec4_speed_custom_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sec4_speed_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sec4_speed_custom

set(handles.edit_sec4_speed_custom, 'Enable', 'on');
set(handles.pushbutton_sec4_speed, 'Enable', 'off');
set(handles.edit_sec4_inf_resolution, 'Enable', 'off');
set(handles.edit_sec4_inf_sample, 'Enable', 'off');
handles.migration_speed = 'custom';
guidata(hObject, handles);

end

function edit_sec4_speed_custom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_speed_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_speed_custom as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_speed_custom as a double

hObject = check_number_value(hObject, 'pos_real', 10);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_speed_custom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_speed_custom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec4_migfold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_migfold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_migfold as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_migfold as a double

hObject = check_number_value(hObject, 'pos_real', handles.prob_para.max_migration_dist_fold);
handles.prob_para.max_migration_dist_fold = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_migfold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_migfold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec4_inf_resolution_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_inf_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_inf_resolution as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_inf_resolution as a double


hObject = check_number_value(hObject, 'pos_real', handles.prob_para.migration_inference_resolution);
handles.prob_para.migration_inference_resolution = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_inf_resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_inf_resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec4_inf_sample_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_inf_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_inf_sample as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_inf_sample as a double

hObject = check_number_value(hObject, 'pos_int', handles.prob_para.migration_inference_min_samples);
handles.prob_para.migration_inference_min_samples = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_inf_sample_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_inf_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_sec4_speed.
function pushbutton_sec4_speed_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sec4_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% gather information
mig_fold = str2double(get(handles.edit_sec4_migfold, 'String'));
inf_res = str2double(get(handles.edit_sec4_inf_resolution, 'String'));
inf_sample = str2double(get(handles.edit_sec4_inf_sample, 'String'));

% gather training data
if (isempty(handles.all_training_path))
    waitfor(errordlg('Training datasets are not provided.','Error'));
    return;
end
f = waitbar(0, 'Processing');
all_training_data = cell(length(handles.all_training_path), 1);
time_range = [Inf, -Inf];
for i=1:length(handles.all_training_path)
    try
        all_training_data{i} = load(handles.all_training_path{i});
        time_range(1) = min(time_range(1), min(all_training_data{i}.imported_frame_id));
        time_range(2) = max(time_range(2), max(all_training_data{i}.imported_frame_id));
    catch
        close(f);
        waitfor(errordlg(['Training dataset ', handles.all_training_path{i}, ' can not be loaded.'], 'Error'));
        return;
    end
end
training_data_size_image = all_training_data{1}.size_image;

% make inference for each case, make plot
waitbar(0.5, f);
switch lower(handles.migration_speed)
    case 'global'
        [ dist_x, dist_y, dist_t ] = aggr_training_data( all_training_data, 'global', training_data_size_image, mig_fold );
        global_sigma = infer_migration_sigma( dist_x, dist_y, dist_t, training_data_size_image );
        
        % plot
        set(handles.axes_sec4_speed, 'Visible', 'on'); cla(handles.axes_sec4_speed); 
        axes(handles.axes_sec4_speed); hold(handles.axes_sec4_speed, 'on');
        histogram([abs(dist_x./sqrt(dist_t)); abs(dist_y./sqrt(dist_t))]); 
        xlim([0, round(1.1*max([abs(dist_x./sqrt(dist_t)); abs(dist_y./sqrt(dist_t))]))]);
        plot([global_sigma, global_sigma], get(handles.axes_sec4_speed, 'ylim'), 'k', 'linewidth', 2);
        xlabel('Migration Speed (Pixels/Frame)'); ylabel('Counts');
        legend('Training Data', ['Inferred: ', sprintf('%.2f', global_sigma)]);
        hold(handles.axes_sec4_speed, 'off');
        
    case 'time'
        [ dist_x, dist_y, dist_t, axis_id ] = aggr_training_data( all_training_data, 'time', training_data_size_image, mig_fold );
        density_val_start_id = str2double(get(handles.edit_sec1_frame_from, 'String'));
        density_val_end_id = str2double(get(handles.edit_sec1_frame_to, 'String'));
        if isnan(density_val_start_id) || isnan(density_val_end_id)
            waitfor(warndlg('Frames to track were not defined. Inference results might be inaccurate.', 'Warning'));
            gap_time = round(0.1*sum(time_range));
            density_val = max(1, round(time_range(1)-gap_time)):round(time_range(2)+gap_time);
        else
            density_val = density_val_start_id:density_val_end_id;
        end
        [sigma_val, errmsg] = infer_migration_sigma_axis( dist_x, dist_y, dist_t, axis_id, density_val, training_data_size_image, inf_res, inf_sample );
    
        % skip if inference failed
        if (~isempty(errmsg))
            close(f);
            waitfor(errordlg('Inference failed. Please adjust parameter values. Have you provided any training datasets for the frames to track?','Error'));
            return;
        end
        
        % plot
        set(handles.axes_sec4_speed, 'Visible', 'on'); cla(handles.axes_sec4_speed); 
        axes(handles.axes_sec4_speed); hold(handles.axes_sec4_speed, 'on');
        plot([axis_id; axis_id], [abs(dist_x./sqrt(dist_t)); abs(dist_y./sqrt(dist_t))], '.');
        plot(density_val, sigma_val, 'k', 'linewidth', 2);
        xlim([min(density_val), max(density_val)]);
        xlabel('Time (Frames)'); ylabel('Migration Speed (Pixels/Frame)');
        legend('Training Data', 'Inferred Value');
        hold(handles.axes_sec4_speed, 'off');
        
    case 'density'
        [ dist_x, dist_y, dist_t, axis_id ] = aggr_training_data( all_training_data, 'density', training_data_size_image, mig_fold );
        density_val = 1:ceil(max(axis_id));
        [sigma_val, errmsg] = infer_migration_sigma_axis( dist_x, dist_y, dist_t, axis_id, density_val, training_data_size_image, inf_res, inf_sample );
        
        % skip if inference failed
        if (~isempty(errmsg))
            close(f);
            waitfor(errordlg('Inference failed. Please adjust parameter values.','Error'));
            return;
        end
        
        % plot
        set(handles.axes_sec4_speed, 'Visible', 'on'); cla(handles.axes_sec4_speed); 
        axes(handles.axes_sec4_speed); hold(handles.axes_sec4_speed, 'on');
        plot([axis_id; axis_id], [abs(dist_x./sqrt(dist_t)); abs(dist_y./sqrt(dist_t))], '.');
        plot(density_val, sigma_val, 'k', 'linewidth', 2);
        xlim([min(density_val), max(density_val)]);
        xlabel('Density (Cells)'); ylabel('Migration Speed (Pixels/Frame)');
        legend('Training Data', 'Inferred Value');
        hold(handles.axes_sec4_speed, 'off');
        
    otherwise
        error('pushbutton_sec4_speed_Callback: unknown option.');
end
close(f);
guidata(hObject, handles);

end

%% PREDICTION OF EVENTS, PAGE 2
function edit_sec4_empty_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_empty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_empty as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_empty as a double

hObject = check_number_value(hObject, 'zeroone', handles.prob_para.empty_prob);
handles.prob_para.empty_prob = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_empty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_empty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec4_null_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_null (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_null as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_null as a double

hObject = check_number_value(hObject, 'zeroone', handles.prob_para.prob_nonmigration);
handles.prob_para.prob_nonmigration = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_null_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_null (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec4_inout_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_inout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_inout as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_inout as a double

hObject = check_number_value(hObject, 'zeroone', handles.prob_para.min_inout_prob);
handles.prob_para.min_inout_prob = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_inout_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_inout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec4_gap_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec4_gap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec4_gap as text
%        str2double(get(hObject,'String')) returns contents of edit_sec4_gap as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.prob_para.max_migration_time-1);
handles.prob_para.max_migration_time = str2double(get(hObject, 'String'))+1;
if (handles.prob_para.max_migration_time > 1)
    set(handles.text138, 'Visible', 'on');
else
    set(handles.text138, 'Visible', 'off');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec4_gap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec4_gap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%% TRACK LINKING
function edit_sec5_minlength_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_minlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_minlength as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_minlength as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.track_para.min_track_length);
handles.track_para.min_track_length = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_minlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_minlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_maxskip_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_maxskip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_maxskip as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_maxskip as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.track_para.max_num_frames_to_skip);
handles.track_para.max_num_frames_to_skip = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_maxskip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_maxskip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_minscore_overall_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_minscore_overall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_minscore_overall as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_minscore_overall as a double

hObject = check_number_value(hObject, 'nonneg_real', handles.track_para.min_track_score);
handles.track_para.min_track_score = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_minscore_overall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_minscore_overall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_minscore_neighbor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_minscore_neighbor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_minscore_neighbor as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_minscore_neighbor as a double

hObject = check_number_value(hObject, 'real', handles.track_para.min_track_score_per_step);
handles.track_para.min_track_score_per_step = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_minscore_neighbor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_minscore_neighbor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_coexist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_coexist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_coexist as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_coexist as a double

hObject = check_number_value(hObject, 'nonneg_real', handles.track_para.multiple_cells_penalty);
handles.track_para.multiple_cells_penalty = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_coexist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_coexist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_skip_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_skip as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_skip as a double

hObject = check_number_value(hObject, 'nonneg_real', handles.track_para.skip_penalty);
handles.track_para.skip_penalty = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_skip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_skip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_swap_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_swap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_swap as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_swap as a double

hObject = check_number_value(hObject, 'nonneg_real', handles.track_para.min_swap_score);
handles.track_para.min_swap_score = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_swap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_swap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_mitosis_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_mitosis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_mitosis as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_mitosis as a double

hObject = check_number_value(hObject, 'zeroone', handles.track_para.mitosis_detection_min_prob);
handles.track_para.mitosis_detection_min_prob = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_mitosis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_mitosis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec5_critical_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec5_critical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec5_critical as text
%        str2double(get(hObject,'String')) returns contents of edit_sec5_critical as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.track_para.critical_length);
handles.track_para.critical_length = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec5_critical_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec5_critical (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%% SIGNAL EXTRACTION
% --- Executes during object creation, after setting all properties.
function axes_sec6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_sec6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_sec6

end

function edit_sec6_nucdist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec6_nucdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec6_nucdist as text
%        str2double(get(hObject,'String')) returns contents of edit_sec6_nucdist as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.signal_extraction_para.nuc_region_dist);
handles.signal_extraction_para.nuc_region_dist = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec6_nucdist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec6_nucdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function edit_sec6_cytodist_inner_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec6_cytodist_inner (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec6_cytodist_inner as text
%        str2double(get(hObject,'String')) returns contents of edit_sec6_cytodist_inner as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.signal_extraction_para.cytoring_region_dist(1));
handles.signal_extraction_para.cytoring_region_dist(1) = str2double(get(hObject, 'String'));
handles = swap_from_to( handles, 'edit_sec6_cytodist_inner', 'edit_sec6_cytodist_outer');
handles.signal_extraction_para.cytoring_region_dist = sort(handles.signal_extraction_para.cytoring_region_dist);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec6_cytodist_inner_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec6_cytodist_inner (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec6_cytodist_outer_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec6_cytodist_outer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec6_cytodist_outer as text
%        str2double(get(hObject,'String')) returns contents of edit_sec6_cytodist_outer as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.signal_extraction_para.cytoring_region_dist(2));
handles.signal_extraction_para.cytoring_region_dist(2) = str2double(get(hObject, 'String'));
handles = swap_from_to( handles, 'edit_sec6_cytodist_inner', 'edit_sec6_cytodist_outer');
handles.signal_extraction_para.cytoring_region_dist = sort(handles.signal_extraction_para.cytoring_region_dist);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec6_cytodist_outer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec6_cytodist_outer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec6_memdist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec6_memdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec6_memdist as text
%        str2double(get(hObject,'String')) returns contents of edit_sec6_memdist as a double

hObject = check_number_value(hObject, 'nonneg_int', handles.signal_extraction_para.background_dist);
handles.signal_extraction_para.background_dist = str2double(get(hObject, 'String'));
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec6_memdist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec6_memdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec6_percentile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec6_percentile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec6_percentile as text
%        str2double(get(hObject,'String')) returns contents of edit_sec6_percentile as a double

val = str2num(get(hObject, 'String'));
if (isempty(val) || any(val <= 0) || any(val >= 100) || length(val) ~= length(unique(val)))
    waitfor(errordlg('Invalid values. Please enter values between 0 and 100 (both excl). No duplicated values allowed.','Error'));
    temp = sprintf('% g', handles.signal_extraction_para.intensity_percentile); temp = temp(2:end);
    set(hObject, 'String', temp);
else
    handles.signal_extraction_para.intensity_percentile = val;
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec6_percentile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec6_percentile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_sec6_outlier_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sec6_outlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sec6_outlier as text
%        str2double(get(hObject,'String')) returns contents of edit_sec6_outlier as a double

val = str2double(get(hObject, 'String'));
if (isnan(val) || val < 0 || val > 50)
    waitfor(errordlg('Invalid value. Please enter a value between 0 and 50.','Error'));
    set(hObject, 'String', num2str(handles.signal_extraction_para.outlier_percentile));
else
    handles.signal_extraction_para.outlier_percentile = val;
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_sec6_outlier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sec6_outlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%% UTILS
function [ handles ] = switch_image_type( handles, new_type )
%SWITCH_IMAGE_TYPE Update fields when the image type is switched
%
%   Input
%       handles: Handle before operation
%       new_type: New image type
%   Output
%       handles: Handle after operation

% see whether the old and new types are the same
if strcmpi(handles.image_type, new_type)
    return;
end

% confirm whether to continue
answer = questdlg('This operation will clear the existing image paths and filename formats. Do you want to continue?', ...
    'Change Image Type', ...
    'Yes', 'No', 'No');
if strcmpi(answer, 'No')
    switch lower(handles.image_type)
        case 'seq'
            set(handles.uibuttongroup_sec1_imagetype, 'SelectedObject', handles.radiobutton_sec1_imagetype_seq);
        case 'stack'
            set(handles.uibuttongroup_sec1_imagetype, 'SelectedObject', handles.radiobutton_sec1_imagetype_stack);
        case 'nd2'
            set(handles.uibuttongroup_sec1_imagetype, 'SelectedObject', handles.radiobutton_sec1_imagetype_nd2);
        otherwise
            error('switch_image_type: unknown option.');
    end
    return;
end

% clear image paths and filename formats
for i=1:6
    set(handles.(handles.channel_operator{i}{3}), 'String', '');
end
set(handles.edit_sec1_filename, 'String', '');
set(handles.pushbutton_sec1_filename_check, 'Enable', 'off');
handles.image_type = new_type;
handles.nd2_image_path = {};

% change visibility
switch lower(new_type)
    case 'seq'
        % input path
        set(handles.checkbox_sec1_path, 'Value', 0, 'Enable', 'on');
        handles.if_same_path = 0;
        for i=1:handles.num_channels
            set(handles.(handles.channel_operator{i}{3}), 'Enable', 'on');
            set(handles.(handles.channel_operator{i}{4}), 'Enable', 'on');
        end
        
        % filename format
        set(handles.pushbutton_sec1_filename_row, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_column, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_site, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_frame, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_channel, 'Enable', 'on');
        
        % extract images
        set(handles.uipanel_sec1_extract, 'Visible', 'off');
    case 'stack'
        % input path
        set(handles.checkbox_sec1_path, 'Value', 0, 'Enable', 'on');
        handles.if_same_path = 0;
        for i=1:handles.num_channels
            set(handles.(handles.channel_operator{i}{3}), 'Enable', 'on');
            set(handles.(handles.channel_operator{i}{4}), 'Enable', 'on');
        end
        
        % filename format
        set(handles.pushbutton_sec1_filename_row, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_column, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_site, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_frame, 'Enable', 'off');
        set(handles.pushbutton_sec1_filename_channel, 'Enable', 'on');
        
        % extract images
        set(handles.uipanel_sec1_extract, 'Visible', 'off');
        
    case 'nd2'
        % input path
        set(handles.checkbox_sec1_path, 'Value', 1, 'Enable', 'off');
        handles.if_same_path = 1;
        set(handles.(handles.channel_operator{1}{3}), 'Enable', 'off');
        set(handles.(handles.channel_operator{1}{4}), 'Enable', 'on');
        for i=2:handles.num_channels
            set(handles.(handles.channel_operator{i}{3}), 'Enable', 'off');
            set(handles.(handles.channel_operator{i}{4}), 'Enable', 'off');
        end
        
        % filename format
        set(handles.pushbutton_sec1_filename_row, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_column, 'Enable', 'on');
        set(handles.pushbutton_sec1_filename_site, 'Enable', 'off');
        set(handles.pushbutton_sec1_filename_frame, 'Enable', 'off');
        set(handles.pushbutton_sec1_filename_channel, 'Enable', 'off');
        
        % extract images
        set(handles.uipanel_sec1_extract, 'Visible', 'on');
        
    otherwise
        error('switch_image_type: unknown option.');
end

end

function [ hObject ] = check_channel_name(hObject, if_start_letter)
%CHECK_CHANNEL_NAME Check input names
%
%   Input
%       hObject: hObject before operation
%       if_start_letter: Whether the variable starts with letter
%   Output
%       hObject: hObject after operation

% get str
str = get(hObject, 'String');
if isempty(str)
    return;
end

% check whether only contain alphanumeric value (only for signal names)
if (if_start_letter)
    try
        temp = struct(str, 'abc');
        if_invalid = 0;
    catch
        if_invalid = 1;
    end
    if (if_invalid)
        waitfor(errordlg('Invalid value. Please only use numbers, letters or _.','Error'));
        set(hObject, 'String', '');
    end
end

end

function [ hObject ] = check_path_name( hObject )
%CHECK_PATH_NAMES Check validity of the path
%
%   Input
%       hObject: hObject before operation
%   Output
%       hObject: hObject after operation

try
    set(hObject, 'String', adjust_path(get(hObject, 'String'), 0));
catch
    waitfor(errordlg('Invalid path.','Error'));
    set(hObject, 'String', '');
end

end

function [ hObject ] = check_number_value( hObject, option, default_val )
%CHECK_NUMBER_VALUE Check if input value satisfies requirement
%
%   Input
%       hObject: hObject before operation
%       option: Option
%       default_val: Default value if not passed check
%   Output
%       hObject: hObject after operation

val = str2double(get(hObject, 'String'));
switch (option)
    case 'pos_int'
        if_invalid = isnan(val) | val~=floor(val) | val <= 0;
        msg = 'Invalid value. Please enter a positive integer.';
    case 'nonneg_int'
        if_invalid = isnan(val) | val~=floor(val) | val < 0;
        msg = 'Invalid value. Please enter a non-negative integer.';
    case 'int'
        if_invalid = isnan(val) | val~=floor(val);
        msg = 'Invalid value. Please enter an integer.';
    case 'pos_real'
        if_invalid = isnan(val) | val <= 0;
        msg = 'Invalid value. Please enter a positive number.';
    case 'nonneg_real'
        if_invalid = isnan(val) | val < 0;
        msg = 'Invalid value. Please enter a non-negative number.';
    case 'real'
        if_invalid = isnan(val);
        msg = 'Invalid value. Please enter a number.';
    case 'neg_real'
        if_invalid = isnan(val) | val >= 0;
        msg = 'Invalid value. Please enter a negative number.';
    case 'zeroone'
        if_invalid = isnan(val) | val < 0 | val > 1;
        msg = 'Invalid value. Please enter a number between 0 and 1.';
    case 'greaterequal1'
        if_invalid = isnan(val) | val < 1;
        msg = 'Invalid value. Please enter a number >= 1.';
    case 'binary'
        if_invalid = ~ismember(val, [0, 1]);
    otherwise
        error('check_number_value: unknown option.');
end

if (if_invalid)
    waitfor(errordlg(msg,'Error'));
    set(hObject, 'String', num2str(default_val));
end

end

function [ handles ] = adjust_num_channels(handles, new_num_channels)
%ADJUST_NUM_CHANNELS Change number of channels on the GUI
%
%   Input
%       handles: Handles before adjustment
%       new_num_channels: New number of channels to display
%   Output
%       handles: Handles after adjustment

% see whether the old and new numbers are the same
if strcmpi(handles.num_channels, new_num_channels)
    return;
end

% confirm whether to continue
if (new_num_channels < handles.num_channels)
    answer = questdlg('This operation will clear the contents for removed channels. Do you want to continue?', ...
        'Change Number of Channel', ...
        'Yes', 'No', 'No');
    if strcmpi(answer, 'No')
        set(handles.uibuttongroup_sec1_numchannel, 'SelectedObject', ...
            handles.(matlab.lang.makeValidName(['handles.radiobutton_sec1_numchannel_', num2str(handles.num_channels)])));
        return;
    end
end

% update information
if (new_num_channels > handles.num_channels) % add new channels
    for i=handles.num_channels+1:new_num_channels
        for j=1:length(handles.channel_operator{i})
            set(handles.(handles.channel_operator{i}{j}), 'Enable', 'on');
        end
        if (handles.if_same_path)
            set(handles.(handles.channel_operator{i}{3}), 'Enable', 'off', 'String', get(handles.(handles.channel_operator{1}{3}), 'String'));
            set(handles.(handles.channel_operator{i}{4}), 'Enable', 'off');
        end
    end
else % remove channels
    for i=new_num_channels+1:handles.num_channels
        set(handles.(handles.channel_operator{i}{1}), 'Enable', 'off', 'String', '');
        set(handles.(handles.channel_operator{i}{2}), 'Enable', 'off', 'String', '');
        set(handles.(handles.channel_operator{i}{3}), 'Enable', 'off', 'String', '');
        set(handles.(handles.channel_operator{i}{4}), 'Enable', 'off');
        set(handles.(handles.channel_operator{i}{5}), 'Enable', 'off', 'String', '');
        set(handles.(handles.channel_operator{i}{6}), 'Enable', 'off');
        set(handles.(handles.channel_operator{i}{7}), 'Enable', 'off');
        set(handles.(handles.channel_operator{i}{8}), 'Enable', 'off', 'Value', 0);
    end
end
handles.num_channels = new_num_channels;

end

function [ handles ] = swap_from_to( handles, entry_from, entry_to )
%SWAP_FROM_TO Swap value of entries such that entry_from is less than
%entry_to
%
%   Input
%       handles: Handles before operation
%       entry_from: From value
%       entry_to: To value
%   Output
%       handles: Handles after operation

val_from = str2double(get(handles.(matlab.lang.makeValidName(entry_from)), 'String'));
val_to = str2double(get(handles.(matlab.lang.makeValidName(entry_to)), 'String'));
if (~isnan(val_from) && ~isnan(val_to) && val_from > val_to)
    set(handles.(matlab.lang.makeValidName(entry_from)), 'String', num2str(val_to));
    set(handles.(matlab.lang.makeValidName(entry_to)), 'String', num2str(val_from));
end

end

function [ nd2_frame_range, all_bfReaders ] = get_nd2_frame_range(handles, row_id, col_id)
%GET_ND2_FRAME_RANGE Get frame range for each nd2 file
%
%   Input
%       handles: Handles of GUI
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%   Output
%       nd2_frame_range: Range of each nd2 file
%       all_bfReaders: BioformatsImage readers

% get empty structure
num_entries = length(handles.nd2_image_path);
nd2_frame_range = nan(num_entries, 2);
all_bfReaders = cell(row_id, col_id); all_bfReaders{row_id, col_id} = cell(num_entries, 1);
movie_definition = struct('filename_format', get(handles.edit_sec1_filename, 'String'), 'image_type', 'nd2');
[ filename_format, image_info_order ] = convert_filename_format(movie_definition);

% iterate over every entry
for i=1:num_entries
    % locate ND2 file
    image_info = {row_id, col_id, 1, 1, 1, 'a', char(row_id-1+'a'), char(row_id-1+'A')};
    filename = sprintf(filename_format, image_info{image_info_order});
    all_files = dir(handles.nd2_image_path{i});
    recorded_file_id = [];
    for j=1:length(all_files)
        if strncmpi(filename, all_files(j).name, length(filename))
            recorded_file_id = j;
            break;
        end
    end
    if (isempty(recorded_file_id))
        error('get_nd2_frame_range: ND2 file not found.');
    end
    all_bfReaders{row_id, col_id}{i} = BioformatsImage([handles.nd2_image_path{i}, all_files(recorded_file_id).name]);
    if (i==1)
        nd2_frame_range(i, :) = [1, all_bfReaders{row_id, col_id}{i}.sizeT];
    else
        nd2_frame_range(i, :) = [1, all_bfReaders{row_id, col_id}{i}.sizeT] + nd2_frame_range(i-1, 2);
    end
end

end

function [ handles ] = switch_panel( handles )
%SWITCH_PANEL Switch panels
%
%   Input
%       handles: Handles before operation
%   Output
%       handles: Handles after operation

panel_names = matlab.lang.makeValidName({'uipanel_sec1_page1', ...
    'uipanel_sec1_page2', 'uipanel_sec2', 'uipanel_sec3', 'uipanel_sec4_page1', ...
    'uipanel_sec4_page2', 'uipanel_sec5', 'uipanel_sec6'});
for i=1:length(panel_names)
    if (i == handles.current_panel)
        set(handles.(panel_names{i}), 'Visible', 'on');
    else
        set(handles.(panel_names{i}), 'Visible', 'off');
    end
end
if (handles.current_panel == 1)
    set(handles.pushbutton_outer_previous, 'Enable', 'off');
else
    set(handles.pushbutton_outer_previous, 'Enable', 'on');
end
if (handles.current_panel == length(panel_names))
    set(handles.pushbutton_outer_next, 'Enable', 'off');
else
    set(handles.pushbutton_outer_next, 'Enable', 'on');
end

end
