function [ all_tracks ] = remove_empty_tracks( all_tracks )
%REMOVE_EMPTY_TRACKS Remove empty tracks from all_tracks data structure
%
%   Input
%       all_tracks: Cell tracks
%   Output
%       all_tracks: Modified cell tracks

if_valid = zeros(1, length(all_tracks));
for i=1:length(all_tracks)
    if any(~isnan(all_tracks{i}.current_id))
        if_valid(i) = 1;
    end
end
old_to_new_mapping = cumsum(if_valid);
all_tracks = all_tracks(logical(if_valid));

for i=1:length(all_tracks)
    temp = find(cellfun(@length, all_tracks{i}.daughters) > 0);
    if (isempty(temp))
        continue;
    end
    all_tracks{i}.daughters{temp} = old_to_new_mapping(all_tracks{i}.daughters{temp});
end

if (isempty(all_tracks))
    error('remove_empty_tracks: No tracks available.');
end

end