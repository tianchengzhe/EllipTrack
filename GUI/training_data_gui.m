function varargout = training_data_gui(varargin)
% TRAINING_DATA_GUI MATLAB code for training_data_gui.fig
%      TRAINING_DATA_GUI, by itself, creates a new TRAINING_DATA_GUI or raises the existing
%      singleton*.
%
%      H = TRAINING_DATA_GUI returns the handle to a new TRAINING_DATA_GUI or the handle to
%      the existing singleton*.
%
%      TRAINING_DATA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAINING_DATA_GUI.M with the given input arguments.
%
%      TRAINING_DATA_GUI('Property','Value',...) creates a new TRAINING_DATA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before training_data_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to training_data_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help training_data_gui

% Last Modified by GUIDE v2.5 26-Feb-2020 16:05:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @training_data_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @training_data_gui_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT

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

% --- Executes just before training_data_gui is made visible.
function training_data_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to training_data_gui (see VARARGIN)

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

% set tooltipstring
set(handles.text_file_path, 'TooltipString', sprintf('Folder storing the nuclear images.\nImage sequences or stacks only.'));
set(handles.edit_file_path, 'TooltipString', sprintf('Enter the path to the folder.'));
set(handles.pushbutton_select_path, 'TooltipString', sprintf('Select the folder.'));
set(handles.text_prefix, 'TooltipString', sprintf('Format of filenames.\nUse %%t for Frame IDs.\nUse %%0Nt for prefix zeros.'));
set(handles.edit_prefix, 'TooltipString', sprintf('Enter the format of filenames.'))
set(handles.text80, 'TooltipString', sprintf('Frames to load.'));
set(handles.edit_first_imported_frame_id, 'TooltipString', sprintf('Enter ID of the first frame.\nMust be a non-negative integer.'));
set(handles.edit_last_imported_frame_id, 'TooltipString', sprintf('Enter ID of the last frame.\nMust be a non-negative integer.'));
set(handles.text_cmos, 'TooltipString', sprintf('Path to the MAT file storing the camera dark noise.\nLeave empty if not available.'));
set(handles.edit_cmos, 'TooltipString', sprintf('Enter the path to the MAT file.'));
set(handles.pushbutton_cmos, 'TooltipString', sprintf('Select the MAT file.'));
set(handles.text_bias, 'TooltipString', sprintf('Path to the MAT file storing the illumination bias.\nLeave empty if not available.'));
set(handles.edit_bias, 'TooltipString', sprintf('Enter the path to the MAT file.'));
set(handles.pushbutton_bias, 'TooltipString', sprintf('Select the MAT file.'));
set(handles.text_path_segmentation, 'TooltipString', sprintf('Path to the folder storing the seg info.'));
set(handles.edit_path_segmentation, 'TooltipString', sprintf('Enter the path to the folder.'));
set(handles.pushbutton_path_segmentation, 'TooltipString', sprintf('Select the folder.'));
set(handles.text_path_existing, 'TooltipString', sprintf('Path to the existing training dataset.\nLeave empty if not available.'));
set(handles.edit_path_existing, 'TooltipString', sprintf('Enter the path to the existing training dataset.'));
set(handles.pushbutton_path_existing, 'TooltipString', sprintf('Select the existing training dataset.'));
set(handles.text_path_output, 'TooltipString', sprintf('Path to the folder storing the output.'));
set(handles.edit_path_output, 'TooltipString', sprintf('Enter the path to the folder.'));
set(handles.pushbutton_path_output, 'TooltipString', sprintf('Select the folder.'));
set(handles.pushbutton_import_to_workspace, 'TooltipString', sprintf('Load images and start training.'));

set(handles.pushbutton_go_by_10_frames_prev, 'TooltipString', sprintf('Go backward by 10 frames.\nShortcut: Down Arrow'));
set(handles.pushbutton_go_by_10_frames_next, 'TooltipString', sprintf('Go forward by 10 frames.\nShortcut: Up Arrow'));
set(handles.pushbutton_go_by_1_frame_prev, 'TooltipString', sprintf('Go backward by 10 frames.\nShortcut: Left Arrow'));
set(handles.pushbutton_go_by_1_frame_next, 'TooltipString', sprintf('Go forward by 10 frames.\nShortcut: Right Arrow'));
set(handles.edit_go_to, 'TooltipString', sprintf('Enter Frame ID.\nMust be a loaded Frame ID.'));
set(handles.pushbutton_go_to_frame_ID, 'TooltipString', sprintf('Go to the frame.'));
set(handles.text81, 'TooltipString', sprintf('Intensity range for display.'));
set(handles.edit_intensity_low, 'TooltipString', sprintf('Enter the lower bound.\nMust be a non-negative number.'));
set(handles.edit_intensity_high, 'TooltipString', sprintf('Enter the upper bound.\nMust be a non-negative number.'));

set(handles.text_no_cells, 'TooltipString', sprintf('Ellipse contains no nucleus.'));
set(handles.text_one_cell, 'TooltipString', sprintf('Ellipse contains one nucleus.'));
set(handles.text_two_cells, 'TooltipString', sprintf('Ellipse contains two or more nuclei.'));
set(handles.text_before_mitosis, 'TooltipString', sprintf('Cell undergoes mitosis and divides\ninto two daughter cells in the next frame.'));
set(handles.text_after_mitosis, 'TooltipString', sprintf('Cell is newly born and its mother cell\nundergoes mitosis in the previous frame.'));
set(handles.text_apoptosis, 'TooltipString', sprintf('Cell undergoes apoptosis and disappears in the next frame.'));
set(handles.text_morphology_clear, 'TooltipString', sprintf('Unrecord the selected ellipse.'));

set(handles.pushbutton_no_cells, 'TooltipString', sprintf('Record the ellipse.\nShortcut: 1'));
set(handles.pushbutton_one_cell, 'TooltipString', sprintf('Record the ellipse.\nShortcut: 2'));
set(handles.pushbutton_two_cells, 'TooltipString', sprintf('Record the ellipse.\nShortcut: 3'));
set(handles.pushbutton_before_mitosis, 'TooltipString', sprintf('Record the ellipse.\nShortcut: 4'));
set(handles.pushbutton_after_mitosis, 'TooltipString', sprintf('Record the ellipse.\nShortcut: 5'));
set(handles.pushbutton_apoptosis, 'TooltipString', sprintf('Record the ellipse.\nShortcut: 6'));
set(handles.pushbutton_morphology_clear, 'TooltipString', sprintf('Unrecord the ellipse.\nShortcut: C'));

set(handles.text_no_cells_number, 'TooltipString', sprintf('Number of recorded ellipses.'));
set(handles.text_one_cell_number, 'TooltipString', sprintf('Number of recorded ellipses.'));
set(handles.text_two_cells_number, 'TooltipString', sprintf('Number of recorded ellipses.'));
set(handles.text_before_mitosis_number, 'TooltipString', sprintf('Number of recorded ellipses.'));
set(handles.text_after_mitosis_number, 'TooltipString', sprintf('Number of recorded ellipses.'));
set(handles.text_apoptosis_number, 'TooltipString', sprintf('Number of recorded ellipses.'));

