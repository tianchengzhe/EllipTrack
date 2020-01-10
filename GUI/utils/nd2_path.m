function varargout = nd2_path(varargin)
% nd2_path MATLAB code for nd2_path.fig
%      nd2_path, by itself, creates a new nd2_path or raises the existing
%      singleton*.
%
%      H = nd2_path returns the handle to a new nd2_path or the handle to
%      the existing singleton*.
%
%      nd2_path('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in nd2_path.M with the given input arguments.
%
%      nd2_path('Property','Value',...) creates a new nd2_path or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nd2_path_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nd2_path_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nd2_path

% Last Modified by GUIDE v2.5 13-Nov-2019 02:26:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nd2_path_OpeningFcn, ...
                   'gui_OutputFcn',  @nd2_path_OutputFcn, ...
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

% --- Executes just before nd2_path is made visible.
function nd2_path_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nd2_path (see VARARGIN)

% Choose default command line output for nd2_path
handles.output = hObject;

% https://www.mathworks.com/matlabcentral/answers/482510-annotationpane-handle-appearing-in-guide-guis-with-panel-axes-in-r2019b
% **************** ADD THIS SECTION ******************
% Check if scribeOverlay is a field and that it contains an annotation pane
if isfield(handles,'scribeOverlay') && isa(handles.scribeOverlay(1),'matlab.graphics.shape.internal.AnnotationPane')
    delete(handles.scribeOverlay);
    handles = rmfield(handles, 'scribeOverlay');
end
% **********************  END ************************

% Load files
handles.existing_data = varargin{1};
if ~isempty(varargin{1})
    set(handles.listbox_loaded, 'String', varargin{1}, 'Value', 1);
else
    set(handles.listbox_loaded, 'String', varargin{1}, 'Value', []);
end
handles = set_enable_updown(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nd2_path wait for user response (see UIRESUME)
uiwait(handles.figure1);

end

% --- Outputs from this function are returned to the command line.
function varargout = nd2_path_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% handles
varargout{1} = get(hObject, 'UserData');
delete(handles.figure1);

end

function edit_load_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_load_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_load_path as text
%        str2double(get(hObject,'String')) returns contents of edit_load_path as a double

try
    set(hObject, 'String', adjust_path(get(hObject, 'String'), 0));
    set(handles.pushbutton_add, 'Enable', 'on');
catch
    waitfor(warndlg('Invalid path.','Warning'));
    set(hObject, 'String', '');
end
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function edit_load_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_load_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_load_path.
function pushbutton_load_path_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selpath = uigetdir();
if ~isequal(selpath, 0)
    set(handles.edit_load_path, 'String', adjust_path(selpath, 0));
    set(handles.pushbutton_add, 'Enable', 'on');
end
guidata(hObject, handles);

end

% --- Executes on selection change in listbox_loaded.
function listbox_loaded_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_loaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_loaded contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_loaded

handles = set_enable_updown(handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function listbox_loaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_loaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% examine duplication
str = get(handles.listbox_loaded, 'String');
new_str = get(handles.edit_load_path, 'String');
if ~isempty(str) && any(cellfun(@(x) strcmpi(x, new_str), str))
    waitfor(warndlg('Folder is already in the list.','Warning'));
    return;
end

% add training data
str = cat(1, str, {new_str});
set(handles.listbox_loaded, 'String', str, 'Value', length(str));
set(handles.edit_load_path, 'String', '');
set(handles.pushbutton_add, 'Enable', 'off');
handles = set_enable_updown(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_up.
function pushbutton_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.listbox_loaded, 'Value');
str = get(handles.listbox_loaded, 'String');
set(handles.listbox_loaded, 'String', str([1:val-2, val, val-1, val+1:end]), 'Value', val-1);
handles = set_enable_updown(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_down.
function pushbutton_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.listbox_loaded, 'Value');
str = get(handles.listbox_loaded, 'String');
set(handles.listbox_loaded, 'String', str([1:val-1, val+1, val, val+2:end]), 'Value', val+1);
handles = set_enable_updown(handles);
guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_remove.
function pushbutton_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.listbox_loaded, 'Value');
str = get(handles.listbox_loaded, 'String');
if (length(str)>1)
    set(handles.listbox_loaded, 'String', str([1:val-1, val+1:end]), 'Value', max(val-1, 1));
else
    set(handles.listbox_loaded, 'String', str([1:val-1, val+1:end]), 'Value', []);
end
handles = set_enable_updown(handles);
guidata(hObject, handles);

end

function handles = set_enable_updown(handles)
%SET_ENABLE_UPDOWN Set the enability of "UP" and "DOWN" buttons.
%
%   Input
%       handles: Handles before operation.
%   Output
%       handles: Handles after operation.

val = get(handles.listbox_loaded, 'Value');
num_entry = length(get(handles.listbox_loaded, 'String'));
if (isempty(val))
    set(handles.pushbutton_up, 'Enable', 'off');
    set(handles.pushbutton_down, 'Enable', 'off');
    set(handles.pushbutton_remove, 'Enable', 'off');
else
    set(handles.pushbutton_remove, 'Enable', 'on');
    if (val == 1)
        set(handles.pushbutton_up, 'Enable', 'off');
    else
        set(handles.pushbutton_up, 'Enable', 'on');
    end
    if (val == num_entry)
        set(handles.pushbutton_down, 'Enable', 'off');
    else
        set(handles.pushbutton_down, 'Enable', 'on');
    end
end

end

% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.existing_data = get(handles.listbox_loaded, 'String');
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(handles.figure1, 'UserData', handles.existing_data);
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

end
