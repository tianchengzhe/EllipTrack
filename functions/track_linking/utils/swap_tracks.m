function [ all_tracks ] = swap_tracks( all_tracks, track1_id, track2_id, frame_id )
%SWAP_TRACKS Swap the contents of two tracks from a specified frame
%
%   Input
%   all_tracks: tracks before swapping
%       track1_id: id of the first track
%       track2_id: id of the second track
%       frame_id: swapping point
%   Output
%   all_tracks: tracks after swapping

% swap the content from frame_id
temp = all_tracks{track1_id};
all_tracks{track1_id}.current_id(frame_id:end) = all_tracks{track2_id}.current_id(frame_id:end);
all_tracks{track1_id}.gap_to_previous_id(frame_id:end) = all_tracks{track2_id}.gap_to_previous_id(frame_id:end);
all_tracks{track1_id}.gap_to_next_id(frame_id:end) = all_tracks{track2_id}.gap_to_next_id(frame_id:end);
all_tracks{track1_id}.if_apoptosis(frame_id:end) = all_tracks{track2_id}.if_apoptosis(frame_id:end);
all_tracks{track1_id}.daughters(frame_id:end) = all_tracks{track2_id}.daughters(frame_id:end);

all_tracks{track2_id}.current_id(frame_id:end) = temp.current_id(frame_id:end);
all_tracks{track2_id}.gap_to_previous_id(frame_id:end) = temp.gap_to_previous_id(frame_id:end);
all_tracks{track2_id}.gap_to_next_id(frame_id:end) = temp.gap_to_next_id(frame_id:end);
all_tracks{track2_id}.if_apoptosis(frame_id:end) = temp.if_apoptosis(frame_id:end);
all_tracks{track2_id}.daughters(frame_id:end) = temp.daughters(frame_id:end);

end