set(handles.text_no_cell_color, 'TooltipString', sprintf('Symbolic color.'));
set(handles.text_one_cell_color, 'TooltipString', sprintf('Symbolic color.'));
set(handles.text_two_cells_color, 'TooltipString', sprintf('Symbolic color.'));
set(handles.text_before_mitosis_color, 'TooltipString', sprintf('Symbolic color.'));
set(handles.text_after_mitosis_color, 'TooltipString', sprintf('Symbolic color.'));
set(handles.text_apoptosis_color, 'TooltipString', sprintf('Symbolic color.'));

set(handles.text_recorded_cells, 'TooltipString', sprintf('Number of trained cells.'));
set(handles.text_current_cell_id, 'TooltipString', sprintf('ID of the cell under training.'));
set(handles.text_intances, 'TooltipString', sprintf('Number of recorded ellipses for the cell.'));
set(handles.pushbutton_migration_record, 'TooltipString', sprintf('Record the selected ellipse.\nShortcut: R'));
set(handles.pushbutton_migration_clear, 'TooltipString', sprintf('Unrecord the selected ellipse.\nShortcut: C'));
set(handles.text_to_cell_id, 'TooltipString', sprintf('Switch to another cell.'));
set(handles.edit_to_cell_id, 'TooltipString', sprintf('Enter Cell ID.\nMust be a positive integer.'));
set(handles.pushbutton_to_cell_id, 'TooltipString', sprintf('Switch to the cell.'));
set(handles.text_clear_cell_id, 'TooltipString', sprintf('Clear all recorded ellipses for a cell.'));
set(handles.edit_clear_cell_id, 'TooltipString', sprintf('Enter Cell ID.\nMust be an existing Cell ID.'));
set(handles.pushbutton_clear_cell_id, 'TooltipString', sprintf('Clear all recorded ellipses.'));

set(handles.pushbutton_clear_all, 'TooltipString', sprintf('Clear all training data.'));
set(handles.pushbutton_next, 'TooltipString', sprintf('Go to migration training.'));
set(handles.pushbutton_finish, 'TooltipString', sprintf('Finish training.'));

% Choose default command line output for training_data_gui
handles.output = hObject;

% initialize data structures
handles.file_path = []; % selected file paths
handles.prefix = []; % prefix of file names (e.g. 1_1_1_mIFP_)
handles.imported_frame_id = []; % first:last id
handles.cmos_path = []; % cmosoffset path
handles.bias_path = []; % bias path
handles.segmentation_path = []; % selected path for existing segmentation info
handles.existing_path = []; % selected path for existing training data
handles.output_path = []; % selected path for output
handles.curr_frame_id = []; % current frame id for display
handles.curr_ellipse_id = []; % current selected ellipse id
handles.morphology_training_set = {}; % save all morphology training objects provided by the users
    % every cell represents a frame
    % in each cell, nx2 matrix: ellipse id, type id (1-5).
    % 1 for no cells, 2 for 1 cell, 3 for 2 cells, 4 for before mitosis, 5
    % for after mitosis, 6 for apoptosis
handles.motion_training_set = []; % save all motion training objects provided by the users
    % every cell represents a cell ID
    % in each cell, nx2 matrix: frame ID, ellipse ID
handles.if_morphology = []; % whether classifying morphology or motion
handles.curr_cell_id = []; % current cell id for motion classification

% set visibility of structure
set(handles.uipanel_nav_frames, 'Visible', 'Off');
set(handles.uipanel_morphology_classification, 'Visible', 'Off');
set(handles.uipanel_motion_classification, 'Visible', 'Off');
set(handles.pushbutton_clear_all, 'Visible', 'Off');
set(handles.pushbutton_next, 'Visible', 'Off');
set(handles.pushbutton_finish, 'Visible', 'Off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes training_data_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = training_data_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

%% SETTING
function edit_file_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_file_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_file_path as text
%        str2double(get(hObject,'String')) returns contents of edit_file_path as a double

handles.file_path = adjust_path(get(hObject, 'String'), 0);
set(hObject, 'String', handles.file_path);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_file_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_file_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_select_path.
function pushbutton_select_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir;
if (selpath ~= 0)
    handles.file_path = adjust_path(selpath, 0);
    set(handles.edit_file_path, 'String', handles.file_path);
end
guidata(hObject, handles);

end

function edit_prefix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prefix as text
%        str2double(get(hObject,'String')) returns contents of edit_prefix as a double

handles.prefix = get(hObject, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_first_imported_frame_id_Callback(hObject, eventdata, handles)
% hObject    handle to edit_first_imported_frame_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_first_imported_frame_id as text
%        str2double(get(hObject,'String')) returns contents of edit_first_imported_frame_id as a double

% check whether the input string is a valid number
val = str2double(get(hObject, 'String'));
if (isnan(val) || val < 0 || val ~= floor(val))
    waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
    set(hObject, 'String', '');
else
    if (val > str2double(get(handles.edit_last_imported_frame_id, 'String')))
        set(hObject, 'String', get(handles.edit_last_imported_frame_id, 'String'));
        set(handles.edit_last_imported_frame_id, 'String', num2str(val));
    end
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_first_imported_frame_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_first_imported_frame_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_last_imported_frame_id_Callback(hObject, eventdata, handles)
% hObject    handle to edit_last_imported_frame_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_last_imported_frame_id as text
%        str2double(get(hObject,'String')) returns contents of edit_last_imported_frame_id as a double

val = str2double(get(hObject, 'String'));
if (isnan(val) || val < 0 || val ~= floor(val))
    waitfor(errordlg('Invalid value. Please enter a non-negative integer.', 'Error'));
    set(hObject, 'String', '');
else
    if (val < str2double(get(handles.edit_first_imported_frame_id, 'String')))
        set(hObject, 'String', get(handles.edit_first_imported_frame_id, 'String'));
        set(handles.edit_first_imported_frame_id, 'String', num2str(val));
    end
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_last_imported_frame_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_last_imported_frame_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_cmos_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cmos as text
%        str2double(get(hObject,'String')) returns contents of edit_cmos as a double

handles.cmos_path = adjust_path(get(hObject, 'String'), 0);
set(hObject, 'String', handles.cmos_path);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_cmos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushbutton_cmos.
function pushbutton_cmos_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ file, path ] = uigetfile({'*.mat','*.MAT'}, 'Select Camera Dark Noise');
if (file ~= 0)
    handles.cmos_path = adjust_path([path, file], 0);
    set(handles.edit_cmos, 'String', handles.cmos_path);
end
guidata(hObject, handles);

end

function edit_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_bias as text
%        str2double(get(hObject,'String')) returns contents of edit_bias as a double

handles.bias_path = adjust_path(get(hObject, 'String'), 0);
set(hObject, 'String', handles.bias_path);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushbutton_bias.
function pushbutton_bias_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ file, path ] = uigetfile({'*.mat','*.MAT'}, 'Select Illumination Bias');
if (file ~= 0)
    handles.bias_path = adjust_path([path, file], 0);
    set(handles.edit_bias, 'String', handles.bias_path);
end
guidata(hObject, handles);

end

function edit_path_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path_segmentation as text
%        str2double(get(hObject,'String')) returns contents of edit_path_segmentation as a double

