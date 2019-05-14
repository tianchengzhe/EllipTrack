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

% Last Modified by GUIDE v2.5 02-May-2019 06:48:43

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
% --- Executes when figure is resized.
function figure_SizeChangedFcn(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
% hObject    handle to figure (see GCBO)
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

% Choose default command line output for parameter_generator_gui
handles.output = hObject;

% make default stuff
handles.curr_parameters = []; handles.old_parameters = [];
handles.if_tif = []; handles.if_new = 1; handles.load_path = [];
handles.num_signal = [];
handles.row_from = []; handles.row_to = [];
handles.col_from = []; handles.col_to = [];
handles.site_from = []; handles.site_to = [];
handles.frame_from = []; handles.frame_to = [];

% make read visible and all others invisible
set(handles.radiobutton_ifnew_yes, 'Visible', 'on', 'Value', 1);
set(handles.radiobutton_ifnew_no, 'Visible', 'on', 'Value', 0);
set(handles.edit_load, 'Visible', 'off');
set(handles.pushbutton_load, 'Visible', 'off');
set(handles.pushbutton_start, 'Visible', 'on', 'Enable', 'on');

% make all panels, clear all, save to be invisible
set(handles.uipanel1_step1, 'Visible', 'off');
set(handles.uipanel1_step2, 'Visible', 'off');
set(handles.uipanel1_step3, 'Visible', 'off');
set(handles.uipanel2, 'Visible', 'off');
set(handles.uipanel3, 'Visible', 'off');
set(handles.uipanel4, 'Visible', 'off');
set(handles.pushbutton_clearall, 'Visible', 'off');
set(handles.pushbutton_save, 'Visible', 'off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes parameter_generator_gui wait for user response (see UIRESUME)
% uiwait(handles.figure);
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

%% Read, load, clear, save
% --- Executes on button press in radiobutton_ifnew_yes.
function radiobutton_ifnew_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_ifnew_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_ifnew_yes

handles.if_new = 1;
handles.load_path = '';
set(handles.edit_load, 'Visible', 'off', 'String', []);
set(handles.pushbutton_load, 'Visible', 'off');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton_ifnew_no.
function radiobutton_ifnew_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_ifnew_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_ifnew_no

handles.if_new = 0;
set(handles.edit_load, 'Visible', 'on');
set(handles.pushbutton_load, 'Visible', 'on');
guidata(hObject, handles);

end

function edit_load_Callback(hObject, eventdata, handles)
% hObject    handle to edit_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_load as text
%        str2double(get(hObject,'String')) returns contents of edit_load as a double

curr_str = get(handles.edit_load, 'String');
if (length(curr_str) >= 2 && strcmp(curr_str(end-1:end), '.m'))
    handles.load_path = curr_str;
else
    set(handles.edit_load, 'String', []);
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_load_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.m', 'Select Existing Parameter File');
if ~isequal(file, 0)
    handles.load_path = fullfile(path,file);
    set(handles.edit_load, 'String', fullfile(path,file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable all buttons temporarily
set(handles.radiobutton_ifnew_yes, 'Enable', 'Off');
set(handles.radiobutton_ifnew_no, 'Enable', 'Off');
set(handles.edit_load, 'Enable', 'Off');
set(handles.pushbutton_load, 'Enable', 'Off');
set(handles.pushbutton_start, 'Enable', 'Off');
pause(eps);

% read and update entries
try
    % read files
    if (handles.if_new) % read from template
        read_para = load('default_parameters.mat');
    else % read from existing file
        temp = function_handle(handles.load_path);
        read_para = temp();
    end
    
    % update all entries
    % in case of errors, handles will not be updated and therefore no need
    % to revert any entries.
    handles = update_entries(handles, read_para); 
    
    % finally make the first panel visible. should not have any error at
    % this stage
    set(handles.uipanel1_step1, 'Visible', 'on');
    set(handles.pushbutton_clearall, 'Visible', 'on');
    set(handles.pushbutton_save, 'Visible', 'on');
catch
    errordlg('Parameters are not successfully loaded.');
    % reverse all changes to opening
    set(handles.radiobutton_ifnew_yes, 'Enable', 'On');
    set(handles.radiobutton_ifnew_no, 'Enable', 'On');
    set(handles.edit_load, 'Enable', 'On');
    set(handles.pushbutton_load, 'Enable', 'On');
    set(handles.pushbutton_start, 'Enable', 'On');  
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_clearall.
function pushbutton_clearall_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clearall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% revert parameters back
handles = update_entries(handles, handles.old_parameters);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% write file
write_para_file(handles);

% clear all. no need to update specific info of each panel, because they
% will be updated later.
handles.curr_parameters = []; handles.old_parameters = [];
handles.if_tif = []; handles.if_new = 1; handles.load_path = [];
handles.num_signal = [];
handles.row_from = []; handles.row_to = [];
handles.col_from = []; handles.col_to = [];
handles.site_from = []; handles.site_to = [];
handles.frame_from = []; handles.frame_to = [];

set(handles.radiobutton_ifnew_yes, 'Visible', 'on', 'Enable', 'on', 'Value', 1);
set(handles.radiobutton_ifnew_no, 'Visible', 'on', 'Enable', 'on', 'Value', 0);
set(handles.edit_load, 'Visible', 'off', 'Enable', 'on', 'String', []);
set(handles.pushbutton_load, 'Visible', 'off', 'Enable', 'on');
set(handles.pushbutton_start, 'Visible', 'on', 'Enable', 'on');

set(handles.uipanel1_step1, 'Visible', 'off');
set(handles.uipanel1_step2, 'Visible', 'off');
set(handles.uipanel1_step3, 'Visible', 'off');
set(handles.uipanel2, 'Visible', 'off');
set(handles.uipanel3, 'Visible', 'off');
set(handles.uipanel4, 'Visible', 'off');
set(handles.pushbutton_clearall, 'Visible', 'off');
set(handles.pushbutton_save, 'Visible', 'off');

guidata(hObject, handles);

end

%% Previous step, next step
% --- Executes on button press in pushbutton1_prevstep.
function pushbutton1_prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

% --- Executes on button press in pushbutton1_nextstep.
function pushbutton1_nextstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1_step1, 'Visible', 'off');
set(handles.uipanel1_step2, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_step2_prevstep.
function pushbutton1_step2_prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_step2_prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1_step2, 'Visible', 'off');
set(handles.uipanel1_step1, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_step2_nextstep.
function pushbutton1_step2_nextstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_step2_nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1_step2, 'Visible', 'off');
set(handles.uipanel1_step3, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_step3_prevstep.
function pushbutton1_step3_prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_step3_prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1_step3, 'Visible', 'off');
set(handles.uipanel1_step2, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_step3_nextstep.
function pushbutton1_step3_nextstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_step3_nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel1_step3, 'Visible', 'off');
set(handles.uipanel2, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton2_prevstep.
function pushbutton2_prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2_prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel2, 'Visible', 'off');
set(handles.uipanel1_step3, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton2_nextstep.
function pushbutton2_nextstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2_nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel2, 'Visible', 'off');
set(handles.uipanel3, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton3_prevstep.
function pushbutton3_prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3_prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel3, 'Visible', 'off');
set(handles.uipanel2, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton3_nextstep.
function pushbutton3_nextstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3_nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel3, 'Visible', 'off');
set(handles.uipanel4, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton4_prevstep.
function pushbutton4_prevstep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4_prevstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.uipanel4, 'Visible', 'off');
set(handles.uipanel3, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton4_nextstep.
function pushbutton4_nextstep_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to pushbutton4_nextstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

%% General Information; Movie Definition
% --- Executes on button press in radiobutton1_3_filetype_tif.
function radiobutton1_3_filetype_tif_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_filetype_tif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_filetype_tif

% change setting
handles.if_tif = 1;

% remove all saved image path information
handles.curr_parameters.global_setting.nuc_raw_image_path = [];
handles.curr_parameters.global_setting.nd2_frame_range = [];
handles.curr_parameters.signal_extraction_para.additional_raw_image_paths = cell(handles.num_signal-1, 1);
set(handles.edit1_3_imagepath, 'String', [], 'Enable', 'on');

% save data
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_filetype_nd2.
function radiobutton1_3_filetype_nd2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_filetype_nd2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_filetype_nd2

% change setting
handles.if_tif = 0;

% remove all saved image path information
handles.curr_parameters.global_setting.nuc_raw_image_path = [];
handles.curr_parameters.global_setting.nd2_frame_range = [];
handles.curr_parameters.signal_extraction_para.additional_raw_image_paths = cell(handles.num_signal-1, 1);
set(handles.edit1_3_imagepath, 'String', '0 Entries', 'Enable', 'off');

% save data
guidata(hObject, handles);

end

function edit1_3_imagepath_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_imagepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_imagepath as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_imagepath as a double

% should only happen for tif format!
if (handles.if_tif)
    curr_path = get(handles.edit1_3_imagepath, 'String');
    handles.curr_parameters.global_setting.nuc_raw_image_path = curr_path;
    handles.curr_parameters.signal_extraction_para.additional_raw_image_paths(:) = {curr_path};
end

% save data
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_imagepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_imagepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_imagepath.
function pushbutton1_3_imagepath_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_imagepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% need to consider file type separately
if (handles.if_tif) % only read a single folder
    curr_path = uigetdir('.', 'Select Folder of Raw Images');
    if (~isequal(curr_path, 0)) % succeed
        set(handles.edit1_3_imagepath, 'String', curr_path);
        handles.curr_parameters.global_setting.nuc_raw_image_path = curr_path;
        handles.curr_parameters.signal_extraction_para.additional_raw_image_paths(:) = {curr_path};
    end
else % read multiple folders
    curr_path = uigetfile_n_dir('.', 'Select Folders of Raw Images')';
    if (~isempty(curr_path)) % succeed
        set(handles.edit1_3_imagepath, 'String', [num2str(size(curr_path, 1)), ' Entries']);
        handles.curr_parameters.global_setting.nuc_raw_image_path = curr_path;
        handles.curr_parameters.signal_extraction_para.additional_raw_image_paths(:) = {curr_path};
    end
end

% save data
guidata(hObject, handles);

end

function edit1_3_wells_rowsfrom_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_rowsfrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_wells_rowsfrom as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_wells_rowsfrom as a double

curr_val = get(handles.edit1_3_wells_rowsfrom, 'String');
if check_if_number(curr_val)
    handles.row_from = str2double(curr_val);
else
    set(handles.edit1_3_wells_rowsfrom, 'String', num2str(handles.row_from));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_wells_rowsfrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_rowsfrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_wells_rowsto_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_rowsto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_wells_rowsto as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_wells_rowsto as a double

curr_val = get(handles.edit1_3_wells_rowsto, 'String');
if check_if_number(curr_val)
    handles.row_to = str2double(curr_val);
else
    set(handles.edit1_3_wells_rowsto, 'String', num2str(handles.row_to));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_wells_rowsto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_rowsto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_wells_colsfrom_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_colsfrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_wells_colsfrom as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_wells_colsfrom as a double

curr_val = get(handles.edit1_3_wells_colsfrom, 'String');
if check_if_number(curr_val)
    handles.col_from = str2double(curr_val);
else
    set(handles.edit1_3_wells_colsfrom, 'String', num2str(handles.col_from));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_wells_colsfrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_colsfrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_wells_colsto_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_colsto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_wells_colsto as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_wells_colsto as a double

curr_val = get(handles.edit1_3_wells_colsto, 'String');
if check_if_number(curr_val)
    handles.col_to = str2double(curr_val);
else
    set(handles.edit1_3_wells_colsto, 'String', num2str(handles.col_to));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_wells_colsto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_colsto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_wells_sitesfrom_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_sitesfrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_wells_sitesfrom as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_wells_sitesfrom as a double

curr_val = get(handles.edit1_3_wells_sitesfrom, 'String');
if check_if_number(curr_val)
    handles.site_from = str2double(curr_val);
else
    set(handles.edit1_3_wells_sitesfrom, 'String', num2str(handles.site_from));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_wells_sitesfrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_sitesfrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_wells_sitesto_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_sitesto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_wells_sitesto as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_wells_sitesto as a double

curr_val = get(handles.edit1_3_wells_sitesto, 'String');
if check_if_number(curr_val)
    handles.site_to = str2double(curr_val);
else
    set(handles.edit1_3_wells_sitesto, 'String', num2str(handles.site_to));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_wells_sitesto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_wells_sitesto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_frames_from_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_frames_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_frames_from as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_frames_from as a double

curr_val = get(handles.edit1_3_frames_from, 'String');
if check_if_number(curr_val)
    handles.frame_from = str2double(curr_val);
else
    set(handles.edit1_3_frames_from, 'String', num2str(handles.frame_from));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_frames_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_frames_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_frames_to_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_frames_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_frames_to as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_frames_to as a double

curr_val = get(handles.edit1_3_frames_to, 'String');
if check_if_number(curr_val)
    handles.frame_to = str2double(curr_val);
else
    set(handles.edit1_3_frames_to, 'String', num2str(handles.frame_to));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_frames_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_frames_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_3_cmos_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_cmos as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_cmos as a double

handles.curr_parameters.global_setting.cmosoffset_path = get(handles.edit1_3_cmos, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_cmos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_cmos.
function pushbutton1_3_cmos_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_cmos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat', 'Select CMOS Offset');
if ~isequal(file, 0)
    handles.curr_parameters.global_setting.cmosoffset_path = fullfile(path,file);
    set(handles.edit1_3_cmos, 'String', fullfile(path,file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_3_cmos_cancel.
function pushbutton1_3_cmos_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_cmos_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit1_3_cmos, 'String', []);
handles.curr_parameters.global_setting.cmosoffset_path = '';
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_jitter_yes.
function radiobutton1_3_jitter_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_jitter_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_jitter_yes

handles.curr_parameters.global_setting.if_global_correction = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_jitter_no.
function radiobutton1_3_jitter_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_jitter_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_jitter_no

handles.curr_parameters.global_setting.if_global_correction = 0;
guidata(hObject, handles);

end

%% General Information, Cell Definition
function edit1_2_nucradius_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_nucradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_nucradius as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_nucradius as a double

curr_val = get(handles.edit1_2_nucradius, 'String');
if check_if_number(curr_val) % succeed
    handles.curr_parameters.segmentation_para.nuc_radius = str2double(curr_val);
else
    set(handles.edit1_2_nucradius, 'String', num2str(handles.curr_parameters.segmentation_para.nuc_radius));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_nucradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_nucradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in radiobutton1_2_numsignals_1.
function radiobutton1_2_numsignals_1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_numsignals_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_numsignals_1

handles = adjust_num_signal(handles, 1);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_numsignals_2.
function radiobutton1_2_numsignals_2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_numsignals_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_numsignals_2

handles = adjust_num_signal(handles, 2);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_numsignals_3.
function radiobutton1_2_numsignals_3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_numsignals_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_numsignals_3

handles = adjust_num_signal(handles, 3);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_numsignals_4.
function radiobutton1_2_numsignals_4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_numsignals_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_numsignals_4

handles = adjust_num_signal(handles, 4);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_numsignals_5.
function radiobutton1_2_numsignals_5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_numsignals_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_numsignals_5

handles = adjust_num_signal(handles, 5);
guidata(hObject, handles);

end

function edit1_2_signals_sig1_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig1_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig1_signal as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig1_signal as a double

curr_str = get(handles.edit1_2_signals_sig1_signal, 'String');
if (~isempty(curr_str))
    handles.curr_parameters.global_setting.nuc_signal_name = curr_str;
else
    set(handles.edit1_2_signals_sig1_signal, 'String', handles.curr_parameters.global_setting.nuc_signal_name);
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig1_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig1_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig1_biomarker_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig1_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig1_biomarker as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig1_biomarker as a double

curr_str = get(handles.edit1_2_signals_sig1_biomarker, 'String');
if (~isempty(curr_str) && check_if_numberORletter(curr_str))
    if (~check_if_letter(curr_str(1))) % first letter is a not a letter
        curr_str = ['_', curr_str];
    end
    handles.curr_parameters.global_setting.nuc_biomarker_name = curr_str;
else
    set(handles.edit1_2_signals_sig1_biomarker, 'String', handles.curr_parameters.global_setting.nuc_biomarker_name);
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig1_biomarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig1_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig1_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig1_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig1_bias as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig1_bias as a double

handles.curr_parameters.global_setting.nuc_bias_path = get(handles.edit1_2_signals_sig1_bias, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig1_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig1_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_2_signals_sig1_bias.
function pushbutton1_2_signals_sig1_bias_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig1_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('.mat', 'Select Bias for the Nuclear Channel');
if ~isequal(file, 0)
    handles.curr_parameters.global_setting.nuc_bias_path = fullfile(path, file);
    set(handles.edit1_2_signals_sig1_bias, 'String', fullfile(path, file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_2_signals_sig1_bias_cancel.
function pushbutton1_2_signals_sig1_bias_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig1_bias_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_parameters.global_setting.nuc_bias_path = '';
set(handles.edit1_2_signals_sig1_bias, 'String', []);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig1_cytoring_yes.
function radiobutton1_2_signals_sig1_cytoring_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig1_cytoring_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig1_cytoring_no

end

% --- Executes on button press in radiobutton1_2_signals_sig1_cytoring_no.
function radiobutton1_2_signals_sig1_cytoring_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig1_cytoring_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig1_cytoring_no

end

function edit1_2_signals_sig2_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig2_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig2_signal as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig2_signal as a double

curr_str = get(handles.edit1_2_signals_sig2_signal, 'String');
if (~isempty(curr_str))
    handles.curr_parameters.signal_extraction_para.additional_signal_names{1} = curr_str;
else
    set(handles.edit1_2_signals_sig2_signal, 'String', handles.curr_parameters.signal_extraction_para.additional_signal_names{1});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig2_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig2_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig2_biomarker_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig2_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig2_biomarker as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig2_biomarker as a double

curr_str = get(handles.edit1_2_signals_sig2_biomarker, 'String');
if (~isempty(curr_str) && check_if_numberORletter(curr_str))
    if (~check_if_letter(curr_str(1))) % first letter is a not a letter
        curr_str = ['_', curr_str];
    end
    handles.curr_parameters.signal_extraction_para.additional_biomarker_names{1} = curr_str;
else
    set(handles.edit1_2_signals_sig2_biomarker, 'String', handles.curr_parameters.signal_extraction_para.additional_biomarker_names{1});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig2_biomarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig2_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig2_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig2_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig2_bias as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig2_bias as a double

handles.curr_parameters.signal_extraction_para.additional_bias_paths{1} = get(handles.edit1_2_signals_sig2_bias, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig2_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig2_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_2_signals_sig2_bias.
function pushbutton1_2_signals_sig2_bias_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig2_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('.mat', 'Select Bias for Signal 2');
if ~isequal(file, 0)
    handles.curr_parameters.signal_extraction_para.additional_bias_paths{1} = fullfile(path, file);
    set(handles.edit1_2_signals_sig2_bias, 'String', fullfile(path, file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_2_signals_sig2_bias_cancel.
function pushbutton1_2_signals_sig2_bias_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig2_bias_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_parameters.signal_extraction_para.additional_bias_paths{1} = '';
set(handles.edit1_2_signals_sig2_bias, 'String', []);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig2_cytoring_yes.
function radiobutton1_2_signals_sig2_cytoring_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig2_cytoring_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig2_cytoring_yes

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(1) = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig2_cytoring_no.
function radiobutton1_2_signals_sig2_cytoring_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig2_cytoring_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig2_cytoring_no

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(1) = 0;
guidata(hObject, handles);

end

function edit1_2_signals_sig3_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig3_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig3_signal as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig3_signal as a double

curr_str = get(handles.edit1_2_signals_sig3_signal, 'String');
if (~isempty(curr_str))
    handles.curr_parameters.signal_extraction_para.additional_signal_names{2} = curr_str;
else
    set(handles.edit1_2_signals_sig3_signal, 'String', handles.curr_parameters.signal_extraction_para.additional_signal_names{2});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig3_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig3_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig3_biomarker_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig3_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig3_biomarker as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig3_biomarker as a double

curr_str = get(handles.edit1_2_signals_sig3_biomarker, 'String');
if (~isempty(curr_str) && check_if_numberORletter(curr_str))
    if (~check_if_letter(curr_str(1))) % first letter is a not a letter
        curr_str = ['_', curr_str];
    end
    handles.curr_parameters.signal_extraction_para.additional_biomarker_names{2} = curr_str;
else
    set(handles.edit1_2_signals_sig3_biomarker, 'String', handles.curr_parameters.signal_extraction_para.additional_biomarker_names{2});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig3_biomarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig3_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig3_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig3_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig3_bias as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig3_bias as a double

handles.curr_parameters.signal_extraction_para.additional_bias_paths{2} = get(handles.edit1_2_signals_sig3_bias, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig3_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig3_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_2_signals_sig3_bias.
function pushbutton1_2_signals_sig3_bias_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig3_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('.mat', 'Select Bias for Signal 3');
if ~isequal(file, 0)
    handles.curr_parameters.signal_extraction_para.additional_bias_paths{2} = fullfile(path, file);
    set(handles.edit1_2_signals_sig3_bias, 'String', fullfile(path, file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_2_signals_sig3_bias_cancel.
function pushbutton1_2_signals_sig3_bias_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig3_bias_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_parameters.signal_extraction_para.additional_bias_paths{2} = '';
set(handles.edit1_2_signals_sig3_bias, 'String', []);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig3_cytoring_yes.
function radiobutton1_2_signals_sig3_cytoring_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig3_cytoring_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig3_cytoring_yes

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(2) = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig3_cytoring_no.
function radiobutton1_2_signals_sig3_cytoring_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig3_cytoring_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig3_cytoring_no

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(2) = 0;
guidata(hObject, handles);

end

function edit1_2_signals_sig4_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig4_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig4_signal as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig4_signal as a double

curr_str = get(handles.edit1_2_signals_sig4_signal, 'String');
if (~isempty(curr_str))
    handles.curr_parameters.signal_extraction_para.additional_signal_names{3} = curr_str;
else
    set(handles.edit1_2_signals_sig4_signal, 'String', handles.curr_parameters.signal_extraction_para.additional_signal_names{3});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig4_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig4_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig4_biomarker_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig4_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig4_biomarker as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig4_biomarker as a double

curr_str = get(handles.edit1_2_signals_sig4_biomarker, 'String');
if (~isempty(curr_str) && check_if_numberORletter(curr_str))
    if (~check_if_letter(curr_str(1))) % first letter is a not a letter
        curr_str = ['_', curr_str];
    end
    handles.curr_parameters.signal_extraction_para.additional_biomarker_names{3} = curr_str;
else
    set(handles.edit1_2_signals_sig4_biomarker, 'String', handles.curr_parameters.signal_extraction_para.additional_biomarker_names{3});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig4_biomarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig4_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig4_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig4_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig4_bias as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig4_bias as a double

handles.curr_parameters.signal_extraction_para.additional_bias_paths{3} = get(handles.edit1_2_signals_sig4_bias, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig4_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig4_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_2_signals_sig4_bias.
function pushbutton1_2_signals_sig4_bias_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig4_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('.mat', 'Select Bias for Signal 4');
if ~isequal(file, 0)
    handles.curr_parameters.signal_extraction_para.additional_bias_paths{3} = fullfile(path, file);
    set(handles.edit1_2_signals_sig4_bias, 'String', fullfile(path, file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_2_signals_sig4_bias_cancel.
function pushbutton1_2_signals_sig4_bias_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig4_bias_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_parameters.signal_extraction_para.additional_bias_paths{3} = '';
set(handles.edit1_2_signals_sig4_bias, 'String', []);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig4_cytoring_yes.
function radiobutton1_2_signals_sig4_cytoring_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig4_cytoring_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig4_cytoring_yes

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(3) = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig4_cytoring_no.
function radiobutton1_2_signals_sig4_cytoring_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig4_cytoring_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig4_cytoring_no

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(3) = 0;
guidata(hObject, handles);

end

function edit1_2_signals_sig5_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig5_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig5_signal as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig5_signal as a double

curr_str = get(handles.edit1_2_signals_sig5_signal, 'String');
if (~isempty(curr_str))
    handles.curr_parameters.signal_extraction_para.additional_signal_names{4} = curr_str;
else
    set(handles.edit1_2_signals_sig5_signal, 'String', handles.curr_parameters.signal_extraction_para.additional_signal_names{4});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig5_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig5_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig5_biomarker_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig5_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig5_biomarker as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig5_biomarker as a double

curr_str = get(handles.edit1_2_signals_sig5_biomarker, 'String');
if (~isempty(curr_str) && check_if_numberORletter(curr_str))
    if (~check_if_letter(curr_str(1))) % first letter is a not a letter
        curr_str = ['_', curr_str];
    end
    handles.curr_parameters.signal_extraction_para.additional_biomarker_names{4} = curr_str;
else
    set(handles.edit1_2_signals_sig5_biomarker, 'String', handles.curr_parameters.signal_extraction_para.additional_biomarker_names{4});
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig5_biomarker_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig5_biomarker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit1_2_signals_sig5_bias_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig5_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_2_signals_sig5_bias as text
%        str2double(get(hObject,'String')) returns contents of edit1_2_signals_sig5_bias as a double

handles.curr_parameters.signal_extraction_para.additional_bias_paths{4} = get(handles.edit1_2_signals_sig5_bias, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_2_signals_sig5_bias_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_2_signals_sig5_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_2_signals_sig5_bias.
function pushbutton1_2_signals_sig5_bias_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig5_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('.mat', 'Select Bias for Signal 5');
if ~isequal(file, 0)
    handles.curr_parameters.signal_extraction_para.additional_bias_paths{4} = fullfile(path, file);
    set(handles.edit1_2_signals_sig5_bias, 'String', fullfile(path, file));
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_2_signals_sig5_bias_cancel.
function pushbutton1_2_signals_sig5_bias_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_2_signals_sig5_bias_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.curr_parameters.signal_extraction_para.additional_bias_paths{4} = '';
set(handles.edit1_2_signals_sig5_bias, 'String', []);
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig5_cytoring_yes.
function radiobutton1_2_signals_sig5_cytoring_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig5_cytoring_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig5_cytoring_yes

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(4) = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_2_signals_sig5_cytoring_no.
function radiobutton1_2_signals_sig5_cytoring_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_2_signals_sig5_cytoring_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_2_signals_sig5_cytoring_no

handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(4) = 0;
guidata(hObject, handles);

end

%% General Information, Training Data and Output
function edit1_3_training_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_training as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_training as a double

end

% --- Executes during object creation, after setting all properties.
function edit1_3_training_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_training.
function pushbutton1_3_training_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path]=uigetfile('*.mat','Select Training Datasets','MultiSelect','on');
if ~isequal(file, 0)
    set(handles.edit1_3_training, 'String', [num2str(length(file)), ' Entries']);
    handles.curr_parameters.segmentation_para.seg_correction_para.training_data_path = fullfile(path, file);
    handles.curr_parameters.track_para.training_data_path = fullfile(path, file);
end
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton1_3_training_cancel.
function pushbutton1_3_training_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_training_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit1_3_training, 'String', '0 Entries');
handles.curr_parameters.segmentation_para.seg_correction_para.training_data_path = {};
handles.curr_parameters.track_para.training_data_path = {};
guidata(hObject, handles);

end

function edit1_3_out_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_out as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_out as a double

handles.curr_parameters.global_setting.output_path = get(handles.edit1_3_out, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_out_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_out.
function pushbutton1_3_out_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_path = uigetdir('.', 'Select Folder for Output');
if (~isequal(curr_path, 0)) % succeed
    set(handles.edit1_3_out, 'String', curr_path);
    handles.curr_parameters.global_setting.output_path = curr_path;
end
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_mask_output_yes.
function radiobutton1_3_out_mask_output_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_mask_output_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_mask_output_yes

handles.curr_parameters.segmentation_para.if_print_mask = 1;
set(handles.edit1_3_out_mask_path, 'Visible', 'on');
set(handles.pushbutton1_3_out_mask_path, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_mask_output_no.
function radiobutton1_3_out_mask_output_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_mask_output_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_mask_output_no

handles.curr_parameters.segmentation_para.if_print_mask = 0;
handles.curr_parameters.segmentation_para.mask_path = '';
set(handles.edit1_3_out_mask_path, 'Visible', 'off', 'String', []);
set(handles.pushbutton1_3_out_mask_path, 'Visible', 'off');
guidata(hObject, handles);

end

function edit1_3_out_mask_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_mask_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_out_mask_path as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_out_mask_path as a double

handles.curr_parameters.segmentation_para.mask_path = get(handles.edit1_3_out_mask_path, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_out_mask_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_mask_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_out_mask_path.
function pushbutton1_3_out_mask_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_out_mask_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_path = uigetdir('.', 'Select Folder for Mask');
if (~isequal(curr_path, 0)) % succeed
    set(handles.edit1_3_out_mask_path, 'String', curr_path);
    handles.curr_parameters.segmentation_para.mask_path = curr_path;
end
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_ellipse_output_yes.
function radiobutton1_3_out_ellipse_output_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_ellipse_output_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_ellipse_output_yes

handles.curr_parameters.segmentation_para.if_print_ellipse_movie = 1;
set(handles.edit1_3_out_ellipse_path, 'Visible', 'on');
set(handles.pushbutton1_3_out_ellipse_path, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_ellipse_output_no.
function radiobutton1_3_out_ellipse_output_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_ellipse_output_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_ellipse_output_no

handles.curr_parameters.segmentation_para.if_print_ellipse_movie = 0;
handles.curr_parameters.segmentation_para.ellipse_movie_path = '';
set(handles.edit1_3_out_ellipse_path, 'Visible', 'off', 'String', []);
set(handles.pushbutton1_3_out_ellipse_path, 'Visible', 'off');
guidata(hObject, handles);

end

function edit1_3_out_ellipse_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_ellipse_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_out_ellipse_path as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_out_ellipse_path as a double

handles.curr_parameters.segmentation_para.ellipse_movie_path = get(handles.edit1_3_out_ellipse_path, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_out_ellipse_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_ellipse_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_out_ellipse_path.
function pushbutton1_3_out_ellipse_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_out_ellipse_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_path = uigetdir('.', 'Select Folder for Ellipse Movie');
if (~isequal(curr_path, 0)) % succeed
    set(handles.edit1_3_out_ellipse_path, 'String', curr_path);
    handles.curr_parameters.segmentation_para.ellipse_movie_path = curr_path;
end
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_seginfo_output_yes.
function radiobutton1_3_out_seginfo_output_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_seginfo_output_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_seginfo_output_yes

handles.curr_parameters.segmentation_para.if_save_seg_info = 1;
set(handles.edit1_3_out_seginfo_path, 'Visible', 'on');
set(handles.pushbutton1_3_out_seginfo_path, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_seginfo_output_no.
function radiobutton1_3_out_seginfo_output_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_seginfo_output_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_seginfo_output_no

handles.curr_parameters.segmentation_para.if_save_seg_info = 0;
handles.curr_parameters.segmentation_para.seg_info_path = '';
set(handles.edit1_3_out_seginfo_path, 'Visible', 'off', 'String', []);
set(handles.pushbutton1_3_out_seginfo_path, 'Visible', 'off');
guidata(hObject, handles);

end

function edit1_3_out_seginfo_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_seginfo_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_out_seginfo_path as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_out_seginfo_path as a double

handles.curr_parameters.segmentation_para.seg_info_path = get(handles.edit1_3_out_seginfo_path, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_out_seginfo_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_seginfo_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_out_seginfo_path.
function pushbutton1_3_out_seginfo_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_out_seginfo_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_path = uigetdir('.', 'Select Folder of Segmentation Info');
if (~isequal(curr_path, 0)) % succeed
    set(handles.edit1_3_out_seginfo_path, 'String', curr_path);
    handles.curr_parameters.segmentation_para.seg_info_path = curr_path;
end
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_vistrack_output_yes.
function radiobutton1_3_out_vistrack_output_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_vistrack_output_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_vistrack_output_yes

handles.curr_parameters.track_para.if_print_vistrack = 1;
set(handles.edit1_3_out_vistrack_path, 'Visible', 'on');
set(handles.pushbutton1_3_out_vistrack_path, 'Visible', 'on');
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton1_3_out_vistrack_output_no.
function radiobutton1_3_out_vistrack_output_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1_3_out_vistrack_output_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1_3_out_vistrack_output_no

handles.curr_parameters.track_para.if_print_vistrack = 0;
handles.curr_parameters.track_para.vistrack_path = '';
set(handles.edit1_3_out_vistrack_path, 'Visible', 'off', 'String', []);
set(handles.pushbutton1_3_out_vistrack_path, 'Visible', 'off');
guidata(hObject, handles);

end

function edit1_3_out_vistrack_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_vistrack_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_3_out_vistrack_path as text
%        str2double(get(hObject,'String')) returns contents of edit1_3_out_vistrack_path as a double

handles.curr_parameters.track_para.vistrack_path = get(handles.edit1_3_out_vistrack_path, 'String');
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit1_3_out_vistrack_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_3_out_vistrack_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton1_3_out_vistrack_path.
function pushbutton1_3_out_vistrack_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_3_out_vistrack_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

curr_path = uigetdir('.', 'Select Folder for Vistrack');
if (~isequal(curr_path, 0)) % succeed
    set(handles.edit1_3_out_vistrack_path, 'String', curr_path);
    handles.curr_parameters.track_para.vistrack_path = curr_path;
end
guidata(hObject, handles);

end

%% Segmentation
% --- Executes on button press in radiobutton2_1_log_yes.
function radiobutton2_1_log_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_1_log_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_1_log_yes

handles.curr_parameters.segmentation_para.image_binarization_para.if_log = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_1_log_no.
function radiobutton2_1_log_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_1_log_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_1_log_no

handles.curr_parameters.segmentation_para.image_binarization_para.if_log = 0;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_1_method_blob.
function radiobutton2_1_method_blob_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_1_method_blob (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_1_method_blob

handles.curr_parameters.segmentation_para.image_binarization_para.if_blob_detection = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_1_method_threshold.
function radiobutton2_1_method_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_1_method_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_1_method_threshold

handles.curr_parameters.segmentation_para.image_binarization_para.if_blob_detection = 0;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_2_if_yes.
function radiobutton2_2_if_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_2_if_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_2_if_yes

handles.curr_parameters.segmentation_para.if_active_contour = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_2_if_no.
function radiobutton2_2_if_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_2_if_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_2_if_no

handles.curr_parameters.segmentation_para.if_active_contour = 0;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_2_log_yes.
function radiobutton2_2_log_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_2_log_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_2_log_yes

handles.curr_parameters.segmentation_para.active_contour_para.if_log = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_2_log_no.
function radiobutton2_2_log_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_2_log_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_2_log_no

handles.curr_parameters.segmentation_para.active_contour_para.if_log = 0;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_3_if_yes.
function radiobutton2_3_if_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_3_if_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_3_if_yes

handles.curr_parameters.segmentation_para.if_watershed = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_3_if_no.
function radiobutton2_3_if_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_3_if_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_3_if_no

handles.curr_parameters.segmentation_para.if_watershed = 0;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_5_if_yes.
function radiobutton2_5_if_yes_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_5_if_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_5_if_yes

handles.curr_parameters.segmentation_para.if_seg_correction = 1;
guidata(hObject, handles);

end

% --- Executes on button press in radiobutton2_5_if_no.
function radiobutton2_5_if_no_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2_5_if_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2_5_if_no

handles.curr_parameters.segmentation_para.if_seg_correction = 0;
guidata(hObject, handles);

end

%% Track Linking
function edit3_1_migration_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to edit3_1_migration_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3_1_migration_sigma as text
%        str2double(get(hObject,'String')) returns contents of edit3_1_migration_sigma as a double

curr_val = get(handles.edit3_1_migration_sigma, 'String');
if (strcmpi(curr_val, 'NaN'))
    handles.curr_parameters.track_para.migration_sigma = NaN;
else
    curr_val = str2double(curr_val);
    if (~isnan(curr_val) && curr_val > 0)
        handles.curr_parameters.track_para.migration_sigma = curr_val;
    else
        set(handles.edit3_1_migration_sigma, 'String', num2str(handles.curr_parameters.track_para.migration_sigma));
    end
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit3_1_migration_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3_1_migration_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function radiobutton3_1_if_similarity_yes_Callback(hObject, eventdata, handles)

handles.curr_parameters.track_para.if_similarity_for_migration = 1;
guidata(hObject, handles);

end

function radiobutton3_1_if_similarity_no_Callback(hObject, eventdata, handles)

handles.curr_parameters.track_para.if_similarity_for_migration = 0;
guidata(hObject, handles);

end

function edit3_2_minlength_Callback(hObject, eventdata, handles)
% hObject    handle to edit3_2_minlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3_2_minlength as text
%        str2double(get(hObject,'String')) returns contents of edit3_2_minlength as a double

curr_val = get(handles.edit3_2_minlength, 'String');
if (check_if_number(curr_val))
    curr_val = str2double(curr_val);
    handles.curr_parameters.track_para.min_track_length = curr_val;
else
    set(handles.edit3_2_minlength, 'String', num2str(handles.curr_parameters.track_para.min_track_length));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit3_2_minlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3_2_minlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


function edit3_2_maxskip_Callback(hObject, eventdata, handles)
% hObject    handle to edit3_2_maxskip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3_2_maxskip as text
%        str2double(get(hObject,'String')) returns contents of edit3_2_maxskip as a double

curr_val = get(handles.edit3_2_maxskip, 'String');
if (check_if_number(curr_val))
    curr_val = str2double(curr_val);
    handles.curr_parameters.track_para.max_num_frames_to_skip = curr_val;
else
    set(handles.edit3_2_maxskip, 'String', num2str(handles.curr_parameters.track_para.max_num_frames_to_skip));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit3_2_maxskip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3_2_maxskip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end


%% Signal Extraction
function edit4_1_ROI_nucleus_Callback(hObject, eventdata, handles)
% hObject    handle to edit4_1_ROI_nucleus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4_1_ROI_nucleus as text
%        str2double(get(hObject,'String')) returns contents of edit4_1_ROI_nucleus as a double

curr_val = get(handles.edit4_1_ROI_nucleus, 'String');
if (check_if_number(curr_val))
    handles.curr_parameters.signal_extraction_para.nuc_outer_size = str2double(curr_val);
else
    set(handles.edit4_1_ROI_nucleus, 'String', num2str(handles.curr_parameters.signal_extraction_para.nuc_outer_size));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit4_1_ROI_nucleus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4_1_ROI_nucleus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit4_1_ROI_cytoring_in_Callback(hObject, eventdata, handles)
% hObject    handle to edit4_1_ROI_cytoring_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4_1_ROI_cytoring_in as text
%        str2double(get(hObject,'String')) returns contents of edit4_1_ROI_cytoring_in as a double

curr_val = get(handles.edit4_1_ROI_cytoring_in, 'String');
if (check_if_number(curr_val))
    handles.curr_parameters.signal_extraction_para.cyto_ring_inner_size = str2double(curr_val);
else
    set(handles.edit4_1_ROI_cytoring_in, 'String', num2str(handles.curr_parameters.signal_extraction_para.cyto_ring_inner_size));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit4_1_ROI_cytoring_in_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4_1_ROI_cytoring_in (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit4_1_ROI_cytoring_out_Callback(hObject, eventdata, handles)
% hObject    handle to edit4_1_ROI_cytoring_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4_1_ROI_cytoring_out as text
%        str2double(get(hObject,'String')) returns contents of edit4_1_ROI_cytoring_out as a double

curr_val = get(handles.edit4_1_ROI_cytoring_out, 'String');
if (check_if_number(curr_val))
    handles.curr_parameters.signal_extraction_para.cyto_ring_outer_size = str2double(curr_val);
else
    set(handles.edit4_1_ROI_cytoring_out, 'String', num2str(handles.curr_parameters.signal_extraction_para.cyto_ring_outer_size));
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit4_1_ROI_cytoring_out_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4_1_ROI_cytoring_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function edit4_2_signal_Callback(hObject, eventdata, handles)
% hObject    handle to edit4_2_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4_2_signal as text
%        str2double(get(hObject,'String')) returns contents of edit4_2_signal as a double

curr_val = str2double(get(handles.edit4_2_signal, 'String'));
if (curr_val > 0 && curr_val < 100)
    handles.curr_parameters.signal_extraction_para.intensity_percentile = curr_val;
else
    set(handles.edit4_2_signal, 'String', num2str(handles.curr_parameters.signal_extraction_para.intensity_percentile));
end
guidata(hObject, handles);

end
% --- Executes during object creation, after setting all properties.
function edit4_2_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4_2_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

%% Utilities
function res = check_if_number(str)
    res = all(ismember(str, '0123456789'));
end

function res = check_if_letter(str)
    res = all(ismember(str, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'));
end

function res = check_if_numberORletter(str)
    res = all(ismember(str, '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'));
end

function handles = adjust_num_signal(handles, new_num_signal)
    % make names for each handle
    left_text = {'text1_2_signals_sig1', 'text1_2_signals_sig2', 'text1_2_signals_sig3', 'text1_2_signals_sig4', 'text1_2_signals_sig5'};
    signal_box = {'edit1_2_signals_sig1_signal', 'edit1_2_signals_sig2_signal', 'edit1_2_signals_sig3_signal', 'edit1_2_signals_sig4_signal', 'edit1_2_signals_sig5_signal'};
    biomarker_box = {'edit1_2_signals_sig1_biomarker', 'edit1_2_signals_sig2_biomarker', 'edit1_2_signals_sig3_biomarker', 'edit1_2_signals_sig4_biomarker', 'edit1_2_signals_sig5_biomarker'};
    bias_box = {'edit1_2_signals_sig1_bias', 'edit1_2_signals_sig2_bias', 'edit1_2_signals_sig3_bias', 'edit1_2_signals_sig4_bias', 'edit1_2_signals_sig5_bias'};
    bias_button = {'pushbutton1_2_signals_sig1_bias', 'pushbutton1_2_signals_sig2_bias', 'pushbutton1_2_signals_sig3_bias', 'pushbutton1_2_signals_sig4_bias', 'pushbutton1_2_signals_sig5_bias'};
    bias_button_cancel = {'pushbutton1_2_signals_sig1_bias_cancel', 'pushbutton1_2_signals_sig2_bias_cancel', 'pushbutton1_2_signals_sig3_bias_cancel', 'pushbutton1_2_signals_sig4_bias_cancel', 'pushbutton1_2_signals_sig5_bias_cancel'};
    cyto_panel = {'uibuttongroup1_2_signals_sig1_cytoring', 'uibuttongroup1_2_signals_sig2_cytoring', 'uibuttongroup1_2_signals_sig3_cytoring', 'uibuttongroup1_2_signals_sig4_cytoring', 'uibuttongroup1_2_signals_sig5_cytoring'};
    cyto_yes = {'radiobutton1_2_signals_sig1_cytoring_yes', 'radiobutton1_2_signals_sig2_cytoring_yes', 'radiobutton1_2_signals_sig3_cytoring_yes', 'radiobutton1_2_signals_sig4_cytoring_yes', 'radiobutton1_2_signals_sig5_cytoring_yes'};
    cyto_no = {'radiobutton1_2_signals_sig1_cytoring_no', 'radiobutton1_2_signals_sig2_cytoring_no', 'radiobutton1_2_signals_sig3_cytoring_no', 'radiobutton1_2_signals_sig4_cytoring_no', 'radiobutton1_2_signals_sig5_cytoring_no'};
    left_text = matlab.lang.makeValidName(left_text);
    signal_box = matlab.lang.makeValidName(signal_box);
    biomarker_box = matlab.lang.makeValidName(biomarker_box);
    bias_box = matlab.lang.makeValidName(bias_box);
    bias_button = matlab.lang.makeValidName(bias_button);
    bias_button_cancel = matlab.lang.makeValidName(bias_button_cancel);
    cyto_panel = matlab.lang.makeValidName(cyto_panel);
    cyto_yes = matlab.lang.makeValidName(cyto_yes);
    cyto_no = matlab.lang.makeValidName(cyto_no);
    
    % find old and new number of signals
    old_num_signal = handles.num_signal;
    handles.num_signal = new_num_signal;
    
    if (old_num_signal < new_num_signal) % need to add new entries
        % parameters
        handles.curr_parameters.signal_extraction_para.additional_signal_names{new_num_signal-1} = [];
        handles.curr_parameters.signal_extraction_para.additional_biomarker_names{new_num_signal-1} = [];
        handles.curr_parameters.signal_extraction_para.additional_raw_image_paths{new_num_signal-1} = []; 
        handles.curr_parameters.signal_extraction_para.additional_raw_image_paths(old_num_signal:end) = {handles.curr_parameters.global_setting.nuc_raw_image_path};
        handles.curr_parameters.signal_extraction_para.additional_bias_paths{new_num_signal-1} = [];
        handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(old_num_signal:new_num_signal-1) = 1;
        
        % enable entries
        for i=old_num_signal+1:new_num_signal
            set(handles.(left_text{i}), 'Visible', 'on');
            set(handles.(signal_box{i}), 'Visible', 'on');
            set(handles.(biomarker_box{i}), 'Visible', 'on');
            set(handles.(bias_box{i}), 'Visible', 'on');
            set(handles.(bias_button{i}), 'Visible', 'on');
            set(handles.(bias_button_cancel{i}), 'Visible', 'on');
            set(handles.(cyto_panel{i}), 'Visible', 'on');
            set(handles.(cyto_yes{i}), 'Visible', 'on', 'Value', 1);
            set(handles.(cyto_no{i}), 'Visible', 'on', 'Value', 0);
        end
    elseif (old_num_signal > new_num_signal) % need to remove entries
        % parameters
        handles.curr_parameters.signal_extraction_para.additional_signal_names = handles.curr_parameters.signal_extraction_para.additional_signal_names(1:new_num_signal-1);
        handles.curr_parameters.signal_extraction_para.additional_biomarker_names = handles.curr_parameters.signal_extraction_para.additional_biomarker_names(1:new_num_signal-1);
        handles.curr_parameters.signal_extraction_para.additional_raw_image_paths = handles.curr_parameters.signal_extraction_para.additional_raw_image_paths(1:new_num_signal-1); 
        handles.curr_parameters.signal_extraction_para.additional_bias_paths = handles.curr_parameters.signal_extraction_para.additional_bias_paths(1:new_num_signal-1);
        handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring = handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(1:new_num_signal-1);
        
        % disable entries
        for i=new_num_signal+1:old_num_signal
            set(handles.(left_text{i}), 'Visible', 'off');
            set(handles.(signal_box{i}), 'Visible', 'off', 'String', []);
            set(handles.(biomarker_box{i}), 'Visible', 'off', 'String', []);
            set(handles.(bias_box{i}), 'Visible', 'off', 'String', []);
            set(handles.(bias_button{i}), 'Visible', 'off');
            set(handles.(bias_button_cancel{i}), 'Visible', 'off');
            set(handles.(cyto_panel{i}), 'Visible', 'off');
            set(handles.(cyto_yes{i}), 'Visible', 'off', 'Value', 1);
            set(handles.(cyto_no{i}), 'Visible', 'off', 'Value', 0);
        end
    end

end

function handles = initialize_num_signal(handles, num_signal, read_para)
    % make names for each handle
    signal_radio = {'radiobutton1_2_numsignals_1', 'radiobutton1_2_numsignals_2', 'radiobutton1_2_numsignals_3', 'radiobutton1_2_numsignals_4', 'radiobutton1_2_numsignals_5'};
    left_text = {'text1_2_signals_sig1', 'text1_2_signals_sig2', 'text1_2_signals_sig3', 'text1_2_signals_sig4', 'text1_2_signals_sig5'};
    signal_box = {'edit1_2_signals_sig1_signal', 'edit1_2_signals_sig2_signal', 'edit1_2_signals_sig3_signal', 'edit1_2_signals_sig4_signal', 'edit1_2_signals_sig5_signal'};
    biomarker_box = {'edit1_2_signals_sig1_biomarker', 'edit1_2_signals_sig2_biomarker', 'edit1_2_signals_sig3_biomarker', 'edit1_2_signals_sig4_biomarker', 'edit1_2_signals_sig5_biomarker'};
    bias_box = {'edit1_2_signals_sig1_bias', 'edit1_2_signals_sig2_bias', 'edit1_2_signals_sig3_bias', 'edit1_2_signals_sig4_bias', 'edit1_2_signals_sig5_bias'};
    bias_button = {'pushbutton1_2_signals_sig1_bias', 'pushbutton1_2_signals_sig2_bias', 'pushbutton1_2_signals_sig3_bias', 'pushbutton1_2_signals_sig4_bias', 'pushbutton1_2_signals_sig5_bias'};
    bias_button_cancel = {'pushbutton1_2_signals_sig1_bias_cancel', 'pushbutton1_2_signals_sig2_bias_cancel', 'pushbutton1_2_signals_sig3_bias_cancel', 'pushbutton1_2_signals_sig4_bias_cancel', 'pushbutton1_2_signals_sig5_bias_cancel'};
    cyto_panel = {'uibuttongroup1_2_signals_sig1_cytoring', 'uibuttongroup1_2_signals_sig2_cytoring', 'uibuttongroup1_2_signals_sig3_cytoring', 'uibuttongroup1_2_signals_sig4_cytoring', 'uibuttongroup1_2_signals_sig5_cytoring'};
    cyto_yes = {'radiobutton1_2_signals_sig1_cytoring_yes', 'radiobutton1_2_signals_sig2_cytoring_yes', 'radiobutton1_2_signals_sig3_cytoring_yes', 'radiobutton1_2_signals_sig4_cytoring_yes', 'radiobutton1_2_signals_sig5_cytoring_yes'};
    cyto_no = {'radiobutton1_2_signals_sig1_cytoring_no', 'radiobutton1_2_signals_sig2_cytoring_no', 'radiobutton1_2_signals_sig3_cytoring_no', 'radiobutton1_2_signals_sig4_cytoring_no', 'radiobutton1_2_signals_sig5_cytoring_no'};
    signal_radio = matlab.lang.makeValidName(signal_radio);
    left_text = matlab.lang.makeValidName(left_text);
    signal_box = matlab.lang.makeValidName(signal_box);
    biomarker_box = matlab.lang.makeValidName(biomarker_box);
    bias_box = matlab.lang.makeValidName(bias_box);
    bias_button = matlab.lang.makeValidName(bias_button);
    bias_button_cancel = matlab.lang.makeValidName(bias_button_cancel);
    cyto_panel = matlab.lang.makeValidName(cyto_panel);
    cyto_yes = matlab.lang.makeValidName(cyto_yes);
    cyto_no = matlab.lang.makeValidName(cyto_no);
    
    % radio button
    for i=1:length(signal_radio)
        set(handles.(signal_radio{i}), 'Visible', 'on', 'Value', num_signal == i);
    end
    
    % put nucleus signal
    set(handles.(left_text{1}), 'Visible', 'on');
    set(handles.(signal_box{1}), 'Visible', 'on', 'String', read_para.global_setting.nuc_signal_name);
    set(handles.(biomarker_box{1}), 'Visible', 'on', 'String', read_para.global_setting.nuc_biomarker_name);
    set(handles.(bias_box{1}), 'Visible', 'on', 'String', read_para.global_setting.nuc_bias_path);
    set(handles.(bias_button{1}), 'Visible', 'on');
    set(handles.(bias_button_cancel{1}), 'Visible', 'on');
    set(handles.(cyto_panel{1}), 'Visible', 'on');
    set(handles.(cyto_yes{1}), 'Visible', 'on', 'Value', 0, 'Enable', 'off');
    set(handles.(cyto_no{1}), 'Visible', 'on', 'Value', 1, 'Enable', 'off');
    
    % put other signals
    for i=2:num_signal
        set(handles.(left_text{i}), 'Visible', 'on');
        set(handles.(signal_box{i}), 'Visible', 'on', 'String', read_para.signal_extraction_para.additional_signal_names{i-1});
        set(handles.(biomarker_box{i}), 'Visible', 'on', 'String', read_para.signal_extraction_para.additional_biomarker_names{i-1});
        set(handles.(bias_box{i}), 'Visible', 'on', 'String', read_para.signal_extraction_para.additional_bias_paths{i-1});
        set(handles.(bias_button{i}), 'Visible', 'on');
        set(handles.(bias_button_cancel{i}), 'Visible', 'on');
        set(handles.(cyto_panel{i}), 'Visible', 'on');
        set(handles.(cyto_yes{i}), 'Visible', 'on', 'Value', read_para.signal_extraction_para.if_compute_cyto_ring(i-1) == 1);
        set(handles.(cyto_no{i}), 'Visible', 'on', 'Value', read_para.signal_extraction_para.if_compute_cyto_ring(i-1) ~= 1);
    end
    
    % disable abundant signals
    for i=num_signal+1:length(left_text)
        set(handles.(left_text{i}), 'Visible', 'off');
        set(handles.(signal_box{i}), 'Visible', 'off', 'String', []);
        set(handles.(biomarker_box{i}), 'Visible', 'off', 'String', []);
        set(handles.(bias_box{i}), 'Visible', 'off', 'String', []);
        set(handles.(bias_button{i}), 'Visible', 'off');
        set(handles.(bias_button_cancel{i}), 'Visible', 'off');
        set(handles.(cyto_panel{i}), 'Visible', 'off');
        set(handles.(cyto_yes{i}), 'Visible', 'off', 'Value', 1);
        set(handles.(cyto_no{i}), 'Visible', 'off', 'Value', 0);
    end
end

function handles = update_entries(handles, read_para)

% change parameters stored in handles
handles.if_tif = isempty(read_para.global_setting.nd2_frame_range);
handles.num_signal = 1 + length(read_para.signal_extraction_para.additional_signal_names);

if (size(read_para.global_setting.valid_wells, 1) ~= ...
        length(unique(read_para.global_setting.valid_wells(:,1))) * ...
        length(unique(read_para.global_setting.valid_wells(:,2))) * ...
        length(unique(read_para.global_setting.valid_wells(:,3)))) % not consecutive movies
    warndlg('GUI assumes that all selected wells should locate consecutively on the plate. However, loaded parameter values do not satisfy this assumption. Please modify global_setting.valid_wells manually.' );
end
handles.row_from = min(read_para.global_setting.valid_wells(:,1));
handles.row_to = max(read_para.global_setting.valid_wells(:,1));
handles.col_from = min(read_para.global_setting.valid_wells(:,2));
handles.col_to = max(read_para.global_setting.valid_wells(:,2));
handles.site_from = min(read_para.global_setting.valid_wells(:,3));
handles.site_to = max(read_para.global_setting.valid_wells(:,3));

if any(diff(read_para.global_setting.all_frames) ~= 1)
    warndlg('GUI assumes that selected frames should be consecutive. However, loaded parameter values do not satisfy this assumption. Please modify global_setting.all_frames manually.' );
end
handles.frame_from = min(read_para.global_setting.all_frames);
handles.frame_to = max(read_para.global_setting.all_frames);

% change entries of the panels
% General Information, Movie Definition
if (handles.if_tif)
    set(handles.radiobutton1_3_filetype_tif, 'Value', 1); set(handles.radiobutton1_3_filetype_nd2, 'Value', 0);
else
    set(handles.radiobutton1_3_filetype_tif, 'Value', 0); set(handles.radiobutton1_3_filetype_nd2, 'Value', 1);
end

if_all_path_equal = 1;
for i=1:handles.num_signal-1
    if ~isequal(read_para.global_setting.nuc_raw_image_path, read_para.signal_extraction_para.additional_raw_image_paths{i})
        if_all_path_equal = 0; break;
    end
end
if ~if_all_path_equal
    warndlg('GUI assumes that all images should locate in the same folder. However, loaded parameter values do not satisfy this assumption. GUI will use the folder for the nuclear channel for all relevant entries. Please modify signal_extraction_para.additional_raw_image_paths manually.');
    for i=1:handles.num_signal-1
        read_para.signal_extraction_para.additional_raw_image_paths{i} = read_para.global_setting.nuc_raw_image_path;
    end
end
if (handles.if_tif)
    set(handles.edit1_3_imagepath, 'String', read_para.global_setting.nuc_raw_image_path, 'Enable', 'on');
else
    set(handles.edit1_3_imagepath, 'String', [num2str(length(read_para.global_setting.nuc_raw_image_path)), ' Entries'], 'Enable', 'off');
end

set(handles.edit1_3_wells_rowsfrom, 'String', num2str(handles.row_from));
set(handles.edit1_3_wells_rowsto, 'String', num2str(handles.row_to));
set(handles.edit1_3_wells_colsfrom, 'String', num2str(handles.col_from));
set(handles.edit1_3_wells_colsto, 'String', num2str(handles.col_to));
set(handles.edit1_3_wells_sitesfrom, 'String', num2str(handles.site_from));
set(handles.edit1_3_wells_sitesto, 'String', num2str(handles.site_to));
set(handles.edit1_3_frames_from, 'String', num2str(handles.frame_from));
set(handles.edit1_3_frames_to, 'String', num2str(handles.frame_to));

set(handles.edit1_3_cmos, 'String', read_para.global_setting.cmosoffset_path);

set(handles.radiobutton1_3_jitter_yes, 'Value', read_para.global_setting.if_global_correction == 1);
set(handles.radiobutton1_3_jitter_no, 'Value', read_para.global_setting.if_global_correction == 0);

% General Information, Cell Definition
set(handles.edit1_2_nucradius, 'String', num2str(read_para.segmentation_para.nuc_radius));

handles = initialize_num_signal(handles, handles.num_signal, read_para);

% General Information, Training Data and Output
if ~isequal(read_para.track_para.training_data_path, read_para.segmentation_para.seg_correction_para.training_data_path)
    warndlg('GUI assumes that the training datasets for correcting segmentation mistakes and for track linking should be the same. However, loaded parameters do not satisfy this assumption. GUI will use the datasets for track linking instead. Please modify segmentation_para.seg_correction_para.training_data_path manually.');
    read_para.segmentation_para.seg_correction_para.training_data_path = read_para.track_para.training_data_path;
end
set(handles.edit1_3_training, 'Enable', 'off', 'String', [num2str(length(read_para.track_para.training_data_path)), ' Entries']);

set(handles.edit1_3_out, 'String', read_para.global_setting.output_path);

set(handles.radiobutton1_3_out_mask_output_yes, 'Value', read_para.segmentation_para.if_print_mask == 1);
set(handles.radiobutton1_3_out_mask_output_no, 'Value', read_para.segmentation_para.if_print_mask == 0);
if read_para.segmentation_para.if_print_mask
    set(handles.edit1_3_out_mask_path, 'String', read_para.segmentation_para.mask_path, 'Visible', 'on');
    set(handles.pushbutton1_3_out_mask_path, 'Visible', 'on');
else
    set(handles.edit1_3_out_mask_path, 'String', [], 'Visible', 'off');
    set(handles.pushbutton1_3_out_mask_path, 'Visible', 'off');
    read_para.segmentation_para.mask_path = '';
end

set(handles.radiobutton1_3_out_ellipse_output_yes, 'Value', read_para.segmentation_para.if_print_ellipse_movie == 1);
set(handles.radiobutton1_3_out_ellipse_output_no, 'Value', read_para.segmentation_para.if_print_ellipse_movie == 0);
if read_para.segmentation_para.if_print_ellipse_movie
    set(handles.edit1_3_out_ellipse_path, 'String', read_para.segmentation_para.ellipse_movie_path, 'Visible', 'on');
    set(handles.pushbutton1_3_out_ellipse_path, 'Visible', 'on');
else
    set(handles.edit1_3_out_ellipse_path, 'String', [], 'Visible', 'off');
    set(handles.pushbutton1_3_out_ellipse_path, 'Visible', 'off');
    read_para.segmentation_para.ellipse_movie_path = '';
end

set(handles.radiobutton1_3_out_seginfo_output_yes, 'Value', read_para.segmentation_para.if_save_seg_info == 1);
set(handles.radiobutton1_3_out_seginfo_output_no, 'Value', read_para.segmentation_para.if_save_seg_info == 0);
if read_para.segmentation_para.if_save_seg_info
    set(handles.edit1_3_out_seginfo_path, 'String', read_para.segmentation_para.seg_info_path, 'Visible', 'on');
    set(handles.pushbutton1_3_out_seginfo_path, 'Visible', 'on');
else
    set(handles.edit1_3_out_seginfo_path, 'String', [], 'Visible', 'off');
    set(handles.pushbutton1_3_out_seginfo_path, 'Visible', 'off');
    read_para.segmentation_para.seg_info_path = '';
end

set(handles.radiobutton1_3_out_vistrack_output_yes, 'Value', read_para.track_para.if_print_vistrack == 1);
set(handles.radiobutton1_3_out_vistrack_output_no, 'Value', read_para.track_para.if_print_vistrack == 0);
if read_para.track_para.if_print_vistrack
    set(handles.edit1_3_out_vistrack_path, 'String', read_para.track_para.vistrack_path, 'Visible', 'on');
    set(handles.pushbutton1_3_out_vistrack_path, 'Visible', 'on');
else
    set(handles.edit1_3_out_vistrack_path, 'String', [], 'Visible', 'off');
    set(handles.pushbutton1_3_out_vistrack_path, 'Visible', 'off');
    read_para.track_para.vistrack_path = '';
end

% Segmentation
set(handles.radiobutton2_1_log_yes, 'Value', read_para.segmentation_para.image_binarization_para.if_log == 1);
set(handles.radiobutton2_1_log_no, 'Value', read_para.segmentation_para.image_binarization_para.if_log == 0);

set(handles.radiobutton2_1_method_blob, 'Value', read_para.segmentation_para.image_binarization_para.if_blob_detection == 1);
set(handles.radiobutton2_1_method_threshold, 'Value', read_para.segmentation_para.image_binarization_para.if_blob_detection == 0);

set(handles.radiobutton2_2_if_yes, 'Value', read_para.segmentation_para.if_active_contour == 1);
set(handles.radiobutton2_2_if_no, 'Value', read_para.segmentation_para.if_active_contour == 0);

set(handles.radiobutton2_2_log_yes, 'Value', read_para.segmentation_para.active_contour_para.if_log == 1);
set(handles.radiobutton2_2_log_no, 'Value', read_para.segmentation_para.active_contour_para.if_log == 0);

set(handles.radiobutton2_3_if_yes, 'Value', read_para.segmentation_para.if_watershed == 1);
set(handles.radiobutton2_3_if_no, 'Value', read_para.segmentation_para.if_watershed == 0);

set(handles.radiobutton2_5_if_yes, 'Value', read_para.segmentation_para.if_seg_correction == 1);
set(handles.radiobutton2_5_if_no, 'Value', read_para.segmentation_para.if_seg_correction == 0);

% Track Linking
set(handles.edit3_1_migration_sigma, 'String', num2str(read_para.track_para.migration_sigma));
set(handles.radiobutton3_1_if_similarity_yes, 'Value', read_para.track_para.if_similarity_for_migration == 1); 
set(handles.radiobutton3_1_if_similarity_no, 'Value', read_para.track_para.if_similarity_for_migration == 0);

set(handles.edit3_2_minlength, 'String', num2str(read_para.track_para.min_track_length));
set(handles.edit3_2_maxskip, 'String', num2str(read_para.track_para.max_num_frames_to_skip));

% Signal Extraction
set(handles.edit4_1_ROI_nucleus, 'String', num2str(read_para.signal_extraction_para.nuc_outer_size));
set(handles.edit4_1_ROI_cytoring_in, 'String', num2str(read_para.signal_extraction_para.cyto_ring_inner_size));
set(handles.edit4_1_ROI_cytoring_out, 'String', num2str(read_para.signal_extraction_para.cyto_ring_outer_size));
set(handles.edit4_2_signal, 'String', num2str(read_para.signal_extraction_para.intensity_percentile));

handles.curr_parameters = read_para; handles.old_parameters = read_para;

end

function write_para_file( handles )

% fill in other entries
handles.curr_parameters.valid_wells = combvec( handles.row_from:handles.row_to, handles.col_from:handles.col_to, handles.site_from:handles.site_to)';
handles.curr_parameters.all_frames = handles.frame_from:handles.frame_to;

if handles.if_tif
    handles.curr_parameters.global_setting.nd2_frame_range = [];
else % read sample files to find the nd2_frame_range
    h = msgbox('Computing nd2_frame_range. Please wait.');
    try
        % find the right path to ND2 file
        num_files = length(handles.curr_parameters.global_setting.nuc_raw_image_path);
        handles.curr_parameters.global_setting.nd2_frame_range = nan(num_files, 2);
        for file_id=1:num_files
            all_files = dir(handles.curr_parameters.global_setting.nuc_raw_image_path{file_id});
            leading_filename = ['Well', char(handles.row_from-1+'A'), sprintf('%02d', handles.col_from)];
            recorded_file_id = [];
            for i=1:length(all_files)
                if (length(all_files(i).name) <= length(leading_filename))
                    continue;
                end
                if (strcmp(all_files(i).name(1:length(leading_filename)), leading_filename))
                    recorded_file_id = i;
                break;
                end
            end
            if (isempty(recorded_file_id))
                error('ND2 file is not found. ');
            end
            bfReader = BioformatsImage(fullfile(handles.curr_parameters.global_setting.nuc_raw_image_path{file_id}, all_files(recorded_file_id).name));
            if (file_id == 1)
                handles.curr_parameters.global_setting.nd2_frame_range(1, :) = [1, bfReader.sizeT];
            else
                handles.curr_parameters.global_setting.nd2_frame_range(file_id, :) = handles.curr_parameters.global_setting.nd2_frame_range(file_id-1, 2) + [1, bfReader.sizeT];
            end
        end
    catch
        warndlg('Calculation of nd2_frame_range is not successful. Please set global_setting.nd2_frame_range manually.');
    end
    close(h);
end

% generate m file
generate_m_file(handles);

end

%% Generate parameters.m based on handles
function generate_m_file( handles )
% open a file
fileID = fopen('parameters.m', 'wt');

% intro
fprintf(fileID, "function [ all_parameters ] = parameters()\n");
fprintf(fileID, "%%PARAMETERS Definition of all the parameters used in the program\n");
fprintf(fileID, "%%\n");
fprintf(fileID, "%%   Input: empty\n");
fprintf(fileID, "%%   Output:\n");
fprintf(fileID, "%%       all_parameters: all the parameters, organized in a struct variable\n");
fprintf(fileID, "%%\n\n");

% global setting
fprintf(fileID, "%%%% GLOBAL_SETTING\n");
fprintf(fileID, "%% Parameters used by all tracker modules.\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] nuc_raw_image_path: Path to the folder with all the captured\n");
fprintf(fileID, "%% images of the nuclear channel (TIFF or ND2 formats).\n");
fprintf(fileID, "%% [Essential] nd2_frame_range: Range of frames each ND2 file stores. If the\n");
fprintf(fileID, "%% captured images are stored in the TIFF format, this variable should be\n");
fprintf(fileID, "%% empty.\n");
fprintf(fileID, "nuc_raw_image_path = ");
if (handles.if_tif)
    fprintf(fileID, "'%s';\n", handles.curr_parameters.global_setting.nuc_raw_image_path);
else
    fprintf(fileID, "{");
    num_entry = length(handles.curr_parameters.global_setting.nuc_raw_image_path);
    for i=1:num_entry-1
        fprintf(fileID, "'%s';\n    ", handles.curr_parameters.global_setting.nuc_raw_image_path{i});
    end
    fprintf(fileID, "'%s'};\n", handles.curr_parameters.global_setting.nuc_raw_image_path{num_entry});
end
if (isempty(handles.curr_parameters.global_setting.nd2_frame_range))
    fprintf(fileID, "nd2_frame_range = [];\n");
else
    num_entry = size(handles.curr_parameters.global_setting.nd2_frame_range, 1);
    fprintf(fileID, "nd2_frame_range = [");
    for i=1:num_entry-1
        fprintf(fileID, "%g, %g;\n    ", handles.curr_parameters.global_setting.nd2_frame_range(i,1), handles.curr_parameters.global_setting.nd2_frame_range(i,2));
    end
    fprintf(fileID, "%g, %g];\n", handles.curr_parameters.global_setting.nd2_frame_range(num_entry,1), handles.curr_parameters.global_setting.nd2_frame_range(num_entry,2));
end
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS BELOW\n");
fprintf(fileID, "if (ischar(nuc_raw_image_path))\n");
fprintf(fileID, "    nuc_raw_image_path = adjust_path(nuc_raw_image_path);\n");
fprintf(fileID, "else\n");
fprintf(fileID, "    for i=1:length(nuc_raw_image_path)\n");
fprintf(fileID, "        nuc_raw_image_path{i} = adjust_path(nuc_raw_image_path{i});\n");
fprintf(fileID, "    end\n");
fprintf(fileID, "end\n");
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS ABOVE\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] valid_wells: Movies being tracked.\n");
fprintf(fileID, "valid_wells = allcomb(%g:%g, %g:%g, %g:%g);\n", handles.row_from, handles.row_to, handles.col_from, handles.col_to, handles.site_from, handles.site_to);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] cmosoffset_path: Path to the .mat file storing the camera\n");
fprintf(fileID, "%% dark noises (CMOS Offset).\n");
fprintf(fileID, "cmosoffset_path = '%s';\n", handles.curr_parameters.global_setting.cmosoffset_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] nuc_bias_path: Path to the .mat file storing the illumination\n");
fprintf(fileID, "%% bias (Bias) of the nuclear channel.\n");
fprintf(fileID, "nuc_bias_path = '%s';\n", handles.curr_parameters.global_setting.nuc_bias_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] all_frames: Frames to track.\n");
fprintf(fileID, "all_frames = %g:%g;\n", handles.frame_from, handles.frame_to);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] nuc_signal_name: Name of the nuclear channel.\n");
fprintf(fileID, "nuc_signal_name = '%s';\n", handles.curr_parameters.global_setting.nuc_signal_name);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] nuc_biomarker_name: Name of the measured nuclear marker.\n");
fprintf(fileID, "nuc_biomarker_name = '%s';\n", handles.curr_parameters.global_setting.nuc_biomarker_name);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] if_global_correction: Whether to perform global jitter\n");
fprintf(fileID, "%% correction.\n");
fprintf(fileID, "if_global_correction = %g;\n", handles.curr_parameters.global_setting.if_global_correction);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] output_path: Path to the folder storing the output of the\n");
fprintf(fileID, "%% tracker.\n");
fprintf(fileID, "output_path = '%s';\n", handles.curr_parameters.global_setting.output_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable\n");
fprintf(fileID, "global_setting = struct('nuc_raw_image_path', {nuc_raw_image_path}, 'nd2_frame_range', {nd2_frame_range}, 'valid_wells', {valid_wells}, ...\n");
fprintf(fileID, "    'cmosoffset_path', adjust_path(cmosoffset_path), 'nuc_bias_path', adjust_path(nuc_bias_path), 'all_frames', all_frames, ...\n");
fprintf(fileID, "    'nuc_signal_name', nuc_signal_name, 'nuc_biomarker_name', nuc_biomarker_name, ...\n");
fprintf(fileID, "    'if_global_correction', if_global_correction, 'output_path', adjust_path(output_path));\n\n");

% segmentation
fprintf(fileID, "%%%% SEGMENTATION_PARA\n");
fprintf(fileID, "%% Parameters used by Segmentation\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 1. Non-Specific Parameters\n");
fprintf(fileID, "%% [Optional] if_active_contour: Whether to perform the Active Contour step.\n");
fprintf(fileID, "if_active_contour = %g;\n", handles.curr_parameters.segmentation_para.if_active_contour);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] if_watershed: Whether to perform the Watershed step.\n");
fprintf(fileID, "if_watershed = %g;\n", handles.curr_parameters.segmentation_para.if_watershed);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] if_seg_correction: Whether to use training data to correct\n");
fprintf(fileID, "%% mistakes of segmentation.\n");
fprintf(fileID, "if_seg_correction = %g;\n", handles.curr_parameters.segmentation_para.if_seg_correction);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential]: if_print_mask: Whether to output the mask before ellipse\n");
fprintf(fileID, "%% fitting. 1 indicates outputting and 0 indicates not.\n");
fprintf(fileID, "%% [Essential]: mask_path: Path to the folder storing the mask.\n");
fprintf(fileID, "if_print_mask = %g;\n", handles.curr_parameters.segmentation_para.if_print_mask);
fprintf(fileID, "mask_path = '%s';\n", handles.curr_parameters.segmentation_para.mask_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_print_ellipse_movie: Whether to visualize the ellipse\n");
fprintf(fileID, "%% fitting results by 'ellipse movie' where the fitted ellipses are overlaid\n");
fprintf(fileID, "%% on the nuclear images. 1 indicates visualizing and 0 indicates not.\n");
fprintf(fileID, "%% [Essential] ellipse_movie_path: Path to the folder storing ?ellipse\n");
fprintf(fileID, "%% movie?.\n");
fprintf(fileID, "if_print_ellipse_movie = %g;\n", handles.curr_parameters.segmentation_para.if_print_ellipse_movie);
fprintf(fileID, "ellipse_movie_path = '%s';\n", handles.curr_parameters.segmentation_para.ellipse_movie_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_save_seg_info: Whether to save the ellipse fitting results\n");
fprintf(fileID, "%% of every frame ('seg info').\n");
fprintf(fileID, "%% [Essential] seg_info_path: Path to the folder storing ?seg info?.\n");
fprintf(fileID, "if_save_seg_info = %g;\n", handles.curr_parameters.segmentation_para.if_save_seg_info);
fprintf(fileID, "seg_info_path = '%s';\n", handles.curr_parameters.segmentation_para.seg_info_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] nuc_radius: Blob detection only. The average radius (in\n");
fprintf(fileID, "%% pixels) of a nucleus.\n");
fprintf(fileID, "nuc_radius = %g;\n", handles.curr_parameters.segmentation_para.nuc_radius);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_hole_size_for_fill: The maximal area (in pixels) of a hole\n");
fprintf(fileID, "%% within a component to fill.\n");
fprintf(fileID, "max_hole_size_for_fill = %g;\n", handles.curr_parameters.segmentation_para.max_hole_size_for_fill);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_component_size_for_nucleus: Used in both methods. The\n");
fprintf(fileID, "%% minimal area (in pixels) of a component to be considered as a nucleus.\n");
fprintf(fileID, "%% Any component with a smaller area will be removed.\n");
fprintf(fileID, "min_component_size_for_nucleus = %g;\n", handles.curr_parameters.segmentation_para.min_component_size_for_nucleus);
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 2. Image Binarization\n");
fprintf(fileID, "%% [Optional] blurradius: Used in both methods. Radius (in pixels) of disk\n");
fprintf(fileID, "%% for image smoothing.\n");
fprintf(fileID, "blurradius = %g; \n", handles.curr_parameters.segmentation_para.image_binarization_para.blurradius);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_log: Used in both methods. Whether to perform\n");
fprintf(fileID, "%% log-transform to the image.\n");
fprintf(fileID, "if_log = %g;\n", handles.curr_parameters.segmentation_para.image_binarization_para.if_log);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_blob_detection: Used in both methods. Whether to perform\n");
fprintf(fileID, "%% blob detection or not.\n");
fprintf(fileID, "if_blob_detection = %g;\n", handles.curr_parameters.segmentation_para.image_binarization_para.if_blob_detection);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Important] blob_threshold: Blob detection only. Threshold of hessian.\n");
fprintf(fileID, "%% Should be a negative number.\n");
fprintf(fileID, "blob_threshold = %g;\n", handles.curr_parameters.segmentation_para.image_binarization_para.blob_threshold);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable \n");
fprintf(fileID, "image_binarization_para = struct('blurradius', blurradius, 'if_log', if_log, ...\n");
fprintf(fileID, "    'if_blob_detection', if_blob_detection, 'blob_threshold', blob_threshold);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 3. Active Contour\n");
fprintf(fileID, "%% [Optional] blurradius: Radius (in pixels) of disk for mask smoothing.\n");
fprintf(fileID, "blurradius = %g;\n", handles.curr_parameters.segmentation_para.active_contour_para.blurradius);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_log: Whether to perform log-transform to the image.\n");
fprintf(fileID, "if_log = %g;\n", handles.curr_parameters.segmentation_para.active_contour_para.if_log);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_global: Whether to apply the global option of active\n");
fprintf(fileID, "%% contour algorithm or not.\n");
fprintf(fileID, "if_global = %g;\n", handles.curr_parameters.segmentation_para.active_contour_para.if_global);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable\n");
fprintf(fileID, "active_contour_para = struct('blurradius', blurradius, 'if_log', if_log, 'if_global', if_global);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 4. Watershed\n");
fprintf(fileID, "%% [Optional] max_thresh_component_size: The maximal area (in pixels) of an\n");
fprintf(fileID, "%% eroded component to be added to the refined mask.\n");
fprintf(fileID, "%% [Optional] min_thresh_component_size: The minimal area (in pixels) of an\n");
fprintf(fileID, "%% eroded component to be added to the refined mask.\n");
fprintf(fileID, "max_thresh_component_size = %g;\n", handles.curr_parameters.segmentation_para.watershed_para.max_thresh_component_size);
fprintf(fileID, "min_thresh_component_size = %g;\n", handles.curr_parameters.segmentation_para.watershed_para.min_thresh_component_size);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable\n");
fprintf(fileID, "watershed_para = struct('max_thresh_component_size', max_thresh_component_size, ...\n");
fprintf(fileID, "    'min_thresh_component_size', min_thresh_component_size);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 5. Ellipse Fitting\n");
fprintf(fileID, "%% [Optional] k, thd1, thd2, thdn, C, T_angle, sig, Endpoint, Gap_size:\n");
fprintf(fileID, "%% Parameters in Zafari et al 2015.\n");
fprintf(fileID, "k = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.k);
fprintf(fileID, "thd1 = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.thd1);
fprintf(fileID, "thd2 = %g;\n", handles.curr_parameters.segmentation_para.ellipse_para.thd2);
fprintf(fileID, "thdn = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.thdn);
fprintf(fileID, "C = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.C);
fprintf(fileID, "T_angle = %g;\n", handles.curr_parameters.segmentation_para.ellipse_para.T_angle);
fprintf(fileID, "sig = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.sig);
fprintf(fileID, "Endpoint = %g;\n", handles.curr_parameters.segmentation_para.ellipse_para.Endpoint);
fprintf(fileID, "Gap_size = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.Gap_size);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_ellipse_perimeter: Minimal perimeter (in pixels) of an\n");
fprintf(fileID, "%% ellipse\n");
fprintf(fileID, "min_ellipse_perimeter = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.min_ellipse_perimeter);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_ellipse_area: Minimal area (in pixels) of an ellipse.\n");
fprintf(fileID, "min_ellipse_area = %g; \n", handles.curr_parameters.segmentation_para.ellipse_para.min_ellipse_area);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_major_axis: Maximal major axis (in pixels) of an ellipse.\n");
fprintf(fileID, "max_major_axis = %g;\n", handles.curr_parameters.segmentation_para.ellipse_para.max_major_axis);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable\n");
fprintf(fileID, "ellipse_para = struct('k', k, 'thd1', thd1, 'thd2', thd2, 'thdn', thdn, 'C', C, 'T_angle', T_angle, ...\n");
fprintf(fileID, "    'sig', sig, 'Endpoint', Endpoint, 'Gap_size', Gap_size, 'min_ellipse_perimeter', min_ellipse_perimeter, ...\n");
fprintf(fileID, "    'min_ellipse_area', min_ellipse_area, 'max_major_axis', max_major_axis);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Part 6. Correction of Segmentation Mistakes\n");
fprintf(fileID, "%% [Essential] training_data_path: Paths to the training data.\n");
if (isempty(handles.curr_parameters.segmentation_para.seg_correction_para.training_data_path))
    fprintf(fileID, "training_data_path = {};\n");
else
    num_entry = length(handles.curr_parameters.segmentation_para.seg_correction_para.training_data_path);
    fprintf(fileID, "training_data_path = {");
    for i=1:num_entry-1
        fprintf(fileID, "'%s';\n    ", handles.curr_parameters.segmentation_para.seg_correction_para.training_data_path{i});
    end
    fprintf(fileID, "'%s'};\n", handles.curr_parameters.segmentation_para.seg_correction_para.training_data_path{num_entry});
end
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS BELOW\n");
fprintf(fileID, "for i=1:length(training_data_path)\n");
fprintf(fileID, "    training_data_path{i} = adjust_path(training_data_path{i});\n");
fprintf(fileID, "end\n");
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS ABOVE\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_ellipse_area_twocells: Minimal area (in pixels) of an\n");
fprintf(fileID, "%% ellipse to perform the k-means algorithm.\n");
fprintf(fileID, "min_ellipse_area_twocells = %g;\n", handles.curr_parameters.segmentation_para.seg_correction_para.min_ellipse_area_twocells);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_fraction_mismatch: Maximal fraction (between 0 and 1) of\n");
fprintf(fileID, "%% mismatch between two k-means runs.\n");
fprintf(fileID, "max_fraction_mismatch = %g;\n", handles.curr_parameters.segmentation_para.seg_correction_para.max_fraction_mismatch);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_no_cell_prob: Threshold probability (between 0 and 1) of\n");
fprintf(fileID, "%% containing no nucleus.\n");
fprintf(fileID, "min_no_cell_prob = %g;\n", handles.curr_parameters.segmentation_para.seg_correction_para.min_no_cell_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_two_cells_prob: Threshold probability (between 0 and 1) of\n");
fprintf(fileID, "%% containing two nuclei.\n");
fprintf(fileID, "min_two_cells_prob = %g;\n", handles.curr_parameters.segmentation_para.seg_correction_para.min_two_cells_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable\n");
fprintf(fileID, "seg_correction_para = struct('training_data_path', {training_data_path}, 'min_ellipse_area_twocells', min_ellipse_area_twocells, ...\n");
fprintf(fileID, "    'max_fraction_mismatch', max_fraction_mismatch, 'min_no_cell_prob', min_no_cell_prob, 'min_two_cells_prob', min_two_cells_prob);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble everything\n");
fprintf(fileID, "segmentation_para = struct('if_active_contour', if_active_contour, ...\n");
fprintf(fileID, "    'if_watershed', if_watershed, 'if_seg_correction', if_seg_correction, ...\n");
fprintf(fileID, "    'if_print_mask', if_print_mask, 'mask_path', adjust_path(mask_path), ...\n");
fprintf(fileID, "    'if_print_ellipse_movie', if_print_ellipse_movie, 'ellipse_movie_path', adjust_path(ellipse_movie_path), ...\n");
fprintf(fileID, "    'if_save_seg_info', if_save_seg_info, 'seg_info_path', adjust_path(seg_info_path), ...\n");
fprintf(fileID, "    'nuc_radius', nuc_radius, 'max_hole_size_for_fill', max_hole_size_for_fill, ...\n");
fprintf(fileID, "    'min_component_size_for_nucleus', min_component_size_for_nucleus, ...\n");
fprintf(fileID, "    'image_binarization_para', image_binarization_para, 'active_contour_para', active_contour_para, ...\n");
fprintf(fileID, "    'watershed_para', watershed_para, 'ellipse_para', ellipse_para, ...\n");
fprintf(fileID, "    'seg_correction_para', seg_correction_para);\n\n");

% tracking
fprintf(fileID, "%%%% TRACK_PARA\n");
fprintf(fileID, "%% Parameters used for track linking\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] training_data_path: Paths to the training data.\n");
if (isempty(handles.curr_parameters.track_para.training_data_path))
    fprintf(fileID, "training_data_path = {};\n");
else
    num_entry = length(handles.curr_parameters.track_para.training_data_path);
    fprintf(fileID, "training_data_path = {");
    for i=1:num_entry-1
        fprintf(fileID, "'%s';\n    ", handles.curr_parameters.track_para.training_data_path{i});
    end
    fprintf(fileID, "'%s'};\n", handles.curr_parameters.track_para.training_data_path{num_entry});
end
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS BELOW\n");
fprintf(fileID, "for i=1:length(training_data_path)\n");
fprintf(fileID, "    training_data_path{i} = adjust_path(training_data_path{i});\n");
fprintf(fileID, "end\n");
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS ABOVE\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] empty_prob: Probability of an event (between 0 and 1) if the\n");
fprintf(fileID, "%% training data is absent.\n");
fprintf(fileID, "empty_prob = %g;\n", handles.curr_parameters.track_para.empty_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Important] if_switch_off_before_mitosis: Whether to ignore the\n");
fprintf(fileID, "%% probability of mitotic cell ('Before M') when evaluating the score for\n");
fprintf(fileID, "%% mitosis\n");
fprintf(fileID, "%% [Optional] if_switch_off_after_mitosis: Whether to ignore the\n");
fprintf(fileID, "%% probability of newly born cells ('After M') when evaluating the score for\n");
fprintf(fileID, "%% mitosis\n");
fprintf(fileID, "if_switch_off_before_mitosis = %g;\n", handles.curr_parameters.track_para.if_switch_off_before_mitosis);
fprintf(fileID, "if_switch_off_after_mitosis = %g;\n", handles.curr_parameters.track_para.if_switch_off_after_mitosis);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] if_similarity_for_migration: Whether to account for ellipse\n");
fprintf(fileID, "%% similarities when calculating migration probabilities\n");
fprintf(fileID, "if_similarity_for_migration = %g;\n", handles.curr_parameters.track_para.if_similarity_for_migration);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Important] migration_sigma: The standard deviation (in pixels) of\n");
fprintf(fileID, "%% migration in one frame and one direction. If NaN is chosen, the value\n");
fprintf(fileID, "%% will be inferred from the training data.\n");
fprintf(fileID, "migration_sigma = %g;\n", handles.curr_parameters.track_para.migration_sigma);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_migration_distance_fold: Maximal distances an ellipse can\n");
fprintf(fileID, "%% travel in each direction and each frame.\n");
fprintf(fileID, "max_migration_distance_fold = %g;\n", handles.curr_parameters.track_para.max_migration_distance_fold);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] likelihood_nonmigration: Null probability (between 0 and 1)\n");
fprintf(fileID, "%% for migration.\n");
fprintf(fileID, "likelihood_nonmigration = %g;\n", handles.curr_parameters.track_para.likelihood_nonmigration);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_inout_prob: Minimal probability (between 0 and 1) of\n");
fprintf(fileID, "%% migrating in/out of the field of view.\n");
fprintf(fileID, "min_inout_prob = %g;\n", handles.curr_parameters.track_para.min_inout_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_gap: Maximal value of 'gap' (in the number fo frames) for\n");
fprintf(fileID, "%% migration. Gap = number of frames to skip + 1\n");
fprintf(fileID, "max_gap = %g;\n", handles.curr_parameters.track_para.max_gap);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] skip_penalty: Penalty score for a track to skip one frame.\n");
fprintf(fileID, "skip_penalty = %g;\n", handles.curr_parameters.track_para.skip_penalty);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] multiple_cells_penalty: Penalty score for an ellipse to\n");
fprintf(fileID, "%% contain two nuclei.\n");
fprintf(fileID, "multiple_cells_penalty = %g;\n", handles.curr_parameters.track_para.multiple_cells_penalty);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_mitosis_prob: Minimal probability (between 0 and 1) of\n");
fprintf(fileID, "%% mitotic and newly born cells.\n");
fprintf(fileID, "min_mitosis_prob = %g;\n", handles.curr_parameters.track_para.min_mitosis_prob);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_num_tracks: Maximal number of tracks to search.\n");
fprintf(fileID, "max_num_tracks = %g;\n", handles.curr_parameters.track_para.max_num_tracks);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_track_score: Minimal score of a track to accept\n");
fprintf(fileID, "min_track_score = %g;\n", handles.curr_parameters.track_para.min_track_score);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_track_score_per_step: Minimal score of a track between two\n");
fprintf(fileID, "%% neighboring frames.\n");
fprintf(fileID, "min_track_score_per_step = %g;\n", handles.curr_parameters.track_para.min_track_score_per_step);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_recorded_link: Number of migration events to keep for each\n");
fprintf(fileID, "%% ellipse. \n");
fprintf(fileID, "max_recorded_link = %g;\n", handles.curr_parameters.track_para.max_recorded_link);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_swap_score: Minimal score for swaping tracks in\n");
fprintf(fileID, "%% post-processing\n");
fprintf(fileID, "min_swap_score = %g;\n", handles.curr_parameters.track_para.min_swap_score);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] fixation_min_prob_before_mitosis: Minimal probability of the\n");
fprintf(fileID, "%% mitotic cell (Before M) to define a missing mitosis event.\n");
fprintf(fileID, "%% [Optional] fixation_min_prob_after_mitosis: Minimal probability of the\n");
fprintf(fileID, "%% newly born cells (After M) to define a missing mitosis event.\n");
fprintf(fileID, "fixation_min_prob_before_mitosis = %g;\n", handles.curr_parameters.track_para.fixation_min_prob_before_mitosis);
fprintf(fileID, "fixation_min_prob_after_mitosis = %g;\n", handles.curr_parameters.track_para.fixation_min_prob_after_mitosis);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] min_track_length: Minimal length (in the number of frames) of\n");
fprintf(fileID, "%% a track.\n");
fprintf(fileID, "min_track_length = %g;\n", handles.curr_parameters.track_para.min_track_length);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] max_num_frames_to_skip: Maximal number of frames a track can\n");
fprintf(fileID, "%% skip.\n");
fprintf(fileID, "max_num_frames_to_skip = %g;\n", handles.curr_parameters.track_para.max_num_frames_to_skip);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] if_print_vistrack: Whether to visualize the tracks by\n");
fprintf(fileID, "%% plotting the 'vistrack' movie.\n");
fprintf(fileID, "%% [Essential] vistrack_path: Path to the folder storing the 'vistrack'\n");
fprintf(fileID, "%% movie.\n");
fprintf(fileID, "if_print_vistrack = %g;\n", handles.curr_parameters.track_para.if_print_vistrack);
fprintf(fileID, "vistrack_path = '%s';\n", handles.curr_parameters.track_para.vistrack_path);
fprintf(fileID, "\n");
fprintf(fileID, "%% Assemble into a struct variable\n");
fprintf(fileID, "track_para = struct('training_data_path', {training_data_path}, 'empty_prob', empty_prob, ...\n");
fprintf(fileID, "    'if_switch_off_before_mitosis', if_switch_off_before_mitosis, ...\n");
fprintf(fileID, "    'if_switch_off_after_mitosis', if_switch_off_after_mitosis, ...\n");
fprintf(fileID, "    'if_similarity_for_migration', if_similarity_for_migration, ...\n");
fprintf(fileID, "    'migration_sigma', migration_sigma, 'max_migration_distance_fold', max_migration_distance_fold, ...\n");
fprintf(fileID, "    'likelihood_nonmigration', likelihood_nonmigration, 'min_inout_prob', min_inout_prob, ...\n");
fprintf(fileID, "    'max_gap', max_gap, 'skip_penalty', skip_penalty, 'multiple_cells_penalty', multiple_cells_penalty, ...\n");
fprintf(fileID, "    'min_mitosis_prob', min_mitosis_prob, 'max_num_tracks', max_num_tracks, 'min_track_score', min_track_score, ...\n");
fprintf(fileID, "    'min_track_score_per_step', min_track_score_per_step, 'max_recorded_link', max_recorded_link, ...\n");
fprintf(fileID, "    'min_swap_score', min_swap_score, 'fixation_min_prob_before_mitosis', fixation_min_prob_before_mitosis, ...\n");
fprintf(fileID, "    'fixation_min_prob_after_mitosis', fixation_min_prob_after_mitosis, ...\n");
fprintf(fileID, "    'min_track_length', min_track_length, 'max_num_frames_to_skip', max_num_frames_to_skip, ...\n");
fprintf(fileID, "    'if_print_vistrack', if_print_vistrack, 'vistrack_path', adjust_path(vistrack_path));\n\n");

% signal extraction
fprintf(fileID, "%%%% SIGNAL_EXTRACTION_PARA\n");
fprintf(fileID, "%% A struct containing all the information of the additional markers. In\n");
fprintf(fileID, "%% other words, this will NOT include the nuclear marker (H2B) which is used\n");
fprintf(fileID, "%% to perform tracking\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] additional_signal_names: Names of the signal channels.\n");
num_entry = length(handles.curr_parameters.signal_extraction_para.additional_signal_names);
if (num_entry == 0)
    fprintf(fileID, "additional_signal_names = {};\n");
else
    fprintf(fileID, "additional_signal_names = {");
    for i=1:num_entry-1
        fprintf(fileID, "'%s';\n                           ", handles.curr_parameters.signal_extraction_para.additional_signal_names{i});
    end
    fprintf(fileID, "'%s'};\n", handles.curr_parameters.signal_extraction_para.additional_signal_names{num_entry});
end
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] additional_biomarker_names: Names of the measured markers in\n");
fprintf(fileID, "%% the signal channels.\n");
num_entry = length(handles.curr_parameters.signal_extraction_para.additional_biomarker_names);
if (num_entry == 0)
    fprintf(fileID, "additional_biomarker_names = {};\n");
else
    fprintf(fileID, "additional_biomarker_names = {");
    for i=1:num_entry-1
        fprintf(fileID, "'%s';\n                   ", handles.curr_parameters.signal_extraction_para.additional_biomarker_names{i});
    end
    fprintf(fileID, "'%s'};\n", handles.curr_parameters.signal_extraction_para.additional_biomarker_names{num_entry});
end
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] additional_raw_image_paths: Paths to the folder storing the captured\n");
fprintf(fileID, "%% images of the signal channels.\n");
num_entry = length(handles.curr_parameters.signal_extraction_para.additional_raw_image_paths);
if (num_entry == 0)
    fprintf(fileID, "additional_raw_image_paths = {};\n");
else
    if (handles.if_tif)
        fprintf(fileID, "additional_raw_image_paths = {");
        for i=1:num_entry-1
            fprintf(fileID, "'%s';\n    ", handles.curr_parameters.signal_extraction_para.additional_raw_image_paths{i});
        end
        fprintf(fileID, "'%s'};\n", handles.curr_parameters.signal_extraction_para.additional_raw_image_paths{i});
    else
        num_entry2 = length(handles.curr_parameters.signal_extraction_para.additional_raw_image_paths{1});
        fprintf(fileID, "additional_raw_image_paths = {");
        for i=1:num_entry
            fprintf(fileID, "{");
            for j=1:num_entry2-1
                fprintf(fileID, "'%s';\n    ", handles.curr_parameters.signal_extraction_para.additional_raw_image_paths{i}{j});
            end
            fprintf(fileID, "'%s'}", handles.curr_parameters.signal_extraction_para.additional_raw_image_paths{i}{num_entry2});
            if (i < num_entry)
                fprintf(fileID, ";\n    ");
            else
                fprintf(fileID, "};\n");
            end
        end
    end
end
fprintf(fileID, "%% USE THE FOLLOWING SCRIPTS IF USING ND2 FILES OR ALL TIFF FILES ARE STORED IN THE SAME FOLDER\n");
fprintf(fileID, "%% additional_raw_image_paths = cell(length(additional_signal_names), 1);\n");
fprintf(fileID, "%% additional_raw_image_paths(:) = {global_setting.nuc_raw_image_path};\n");
fprintf(fileID, "%% USE THE ABOVE SCRIPTS IF USING ND2 FILES OR ALL TIFF FILES ARE STORED IN THE SAME FOLDER\n");
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS BELOW\n");
fprintf(fileID, "for i=1:length(additional_raw_image_paths)\n");
fprintf(fileID, "    if (ischar(additional_raw_image_paths{i}))\n");
fprintf(fileID, "        additional_raw_image_paths{i} = adjust_path(additional_raw_image_paths{i});\n");
fprintf(fileID, "    else\n");
fprintf(fileID, "        for j=1:length(additional_raw_image_paths{i})\n");
fprintf(fileID, "            additional_raw_image_paths{i}{j} = adjust_path(additional_raw_image_paths{i}{j});\n");
fprintf(fileID, "        end\n");
fprintf(fileID, "    end\n");
fprintf(fileID, "end\n");
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS ABOVE\n");
fprintf(fileID, "\n");
fprintf(fileID, "%% [Essential] additional_bias_paths: Paths to the Matlab data file (.mat)\n");
fprintf(fileID, "%% storing the bias information for each signal channel.\n");
num_entry = length(handles.curr_parameters.signal_extraction_para.additional_bias_paths);
if (num_entry == 0)
    fprintf(fileID, "additional_bias_paths = {};\n");
else
    fprintf(fileID, "additional_bias_paths = {");
    for i=1:num_entry - 1
        fprintf(fileID, "'%s';\n    ", handles.curr_parameters.signal_extraction_para.additional_bias_paths{i});
    end
    fprintf(fileID, "'%s'};\n", handles.curr_parameters.signal_extraction_para.additional_bias_paths{num_entry});
end
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS BELOW\n");
fprintf(fileID, "for i=1:length(additional_bias_paths)\n");
fprintf(fileID, "    additional_bias_paths{i} = adjust_path(additional_bias_paths{i});\n");
fprintf(fileID, "end\n");
fprintf(fileID, "%% DO NOT CHANGE THE SCRIPTS ABOVE\n");
fprintf(fileID, "%% [Essential] if_compute_cyto_ring: Indicator variables to determine\n");
fprintf(fileID, "%% whether to extract signals in the cytoplasmic ring.\n");
num_entry = length(handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring);
if (num_entry == 0)
    fprintf(fileID, "if_compute_cyto_ring = [];\n");
else
    fprintf(fileID, "if_compute_cyto_ring = [");
    for i=1:num_entry-1
        fprintf(fileID, "%d;\n                        ", handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(i));
    end
    fprintf(fileID, "%d];\n", handles.curr_parameters.signal_extraction_para.if_compute_cyto_ring(end));
end
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] cyto_ring_inner_size: Minimal distance (in pixels) between the\n");
fprintf(fileID, "%% region of cytoplasmic ring and the ellipse contour.\n");
fprintf(fileID, "%% [Optional] cyto_ring_outer_size: Maximal distance (in pixels) between the\n");
fprintf(fileID, "%% region of cytoplasmic ring and the ellipse contour.\n");
fprintf(fileID, "%% [Optional] nuc_outer_size: Minimal distance (in pixels) between the\n");
fprintf(fileID, "%% region of nucleus and the ellipse contour.\n");
fprintf(fileID, "cyto_ring_inner_size = %g;\n", handles.curr_parameters.signal_extraction_para.cyto_ring_inner_size);
fprintf(fileID, "cyto_ring_outer_size = %g;\n", handles.curr_parameters.signal_extraction_para.cyto_ring_outer_size);
fprintf(fileID, "nuc_outer_size = %g;\n", handles.curr_parameters.signal_extraction_para.nuc_outer_size);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] foreground_dilation_size: Maximal distance (in pixels) between\n");
fprintf(fileID, "%% background and a nucleus.\n");
fprintf(fileID, "foreground_dilation_size = %g;\n", handles.curr_parameters.signal_extraction_para.foreground_dilation_size);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] intensity_percentile: Measured percentile (between 0 and 100)\n");
fprintf(fileID, "%% of each region.\n");
fprintf(fileID, "intensity_percentile = %g;\n", handles.curr_parameters.signal_extraction_para.intensity_percentile);
fprintf(fileID, "\n");
fprintf(fileID, "%% [Optional] lower_percentile: Lower percentile (between 0 and 100) of\n");
fprintf(fileID, "%% intensities to keep.\n");
fprintf(fileID, "%% [Optional] higher_percentile: Higher percentile (between 0 and 100,\n");
fprintf(fileID, "%% greater than lower_percentile) to keep.\n");
fprintf(fileID, "lower_percentile = %g;\n", handles.curr_parameters.signal_extraction_para.lower_percentile);
fprintf(fileID, "higher_percentile = %g;\n", handles.curr_parameters.signal_extraction_para.higher_percentile);
fprintf(fileID, "\n");
fprintf(fileID, "%% Save all parameters into a struct\n");
fprintf(fileID, "signal_extraction_para = struct('additional_signal_names', {additional_signal_names}, ...\n");
fprintf(fileID, "    'additional_biomarker_names', {additional_biomarker_names}, ...\n");
fprintf(fileID, "    'additional_raw_image_paths', {additional_raw_image_paths}, ...\n");
fprintf(fileID, "    'additional_bias_paths', {additional_bias_paths}, ...\n");
fprintf(fileID, "    'if_compute_cyto_ring', if_compute_cyto_ring, ...\n");
fprintf(fileID, "    'cyto_ring_inner_size', cyto_ring_inner_size, 'cyto_ring_outer_size', cyto_ring_outer_size, ...\n");
fprintf(fileID, "    'nuc_outer_size', nuc_outer_size, ...\n");
fprintf(fileID, "    'foreground_dilation_size', foreground_dilation_size, 'intensity_percentile', intensity_percentile, ...\n");
fprintf(fileID, "    'lower_percentile', lower_percentile, 'higher_percentile', higher_percentile);\n");
fprintf(fileID, "\n");
fprintf(fileID, "%%%% ASSEMBLE ALL PARAMETERS\n");
fprintf(fileID, "all_parameters = struct('global_setting', global_setting, 'segmentation_para', ...\n");
fprintf(fileID, "    segmentation_para, 'track_para', track_para, 'signal_extraction_para', signal_extraction_para);\n");
fprintf(fileID, "\n");
fprintf(fileID, "end\n");
fprintf(fileID, "\n");
fprintf(fileID, "function [ new_path ] = adjust_path ( old_path )\n");
fprintf(fileID, "%%ADJUST_PATH Adjust the path of files such that the code can be used in\n");
fprintf(fileID, "%%both windows and mac platforms\n");
fprintf(fileID, "\n");
fprintf(fileID, "new_path = old_path;\n");
fprintf(fileID, "if (~isempty(old_path) && old_path(end) ~= '/' && ~strcmp(old_path(max(end-3,1):end), '.mat'))\n");
fprintf(fileID, "    new_path = cat(2, new_path, '/');\n");
fprintf(fileID, "end\n");
fprintf(fileID, "new_path = strrep(new_path, '\\', '/');\n");
fprintf(fileID, "\n");
fprintf(fileID, "end\n");

% close the file
fclose(fileID);

end
