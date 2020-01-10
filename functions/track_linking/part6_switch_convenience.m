function [ all_tracks ] = part6_switch_convenience( all_tracks, all_ellipse_info )
%PART6_SWITCH_CONVENIENCE Switch track IDs for convenience
%
%   Input
%       all_tracks: Cell tracks
%       all_ellipse_info: Segmentation results
%   Output
%       all_tracks: Modified cell tracks

num_tracks = length(all_tracks);
first_frame_ellipse_ypos = cell2mat(all_ellipse_info{1}.all_parametric_para')'; 
first_frame_ellipse_ypos = first_frame_ellipse_ypos(:, 3);
while 1
    % Step 1. Newly born daughter cells should have consecutive IDs
    old_to_new_mapping = 1:num_tracks;
    for i=1:length(all_tracks)
        daughter_id = sort(cell2mat(all_tracks{i}.daughters));
        if (isempty(daughter_id))
            continue;
        end
        if (daughter_id(2)>daughter_id(1)+1 && old_to_new_mapping(daughter_id(2))==daughter_id(2) && old_to_new_mapping(daughter_id(1)+1)==daughter_id(1)+1) % swap daughter_id(2) with daughter_id(1)+1
            old_to_new_mapping([daughter_id(1)+1, daughter_id(2)]) = old_to_new_mapping([daughter_id(2), daughter_id(1)+1]);
        end
    end
    [ all_tracks, num_swap1 ] = one_switch_instance( all_tracks, old_to_new_mapping, num_tracks );
    
    % Step 2. Change the Track ID at first frame according to ellipse positions
    old_to_new_mapping = 1:num_tracks;
    first_frame_info = [];
    for i=1:num_tracks
        if (~isnan(all_tracks{i}.current_id(1)))
            first_frame_info = cat(1, first_frame_info, [i, all_tracks{i}.current_id(1)]);
        end
    end
    
    if ~(isempty(first_frame_info))
        [~, sort_id] = sort(first_frame_ellipse_ypos(first_frame_info(:, 2)));
        old_to_new_mapping(first_frame_info(:, 1)) = old_to_new_mapping(first_frame_info(sort_id, 1));
        [ all_tracks, num_swap2 ] = one_switch_instance( all_tracks, old_to_new_mapping, num_tracks );
    else
        num_swap2 = 0;
    end
    
    % Terminate if no change
    if (num_swap1 + num_swap2 == 0)
        break;
    end
    disp(['Switched ', num2str(num_swap1 + num_swap2), ' track IDs.']);
end

end

function [ all_tracks, num_swap ] = one_switch_instance( all_tracks, old_to_new_mapping, num_tracks )
%ONE_SWAP_INSTANCE Perform one switch operation of track ID
%
%   Input
%       all_tracks: Cell tracks
%       old_to_new_mapping: Mapping between old and new numbering
%       num_tracks: Number of cell tracks
%   Output
%       all_tracks: Modified cell tracks
%       num_swap: Number of switching events

num_swap = sum(old_to_new_mapping ~= 1:num_tracks);
all_tracks = all_tracks(old_to_new_mapping);
for i=1:length(all_tracks)
    id = find(cellfun(@length, all_tracks{i}.daughters)>0);
    if (isempty(id))
        continue;
    end
    all_tracks{i}.daughters{id} = sort(arrayfun(@(x) find(x==old_to_new_mapping), all_tracks{i}.daughters{id}));
end

end