handles.segmentation_path = adjust_path(get(hObject, 'String'), 0);
set(hObject, 'String', handles.segmentation_path);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_path_segmentation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_path_segmentation.
function pushbutton_path_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_path_segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir;
if (selpath ~= 0)
    handles.segmentation_path = adjust_path(selpath, 0);
    set(handles.edit_path_segmentation, 'String', handles.segmentation_path);
end
guidata(hObject, handles);

end

function edit_path_existing_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path_existing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path_existing as text
%        str2double(get(hObject,'String')) returns contents of edit_path_existing as a double

handles.existing_path = adjust_path(get(hObject, 'String'), 0);
set(hObject, 'String', handles.existing_path);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_path_existing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path_existing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_path_existing.
function pushbutton_path_existing_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_path_existing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[ file, path ] = uigetfile({'*.mat','*.MAT'}, 'Select Existing Training Data');
if (file ~= 0)
    handles.existing_path = adjust_path([path, file], 0);
    set(handles.edit_path_existing, 'String', handles.existing_path);
end
guidata(hObject, handles);

end

function edit_path_output_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path_output as text
%        str2double(get(hObject,'String')) returns contents of edit_path_output as a double

handles.output_path = adjust_path(get(hObject, 'String'), 0);
set(hObject, 'String', handles.output_path);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_path_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_path_output.
function pushbutton_path_output_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_path_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir;
if (selpath ~= 0)
    handles.output_path = adjust_path(selpath, 0);
    set(handles.edit_path_output, 'String', handles.output_path);
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_import_to_workspace.
function pushbutton_import_to_workspace_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_import_to_workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set visibility of buttons
f = waitbar(0, 'Loading Data.'); pause(0.01);
handles = set_setting_enability( handles, 'Off' );

% obtain the data
start_frame_id = str2double(get(handles.edit_first_imported_frame_id, 'String'));
end_frame_id = str2double(get(handles.edit_last_imported_frame_id, 'String'));

% check if any field is empty
if (isempty(start_frame_id) || isempty(end_frame_id) || isempty(handles.prefix) || isempty(handles.file_path) || ...
        isempty(handles.segmentation_path) || isempty(handles.output_path))
    
    % display error message
    close(f);
    waitfor(errordlg('Some fields are empty!','Error'));
    
    % resume visibility of buttons
    handles = set_setting_enability( handles, 'On' );
    guidata(hObject, handles);
    return;
end

% frames, prepare data structure
handles.imported_frame_id = start_frame_id:end_frame_id;
num_imported_frame_id = length(handles.imported_frame_id);
temp(1:num_imported_frame_id) = struct('image', {{}}, 'ellipse_info', {{}});
handles.figure1.UserData = temp;

% import cmosoffset
try
    h = load(handles.cmos_path);
    cmosoffset = h.cmosoffset;
catch
    % display warning message
    if (~isempty(handles.cmos_path))
        waitfor(warndlg('Fail to load cmosoffset. Will not correct camera dark noise.', 'Warning'));
    end
    cmosoffset = 0;
end

% import bias
try
    h = load(handles.bias_path);
    bias = h.bias;
catch
    % display warning message
    if (~isempty(handles.bias_path))
        waitfor(warndlg('Fail to load bias. Will not correct illumination bias.', 'Warning'));
    end
    bias = 1;
end

% import image files
waitbar(0.25, f); pause(0.01);
try
    [filename_format, image_info_order] = convert_filename_format(struct('filename_format', handles.prefix, 'image_type', 'gui'));
    for i=1:num_imported_frame_id
        image_info = {1, 1, 1, 0, handles.imported_frame_id(i), 'mCherry', 'a', 'A'};
        try
            I = imread([handles.file_path, sprintf(filename_format, image_info{image_info_order})]);
        catch
            try
                I = imread([handles.file_path, sprintf(filename_format, image_info{image_info_order})], 'Index', handles.imported_frame_id(i));
            catch
                I = imread([handles.file_path, sprintf(filename_format, image_info{image_info_order})], 'Frames', handles.imported_frame_id(i));
            end
        end
        handles.figure1.UserData(i).image = max((double(I)-cmosoffset)./bias, 1);
    end
catch
    % display error message
    close(f);
    waitfor(errordlg('Error reading images.','Error'));
    
    % resume visibility of buttons
    handles = set_setting_enability( handles, 'On' );
    handles.imported_frame_id = [];
    handles.figure1.UserData = [];
    guidata(hObject, handles);
    return
end

% import all the segmentation files
waitbar(0.5, f); pause(0.01);
try
    all_files = dir(handles.segmentation_path);
    for i=1:num_imported_frame_id
        file_suffix = ['_', num2str(handles.imported_frame_id(i)), '_segmentation.mat'];
        recorded_file_id = [];
        for k=1:length(all_files)
            if endsWith(all_files(k).name, file_suffix)
                recorded_file_id = k;
                break;
            end
        end
        if (isempty(recorded_file_id))
            error('File not found.');
        end
        h = load([handles.segmentation_path, all_files(recorded_file_id).name]);
        handles.figure1.UserData(i).ellipse_info = h.ellipse_info;
    end
catch
    % display error message
    close(f);
    waitfor(errordlg('Seg Info not found!','Error'));
    
    % resume visibility of buttons
    handles = set_setting_enability( handles, 'On' );
    handles.imported_frame_id = [];
    handles.figure1.UserData = [];
    guidata(hObject, handles);
    return
end

% read all existing morphology and motion training set
waitbar(0.75, f); pause(0.01);
try
    if (isempty(handles.existing_path))
        if_exist_training_set = 0;
    else
        h = load(handles.existing_path);
        if (~strcmpi(handles.file_path, h.file_path) || ~strcmpi(handles.prefix, h.prefix) || ~isequal(handles.imported_frame_id, h.imported_frame_id))
            waitfor(warndlg({'Existing dataset was not constructed with the input images. Restart the GUI if error occurs.';
                'Folder';
                ['Input: ', handles.file_path];
                ['Existing: ', h.file_path];
                'File';
                ['Input: ', handles.prefix];
                ['Existing: ', h.prefix];
                'Imported Frames';
                ['Input: ', num2str(min(handles.imported_frame_id)), ' to ', num2str(max(handles.imported_frame_id))];
                ['Existing: ', num2str(min(h.imported_frame_id)), ' to ', num2str(max(h.imported_frame_id))]}, 'Warning'));
        end
        if_exist_training_set = 1;
        handles.morphology_training_set = h.morphology_training_set;
        handles.motion_training_set = h.motion_training_set;
    end
catch
    % display warning message
    if_exist_training_set = 0;
    waitfor(warndlg('Existing dataset is not valid. Will not import it.','Warning'));
end
close(f);

temp = [handles.output_path, 'training_data_', num2str(handles.imported_frame_id(1)), '_', num2str(handles.imported_frame_id(end)), '.mat'];
if exist(temp, 'file') == 2
    waitfor(warndlg(['File ', temp, ' exists in the output folder. Will replace the file.'], 'Warning'));
end

% put empty training set if nothing is provided
if (~if_exist_training_set)
    handles.morphology_training_set = cell(num_imported_frame_id, 1);
    handles.motion_training_set = [];
