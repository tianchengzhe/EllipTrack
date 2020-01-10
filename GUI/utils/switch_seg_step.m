function [ handles ] = switch_seg_step( handles )
%SWITCH_SEG_STEP Switch steps of Segmentation in Parameter Generator GUI.
%
%   Input
%       handles: Handles before operation
%   Output
%       handles: Handles after operation

% change visibility
for i=1:6
    if (i == handles.seg_disp_step)
        set(handles.(handles.seg_pushbutton_name{i}), 'Enable', 'off');
        set(handles.(handles.seg_uipanel_name{i}), 'Visible', 'on');
    else
        set(handles.(handles.seg_pushbutton_name{i}), 'Enable', 'on');
        set(handles.(handles.seg_uipanel_name{i}), 'Visible', 'off');
    end
end

% change y positions
gap_y = 0.0632;
all_pos = [0.9369, 0.3965-(0:4)*gap_y;
    0.9369, 0.8737, 0.4495-(0:3)*gap_y;
    0.9369, 0.8737, 0.8106, 0.4545-(0:2)*gap_y;
    0.9369, 0.8737, 0.8106, 0.7475, 0.5177-(0:1)*gap_y;
    0.9369, 0.8737, 0.8106, 0.7475, 0.6843, 0.1414;
    0.9369, 0.8737, 0.8106, 0.7475, 0.6843, 0.6212];
for i=1:6
    temp = get(handles.(handles.seg_pushbutton_name{i}), 'Position');
    temp(2) = all_pos(handles.seg_disp_step, i);
    set(handles.(handles.seg_pushbutton_name{i}), 'Position', temp);
end

% change display
handles = display_seg_step( handles );

end