end
% count the number of morphology instances
num_morphology_class = 6;
all_morphology_counts = zeros(num_morphology_class, 1);
for i = 1:length(handles.morphology_training_set)
    if (isempty(handles.morphology_training_set{i}))
        continue;
    end
    temp = histc(handles.morphology_training_set{i}(:,2), 1:num_morphology_class);
    if (size(temp, 1) == 1) % need col vector, not row vector
        temp = temp';
    end
    all_morphology_counts = all_morphology_counts + temp;
end
% set display of morphology counts
set(handles.text_no_cells_number, 'String', num2str(all_morphology_counts(1)));
set(handles.text_one_cell_number, 'String', num2str(all_morphology_counts(2)));
set(handles.text_two_cells_number, 'String', num2str(all_morphology_counts(3)));
set(handles.text_before_mitosis_number, 'String', num2str(all_morphology_counts(4)));
set(handles.text_after_mitosis_number, 'String', num2str(all_morphology_counts(5)));
set(handles.text_apoptosis_number, 'String', num2str(all_morphology_counts(6)));
handles = set_morphology_state_enability(handles, 'Off');
handles.curr_ellipse_id = [];

% set display of motion counts
set(handles.text_recorded_cells_number, 'String', num2str(length(handles.motion_training_set)));
set(handles.text_current_cell_id_number, 'String', []);
set(handles.text_intances_number, 'String', []);
handles = set_motion_state_enability(handles, 'Off');
handles.curr_cell_id = [];

% initialize other stuffs
set(handles.axes1, 'Visible', 'On');
set(handles.uipanel_nav_frames, 'Visible', 'On');
set(handles.uipanel_morphology_classification, 'Visible', 'On');
set(handles.pushbutton_clear_all, 'Visible', 'On');
set(handles.pushbutton_next, 'Visible', 'On');
handles.curr_frame_id = 1;
handles.if_morphology = 1;
set(handles.edit_intensity_low, 'String', num2str(round(min(min(handles.figure1.UserData(handles.curr_frame_id).image)))));
set(handles.edit_intensity_high, 'String', num2str(round(max(max(handles.figure1.UserData(handles.curr_frame_id).image)))));
handles = plot_image(handles);

guidata(hObject, handles);

end

%% NAVIGATION OF FRAMES
% --- Executes on button press in pushbutton_go_by_1_frame_prev.
function pushbutton_go_by_1_frame_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go_by_1_frame_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_frame_id = handles.curr_frame_id - 1;
if (handles.curr_frame_id < 1)
    handles.curr_frame_id = handles.curr_frame_id + length(handles.imported_frame_id);
end
handles.curr_ellipse_id = [];
handles = set_morphology_state_enability(handles, 'Off');
handles = set_motion_state_enability(handles, 'Off');
handles = plot_image(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_go_by_1_frame_next.
function pushbutton_go_by_1_frame_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go_by_1_frame_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_frame_id = handles.curr_frame_id + 1;
if (handles.curr_frame_id > length(handles.imported_frame_id))
    handles.curr_frame_id = handles.curr_frame_id - length(handles.imported_frame_id);
end
handles.curr_ellipse_id = [];
handles = set_morphology_state_enability(handles, 'Off');
handles = set_motion_state_enability(handles, 'Off');
handles = plot_image(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_go_by_10_frames_prev.
function pushbutton_go_by_10_frames_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go_by_10_frames_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_frame_id = handles.curr_frame_id - 10;
while (handles.curr_frame_id < 1)
    handles.curr_frame_id = handles.curr_frame_id + length(handles.imported_frame_id);
end
handles.curr_ellipse_id = [];
handles = set_morphology_state_enability(handles, 'Off');
handles = set_motion_state_enability(handles, 'Off');
handles = plot_image(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_go_by_10_frames_next.
function pushbutton_go_by_10_frames_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go_by_10_frames_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_frame_id = handles.curr_frame_id + 10;
while (handles.curr_frame_id > length(handles.imported_frame_id))
    handles.curr_frame_id = handles.curr_frame_id - length(handles.imported_frame_id);
end
handles.curr_ellipse_id = [];
handles = set_morphology_state_enability(handles, 'Off');
handles = set_motion_state_enability(handles, 'Off');
handles = plot_image(handles);
guidata(hObject, handles);

end

function edit_go_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit_go_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_go_to as text
%        str2double(get(hObject,'String')) returns contents of edit_go_to as a double

% check whether the input string is a valid number
val = str2double(get(hObject, 'String'));
if ~ismember(val, handles.imported_frame_id)
    waitfor(errordlg('Invalid Frame ID.','Error'));
    set(hObject, 'String', []);
    set(handles.pushbutton_go_to_frame_ID, 'Enable', 'off');
else
    set(handles.pushbutton_go_to_frame_ID, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_go_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_go_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_go_to_frame_ID.
function pushbutton_go_to_frame_ID_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_go_to_frame_ID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(get(handles.edit_go_to, 'String'));
handles.curr_frame_id = find(val == handles.imported_frame_id, 1);
handles.curr_ellipse_id = [];
handles = set_morphology_state_enability(handles, 'Off');
handles = set_motion_state_enability(handles, 'Off');
handles = plot_image(handles);
guidata(hObject, handles);

end

function edit_intensity_low_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intensity_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intensity_low as text
%        str2double(get(hObject,'String')) returns contents of edit_intensity_low as a double

val = str2double(get(hObject, 'String'));
if (isnan(val) || val < 0)
    waitfor(errordlg('Invalid value. Please enter a non-negative number.','Error'));
    set(hObject, 'String', num2str(round(min(min(handles.figure1.UserData(handles.curr_frame_id).image)))));
else
    if (val > str2double(get(handles.edit_intensity_high, 'String')))
        set(hObject, 'String', get(handles.edit_intensity_high, 'String'));
        set(handles.edit_intensity_high, 'String', num2str(val));
    end
end
handles = plot_image(handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_intensity_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intensity_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit_intensity_high_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intensity_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intensity_high as text
%        str2double(get(hObject,'String')) returns contents of edit_intensity_high as a double

val = str2double(get(hObject, 'String'));
if (isnan(val) || val < 0)
    waitfor(errordlg('Invalid value. Please enter a non-negative number.','Error'));
    set(hObject, 'String', num2str(round(max(max(handles.figure1.UserData(handles.curr_frame_id).image)))));
else
    if (val < str2double(get(handles.edit_intensity_low, 'String')))
        set(hObject, 'String', get(handles.edit_intensity_low, 'String'));
        set(handles.edit_intensity_low, 'String', num2str(val));
    end
end
handles = plot_image(handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_intensity_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intensity_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end
%% MORPHOLOGY CLASSFICATION
% --- Executes on button press in pushbutton_no_cells.
function pushbutton_no_cells_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_no_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 1;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_one_cell.
function pushbutton_one_cell_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_one_cell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 2;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_two_cells.
function pushbutton_two_cells_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_two_cells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 3;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_before_mitosis.
function pushbutton_before_mitosis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_before_mitosis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 4;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_after_mitosis.
function pushbutton_after_mitosis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_after_mitosis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 5;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_apoptosis.
function pushbutton_apoptosis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apoptosis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 6;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_morphology_clear.
function pushbutton_morphology_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_morphology_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% original states
if (isempty(handles.morphology_training_set{handles.curr_frame_id}))
    id = [];
else
    id = find(handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id, 1);
end
if (isempty(id))
    original_state = 0;
else
    original_state = handles.morphology_training_set{handles.curr_frame_id}(id,2);
end

% current states
current_state = 0;

% change states
handles = change_morphology_states(handles, original_state, current_state);
guidata(hObject, handles);

end

%% MOTION CLASSIFICATION
% --- Executes on button press in pushbutton_migration_record.
function pushbutton_migration_record_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_migration_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check whether it has been assigned before
all_assignment = cell2mat(handles.motion_training_set');
if_duplicated = 0;
if (~isempty(all_assignment))
    id = find(all_assignment(:,1) == handles.curr_frame_id & all_assignment(:,2) == handles.curr_ellipse_id, 1);
    if (~isempty(id))
        if_duplicated = 1;
    end
end

% if duplicated, remove all corresponding entries
if (if_duplicated)
    for i=1:length(handles.motion_training_set)
        if (isempty(handles.motion_training_set{i}))
            continue;
        end
        id = handles.motion_training_set{i}(:,1) == handles.curr_frame_id & handles.motion_training_set{i}(:,2) == handles.curr_ellipse_id;
        handles.motion_training_set{i} = handles.motion_training_set{i}(~id, :);
    end
end

% add a new entry to the current cell ID
handles.motion_training_set{handles.curr_cell_id} = [handles.motion_training_set{handles.curr_cell_id}; [handles.curr_frame_id, handles.curr_ellipse_id]];

% change display
set(handles.text_recorded_cells_number, 'String', num2str(length(handles.motion_training_set)));
set(handles.text_current_cell_id_number, 'String', num2str(handles.curr_cell_id));
set(handles.text_intances_number, 'String', num2str(size(handles.motion_training_set{handles.curr_cell_id}, 1)));

handles.curr_ellipse_id = [];

% re-plot
handles = plot_image( handles );
handles = set_motion_state_enability( handles, 'Off');

guidata(hObject, handles);

end
% --- Executes on button press in pushbutton_migration_clear.
function pushbutton_migration_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_migration_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (isempty(handles.motion_training_set{handles.curr_cell_id}))
    return;
end
id = handles.motion_training_set{handles.curr_cell_id}(:,1) == handles.curr_frame_id & ...
    handles.motion_training_set{handles.curr_cell_id}(:,2) == handles.curr_ellipse_id;
handles.motion_training_set{handles.curr_cell_id} = handles.motion_training_set{handles.curr_cell_id}(~id, :);

% change display
set(handles.text_recorded_cells_number, 'String', num2str(length(handles.motion_training_set)));
set(handles.text_current_cell_id_number, 'String', num2str(handles.curr_cell_id));
set(handles.text_intances_number, 'String', num2str(size(handles.motion_training_set{handles.curr_cell_id}, 1)));

handles.curr_ellipse_id = [];

% re-plot
handles = plot_image( handles );
handles = set_motion_state_enability( handles, 'Off');

guidata(hObject, handles);

end

function edit_to_cell_id_Callback(hObject, eventdata, handles)
% hObject    handle to edit_to_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_to_cell_id as text
%        str2double(get(hObject,'String')) returns contents of edit_to_cell_id as a double

% check whether the input string is a valid number
val = str2double(get(hObject, 'String'));
if (isnan(val) || val~=floor(val) || val<=0)
    waitfor(errordlg('Invalid value. Please enter a positive integer.','Error'));
    set(handles.pushbutton_to_cell_id, 'Enable', 'off');
    set(hObject, 'String', '');
else
    set(handles.pushbutton_to_cell_id, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_to_cell_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_to_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_to_cell_id.
function pushbutton_to_cell_id_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_to_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set current cell id
handles.curr_cell_id = str2double(get(handles.edit_to_cell_id, 'String'));

% add additional entries in the training set
if (handles.curr_cell_id > length(handles.motion_training_set))
    handles.motion_training_set{handles.curr_cell_id} = [];
end

% enable labeling
if (~isempty(handles.curr_ellipse_id))
    handles = set_motion_state_enability(handles, 'On');
end

% set display
set(handles.text_recorded_cells_number, 'String', num2str(length(handles.motion_training_set)));
set(handles.text_current_cell_id_number, 'String', num2str(handles.curr_cell_id));
set(handles.text_intances_number, 'String', num2str(size(handles.motion_training_set{handles.curr_cell_id}, 1)));

% re-plot image
handles = plot_image( handles );

guidata(hObject, handles);

end

function edit_clear_cell_id_Callback(hObject, eventdata, handles)
% hObject    handle to edit_clear_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_clear_cell_id as text
%        str2double(get(hObject,'String')) returns contents of edit_clear_cell_id as a double

% check whether the input string is a valid number
val = str2double(get(hObject, 'String'));
if (isnan(val) || ~ismember(val, 1:length(handles.motion_training_set)))
    waitfor(errordlg('Invalid value. Please enter an existing cell ID.','Error'));
    set(hObject, 'String', []);
    set(handles.pushbutton_clear_cell_id, 'Enable', 'off');
else
    set(handles.pushbutton_clear_cell_id, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_clear_cell_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_clear_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in pushbutton_clear_cell_id.
function pushbutton_clear_cell_id_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clear_cell_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear all data in the corresponding cell ID
handles.motion_training_set{str2double(get(handles.edit_clear_cell_id, 'String'))} = [];

% set display
set(handles.text_recorded_cells_number, 'String', num2str(length(handles.motion_training_set)));
set(handles.text_current_cell_id_number, 'String', num2str(handles.curr_cell_id));
set(handles.text_intances_number, 'String', num2str(size(handles.motion_training_set{handles.curr_cell_id}, 1)));

% re-plot the image
handles = plot_image( handles );

% save data
guidata(hObject, handles);

end

%% CONTROL BUTTONS
% --- Executes on button press in pushbutton_clear_all.
function pushbutton_clear_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clear_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clear all saved training data
handles.morphology_training_set = cell(length(handles.imported_frame_id), 1);
handles.motion_training_set = [];
handles.if_morphology = 1;
handles.curr_ellipse_id = [];
handles.curr_cell_id = [];

% restore visibility
set(handles.uipanel_morphology_classification, 'Visible', 'On');
set(handles.uipanel_motion_classification, 'Visible', 'Off');
set(handles.pushbutton_next, 'Visible', 'On');
set(handles.pushbutton_finish, 'Visible', 'Off');
set(handles.pushbutton_go_to_frame_ID, 'Enable', 'off');
set(handles.pushbutton_to_cell_id, 'Enable', 'off');
set(handles.pushbutton_clear_cell_id, 'Enable', 'off');

% store uipanel-specific fields
set(handles.text_no_cells_number, 'String', '0');
set(handles.text_one_cell_number, 'String', '0');
set(handles.text_two_cells_number, 'String', '0');
set(handles.text_before_mitosis_number, 'String', '0');
set(handles.text_after_mitosis_number, 'String', '0');
set(handles.text_apoptosis_number, 'String', '0');
handles = set_morphology_state_enability(handles, 'Off');

set(handles.text_recorded_cells_number, 'String', '0');
set(handles.text_current_cell_id_number, 'String', '');
set(handles.text_intances_number, 'String', '');
handles = set_motion_state_enability(handles, 'Off');

handles = plot_image(handles);

guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% see if enough data is provided
if (str2double(get(handles.text_no_cells_number, 'String')) == 0 && ...
        str2double(get(handles.text_one_cell_number, 'String')) == 0 && ...
        str2double(get(handles.text_two_cells_number, 'String')) == 0 && ...
        str2double(get(handles.text_before_mitosis_number, 'String')) == 0 && ...
        str2double(get(handles.text_after_mitosis_number, 'String')) == 0 && ...
        str2double(get(handles.text_apoptosis_number, 'String')) == 0)
    waitfor(errordlg('Please record at least one ellipse.','Error'));
    return;
end

% change states
handles.if_morphology = 0;
handles.curr_ellipse_id = [];

% set visibility of panels
set(handles.uipanel_morphology_classification, 'Visible', 'Off');
set(handles.uipanel_motion_classification, 'Visible', 'On');
set(handles.pushbutton_next, 'Visible', 'Off');
set(handles.pushbutton_finish, 'Visible', 'On');

% re-plot the image
handles = plot_image(handles);

% save data
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_finish.
function pushbutton_finish_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% see if enough number is trained
if (isempty(handles.motion_training_set) || sum(~cellfun(@isempty, handles.motion_training_set)) < 3)
    waitfor(errordlg('Please record at least 3 cells and at least 3 ellipses for each cell.','Error'));
    return;
end

% save data
% basis data
file_path = handles.file_path;
prefix = handles.prefix;
imported_frame_id = handles.imported_frame_id;
size_image = size(handles.figure1.UserData(1).image);

% ellipse centroid
ellipse_positions = cell(length(imported_frame_id), 1);
for i=1:length(imported_frame_id)
    ellipse_positions{i} = cell2mat(handles.figure1.UserData(i).ellipse_info.all_parametric_para')';
    ellipse_positions{i} = ellipse_positions{i}(:, 3:4);
    ellipse_positions{i}(:,1) = min(max(ellipse_positions{i}(:,1), 1), size_image(2));
    ellipse_positions{i}(:,2) = min(max(ellipse_positions{i}(:,2), 1), size_image(1));
end

% morphology training set and training features
morphology_training_set = handles.morphology_training_set;
morphology_training_info = struct('features', [], 'label', [], 'source_frame', [], 'source_id', []);
for i=1:length(imported_frame_id)
    for j=1:size(morphology_training_set{i}, 1)
        curr_features = handles.figure1.UserData(i).ellipse_info.all_features{morphology_training_set{i}(j,1)};
        morphology_training_info(end+1) = struct('features', curr_features, 'label', morphology_training_set{i}(j,2), 'source_frame', imported_frame_id(i), 'source_id', morphology_training_set{i}(j,1));
    end
end
morphology_training_info = morphology_training_info(2:end);

% motion training set and training features
motion_training_set = handles.motion_training_set;
motion_training_set = motion_training_set(~cellfun(@isempty, motion_training_set));
motion_training_info = struct('features', [], 'label', [], 'source_cell_id', [], 'source_frame', [], 'source_id', []);
motion_distances = struct('dist_x', [], 'dist_y', [], 'dist_s', [], 'dist_t', []);

% first sort motion training set
for i=1:length(motion_training_set)
    if (isempty(motion_training_set{i}))
        continue;
    end
    [~, id] = sort(motion_training_set{i}(:,1));
    motion_training_set{i} = motion_training_set{i}(id,:);
end

% add training data for the same cell (i.e. same cell id). 1 for same cell.
for i=1:length(motion_training_set)
    for j=2:size(motion_training_set{i},1)
        % motion similarity info
        prev_frame = motion_training_set{i}(j-1, 1); prev_ellipse = motion_training_set{i}(j-1, 2);
        prev_features = handles.figure1.UserData(prev_frame).ellipse_info.all_features{prev_ellipse};
        curr_frame = motion_training_set{i}(j, 1); curr_ellipse = motion_training_set{i}(j, 2);
        curr_features = handles.figure1.UserData(curr_frame).ellipse_info.all_features{curr_ellipse};
        motion_training_info(end+1) = struct('features', curr_features-prev_features, 'label', 1, ...
            'source_cell_id', [i;i], 'source_frame', [prev_frame;curr_frame], 'source_id', [prev_ellipse;curr_ellipse]);
        
        % motion distance
        prev_position = handles.figure1.UserData(prev_frame).ellipse_info.all_parametric_para{prev_ellipse}(3:4);
        curr_position = handles.figure1.UserData(curr_frame).ellipse_info.all_parametric_para{curr_ellipse}(3:4);
        motion_distances(end+1) = struct('dist_x', curr_position(1)-prev_position(1), 'dist_y', curr_position(2)-prev_position(2), 'dist_s', norm(curr_position-prev_position), 'dist_t', abs(curr_frame-prev_frame));
    end
end
% add training data for different cells (i.e. different cell id). 0 for
% different cells.
for i=1:length(motion_training_set)
    % randomly select up to 3 entries
    id = randperm(size(motion_training_set{i}, 1));
    if (length(id) > 3)
        id = id(1:3);
    end
    prev_frame = motion_training_set{i}(id, 1); prev_ellipse = motion_training_set{i}(id, 2);
    for j=(i+1):length(motion_training_set)
        id = randperm(size(motion_training_set{j}, 1));
        if (length(id) > 3)
            id = id(1:3);
        end
        curr_frame = motion_training_set{j}(id, 1); curr_ellipse = motion_training_set{j}(id, 2);
        % for every pair of prev and curr entries, compute the difference
        % and assign features
        for prev_k = 1:length(prev_frame)
            for curr_k = 1:length(curr_frame)
                motion_training_info(end+1) = struct('features', ...
                    - handles.figure1.UserData(prev_frame(prev_k)).ellipse_info.all_features{prev_ellipse(prev_k)} ...
                    + handles.figure1.UserData(curr_frame(curr_k)).ellipse_info.all_features{curr_ellipse(curr_k)}, ...
                    'label', 0, 'source_cell_id', [i;j], 'source_frame', [prev_frame(prev_k); curr_frame(curr_k)], ...
                    'source_id', [prev_ellipse(prev_k); curr_ellipse(curr_k)]);
            end
        end
    end
end
motion_training_info = motion_training_info(2:end);
motion_distances = motion_distances(2:end);

save([handles.output_path, 'training_data_', num2str(imported_frame_id(1)), '_', num2str(imported_frame_id(end)), '.mat'], ...
    'file_path', 'prefix', 'imported_frame_id', 'size_image', 'ellipse_positions', ...
    'morphology_training_set', 'morphology_training_info', ...
    'motion_training_set', 'motion_training_info','motion_distances');

% reset the program
handles.file_path = []; set(handles.edit_file_path, 'String', '');
handles.prefix = []; set(handles.edit_prefix, 'String', '');
handles.imported_frame_id = []; set(handles.edit_first_imported_frame_id, 'String', ''); set(handles.edit_last_imported_frame_id, 'String', '');
handles.cmos_path = []; set(handles.edit_cmos, 'String', '');
handles.bias_path = []; set(handles.edit_bias, 'String', '');
handles.segmentation_path = []; set(handles.edit_path_segmentation, 'String', '');
handles.existing_path = []; set(handles.edit_path_existing, 'String', '');
handles.output_path = []; set(handles.edit_path_output, 'String', '');
handles.curr_frame_id = [];
handles.curr_ellipse_id = [];
handles.if_morphology = [];
handles.curr_cell_id = [];
handles.figure1.UserData = [];
handles.morphology_training_set = {};
handles.motion_training_set = [];

cla(handles.axes1);
set(handles.text_no_cells_number, 'String', '0');
set(handles.text_one_cell_number, 'String', '0');
set(handles.text_two_cells_number, 'String', '0');
set(handles.text_before_mitosis_number, 'String', '0');
set(handles.text_after_mitosis_number, 'String', '0');
set(handles.text_apoptosis_number, 'String', '0');
set(handles.text_recorded_cells_number, 'String', '0');
set(handles.text_current_cell_id_number, 'String', '');
set(handles.text_intances_number, 'String', '');

handles = set_setting_enability(handles, 'On');
handles = set_morphology_state_enability(handles, 'Off');
handles = set_motion_state_enability(handles, 'Off');
set(handles.pushbutton_go_to_frame_ID, 'Enable', 'off');
set(handles.pushbutton_to_cell_id, 'Enable', 'off');
set(handles.pushbutton_clear_cell_id, 'Enable', 'off');

set(handles.axes1, 'Visible', 'Off');
set(handles.uipanel_nav_frames, 'Visible', 'Off');
set(handles.uipanel_morphology_classification, 'Visible', 'Off');
set(handles.uipanel_motion_classification, 'Visible', 'Off');
set(handles.pushbutton_clear_all, 'Visible', 'Off');
set(handles.pushbutton_next, 'Visible', 'Off');
set(handles.pushbutton_finish, 'Visible', 'Off');

guidata(hObject, handles);

end

%% SELF_DEFINED FUNCTIONS
function [ handles ] = set_setting_enability( handles, state )

set(handles.edit_file_path, 'Enable', state);
set(handles.pushbutton_select_path, 'Enable', state);
set(handles.edit_prefix, 'Enable', state);
set(handles.edit_first_imported_frame_id, 'Enable', state);
set(handles.edit_last_imported_frame_id, 'Enable', state);
set(handles.edit_cmos, 'Enable', state);
set(handles.pushbutton_cmos, 'Enable', state);
set(handles.edit_bias, 'Enable', state);
set(handles.pushbutton_bias, 'Enable', state);
set(handles.edit_path_segmentation, 'Enable', state);
set(handles.pushbutton_path_segmentation, 'Enable', state);
set(handles.edit_path_existing, 'Enable', state);
set(handles.pushbutton_path_existing, 'Enable', state);
set(handles.edit_path_output, 'Enable', state);
set(handles.pushbutton_path_output, 'Enable', state);
set(handles.pushbutton_import_to_workspace, 'Enable', state);

end

function [ handles ] = set_morphology_state_enability( handles, state )

set(handles.pushbutton_no_cells, 'Enable', state);
set(handles.pushbutton_one_cell, 'Enable', state);
set(handles.pushbutton_two_cells, 'Enable', state);
set(handles.pushbutton_before_mitosis, 'Enable', state);
set(handles.pushbutton_after_mitosis, 'Enable', state);
set(handles.pushbutton_apoptosis, 'Enable', state);
set(handles.pushbutton_morphology_clear, 'Enable', state);

end

function [ handles ] = set_motion_state_enability( handles, state )

set(handles.pushbutton_migration_record, 'Enable', state);
set(handles.pushbutton_migration_clear, 'Enable', state);

end

function [ handles ] = change_morphology_states( handles, original_state, current_state )

num_class = 6;
state_change = zeros(num_class,1);
% clear a selection, but with no states
if ( original_state == 0 && current_state == 0 )
    handles = set_morphology_state_enability( handles, 'Off' );
elseif ( original_state == current_state ) % nothing changed, do nothing
elseif ( original_state == 0 ) % add a new state
    handles.morphology_training_set{handles.curr_frame_id} = [handles.morphology_training_set{handles.curr_frame_id}; [handles.curr_ellipse_id, current_state]];
    state_change(current_state) = 1;
elseif ( current_state == 0) % remove a state
    id = handles.morphology_training_set{handles.curr_frame_id}(:,1) ~= handles.curr_ellipse_id;
    handles.morphology_training_set{handles.curr_frame_id} = handles.morphology_training_set{handles.curr_frame_id}(id,:);
    state_change(original_state) = -1;
else % change a state
    id = handles.morphology_training_set{handles.curr_frame_id}(:,1) == handles.curr_ellipse_id;
    handles.morphology_training_set{handles.curr_frame_id}(id,2) = current_state;
    state_change(original_state) = -1;
    state_change(current_state) = 1;
end
    
handles.curr_ellipse_id = [];
handles = set_morphology_state_enability( handles, 'Off' );

% plot the new image
handles = plot_image( handles );

% set the new counter
set(handles.text_no_cells_number, 'String', num2str(str2double(get(handles.text_no_cells_number, 'String')) + state_change(1)));
set(handles.text_one_cell_number, 'String', num2str(str2double(get(handles.text_one_cell_number, 'String')) + state_change(2)));
set(handles.text_two_cells_number, 'String', num2str(str2double(get(handles.text_two_cells_number, 'String')) + state_change(3)));
set(handles.text_before_mitosis_number, 'String', num2str(str2double(get(handles.text_before_mitosis_number, 'String')) + state_change(4)));
set(handles.text_after_mitosis_number, 'String', num2str(str2double(get(handles.text_after_mitosis_number, 'String')) + state_change(5)));
set(handles.text_apoptosis_number, 'String', num2str(str2double(get(handles.text_apoptosis_number, 'String')) + state_change(6)));

end

function [ handles ] = plot_image( handles )

% get intensity range
min_intensity = str2double(get(handles.edit_intensity_low, 'String'));
max_intensity = str2double(get(handles.edit_intensity_high, 'String'));
temp = handles.figure1.UserData(handles.curr_frame_id).image;
temp = (min(max(temp, min_intensity), max_intensity) - min_intensity)/(max_intensity-min_intensity);

% set current figure number
set(handles.text_curr_frame_id, 'String', num2str(handles.imported_frame_id(handles.curr_frame_id)));

% plot base image
cla(handles.axes1); h_image = imshow(temp, 'Parent', handles.axes1);
hold on; set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn); 

% plot existing ellipses
all_boundary_points = handles.figure1.UserData(handles.curr_frame_id).ellipse_info.all_boundary_points;
all_parametric_para = handles.figure1.UserData(handles.curr_frame_id).ellipse_info.all_parametric_para;
for i=1:length(all_boundary_points)
    h_image = plot(all_boundary_points{i}(:,2), all_boundary_points{i}(:,1), 'Color', [0.8, 0.5, 0.5], 'LineWidth', 1);
    set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn);
end

% for morphology training set
if (handles.if_morphology)
    % plot in color for existing learned stuff
    color_list = [get(handles.text_no_cell_color, 'BackgroundColor');
        get(handles.text_one_cell_color, 'BackgroundColor');
        get(handles.text_two_cells_color, 'BackgroundColor');
        get(handles.text_before_mitosis_color, 'BackgroundColor');
        get(handles.text_after_mitosis_color, 'BackgroundColor');
        get(handles.text_apoptosis_color, 'BackgroundColor')];

    training_set = handles.morphology_training_set{handles.curr_frame_id};
    for i=1:size(training_set, 1)
        h_image = patch(all_boundary_points{training_set(i,1)}(:,2), all_boundary_points{training_set(i,1)}(:,1), ...
            color_list(training_set(i,2),:), 'FaceAlpha', 1);
        set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn);
    end
else
    % for motion training set
    % plot in color for this cell id
    if (~isempty(handles.curr_cell_id) && ~isempty(handles.motion_training_set{handles.curr_cell_id}))
        id = handles.motion_training_set{handles.curr_cell_id}(:,1) == handles.curr_frame_id;
        ellipse_id_to_plot = handles.motion_training_set{handles.curr_cell_id}(id,2);
        for i=1:length(ellipse_id_to_plot)
            h_image = patch(all_boundary_points{ellipse_id_to_plot(i)}(:,2), all_boundary_points{ellipse_id_to_plot(i)}(:,1), ...
                [1, 0, 0], 'FaceAlpha', 1);
            set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn);
        end
    end
    
    % plot with text for other cell id
    for i=1:length(handles.motion_training_set)
        if (isempty(handles.motion_training_set{i}))
            continue;
        end
        id = handles.motion_training_set{i}(:,1) == handles.curr_frame_id;
        ellipse_id_to_plot = handles.motion_training_set{i}(id,2);
        for j=1:length(ellipse_id_to_plot)
            h_image = patch(all_boundary_points{ellipse_id_to_plot(j)}(:,2), all_boundary_points{ellipse_id_to_plot(j)}(:,1), ...
                [0.8, 0.5, 0.5], 'FaceAlpha', 0.5);
            set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn);
            h_image = text(all_parametric_para{ellipse_id_to_plot(j)}(3), all_parametric_para{ellipse_id_to_plot(j)}(4), ...
                num2str(i), 'Color', [0.5, 0.8, 0.5], 'FontSize', 10);
            set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn);
        end
    end
end

% plot the currently selected ellipse
if (~isempty(handles.curr_ellipse_id)) 
    h_image = patch(all_boundary_points{handles.curr_ellipse_id}(:,2), all_boundary_points{handles.curr_ellipse_id}(:,1), ...
        'black', 'FaceAlpha', 1);
    set(h_image, 'ButtonDownFcn', @fig_image_ButtonDownFcn);
end
hold off;

end


function fig_image_ButtonDownFcn(hObject, eventdata)

% check whether the mouse position is within an ellipse
handles = guidata(hObject);
temp_hObject = handles.axes1;
cursorPoint = round(get(handles.axes1, 'CurrentPoint'));
cursorPoint(1,1) = min(max(cursorPoint(1,1), 1), size(handles.figure1.UserData(handles.curr_frame_id).image, 2));
cursorPoint(1,2) = min(max(cursorPoint(1,2), 1), size(handles.figure1.UserData(handles.curr_frame_id).image, 1));

all_internal_points = handles.figure1.UserData(handles.curr_frame_id).ellipse_info.all_internal_points;
ellipse_id = false(size(all_internal_points, 1), 1);
for i=1:size(all_internal_points, 1)
    id = find(all_internal_points{i}(:,1) == cursorPoint(1,2) & all_internal_points{i}(:,2) == cursorPoint(1,1), 1);
    if (~isempty(id))
        ellipse_id(i) = true;
    end
end
ellipse_id = find(ellipse_id);
if (length(ellipse_id)~= 1)
    return;
end
handles.curr_ellipse_id = ellipse_id;
if (handles.if_morphology)
    handles = set_morphology_state_enability(handles, 'On');
else
    if (~isempty(handles.curr_cell_id))
        handles = set_motion_state_enability(handles, 'On');
    end
end
handles = plot_image(handles);
guidata(temp_hObject, handles);

end

%% KEYPRESS FUNCTION
% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% try to examine whether images has been loaded or not
if (strcmp(get(handles.uipanel_nav_frames, 'Visible'), 'Off'))
    return
end

switch (eventdata.Key)
    case '1' % morphology, no cell 
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_no_cells_Callback(handles.pushbutton_no_cells, eventdata, handles);
        end
    case '2' % morphology, 1 cell
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_one_cell_Callback(handles.pushbutton_one_cell, eventdata, handles);
        end
    case '3' % morphology, 2 cells
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_two_cells_Callback(handles.pushbutton_two_cells, eventdata, handles);
        end
    case '4' % morphology, before M
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_before_mitosis_Callback(handles.pushbutton_before_mitosis, eventdata, handles);
        end
    case '5' % morphology, after M
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_after_mitosis_Callback(handles.pushbutton_after_mitosis, eventdata, handles);
        end
    case '6' % morphology, apoptosis
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_apoptosis_Callback(handles.pushbutton_apoptosis, eventdata, handles);
        end
    case 'c' % morphology + motion, clear
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (handles.if_morphology)
            pushbutton_morphology_clear_Callback(handles.pushbutton_morphology_clear, eventdata, handles);
        elseif (~isempty(handles.curr_cell_id))
            pushbutton_migration_clear_Callback(handles.pushbutton_migration_clear, eventdata, handles);
        end
    case 'r' % motion, record
        if (isempty(handles.curr_ellipse_id))
            return;
        end
        if (~handles.if_morphology && ~isempty(handles.curr_cell_id))
            pushbutton_migration_record_Callback(handles.pushbutton_migration_record, eventdata, handles);
        end
    case 'leftarrow' % -1
        pushbutton_go_by_1_frame_prev_Callback(handles.pushbutton_go_by_1_frame_prev, eventdata, handles);
    case 'rightarrow' % +1
        pushbutton_go_by_1_frame_next_Callback(handles.pushbutton_go_by_1_frame_next, eventdata, handles);
    case 'downarrow' % -10
        pushbutton_go_by_10_frames_prev_Callback(handles.pushbutton_go_by_10_frames_prev, eventdata, handles);
    case 'uparrow' % +10
        pushbutton_go_by_10_frames_next_Callback(handles.pushbutton_go_by_10_frames_next, eventdata, handles);
end

end


% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

% try to examine whether images has been loaded or not
if (strcmp(get(handles.uipanel_nav_frames, 'Visible'), 'Off'))
    return
end

if (eventdata.VerticalScrollCount > 0)
    pushbutton_go_by_1_frame_next_Callback(handles.pushbutton_go_by_1_frame_next, eventdata, handles);
elseif (eventdata.VerticalScrollCount < 0)
    pushbutton_go_by_1_frame_prev_Callback(handles.pushbutton_go_by_1_frame_prev, eventdata, handles);
end

end
