function [ nd2_frame_range, all_bfReaders ] = init_nd2_readers( movie_definition )
%INIT_ND2_READERS Obtain ND2 information
%
%   Input
%       movie_definition: Parameters defining the movie
%   Output
%       nd2_frame_range: Range of frames in each nd2 file
%       all_bfReaders: BioformatsImage reader of each nd2 file

% initialize empty vector
all_bfReaders = cell(movie_definition.plate_def(1), movie_definition.plate_def(2));
num_entries = length(movie_definition.image_path);
nd2_frame_range = nan(num_entries, 2);

% iterate over every well
for i=1:size(movie_definition.wells_to_track, 1)
    row_id = movie_definition.wells_to_track(i, 1);
    col_id = movie_definition.wells_to_track(i, 2);
    if (~isempty(all_bfReaders{row_id, col_id})) % already analyzed
        continue; 
    end
    
    % get filename
    image_info = {row_id, col_id, 1, 1, 1, 'a', char(row_id-1+'a'), char(row_id-1+'A')};
    filename = sprintf(movie_definition.filename_format, image_info{movie_definition.image_info_order});
    
    % iterate over every entry
    for j=1:num_entries
        % find ND2 file
        all_files = dir(movie_definition.image_path{j});
        recorded_file_id = [];
        for k=1:length(all_files)
            if strncmpi(filename, all_files(k).name, length(filename))
                recorded_file_id = k;
                break;
            end
        end
        if (isempty(recorded_file_id))
            error('init_nd2_readers: Image not found. Check the names of ND2 files.');
        end

        % construct readers
        all_bfReaders{row_id, col_id}{j} = BioformatsImage([movie_definition.image_path{j}, all_files(recorded_file_id).name]);
        
        % infer nd2 frame range
        if (i==1)
            temp = [1, all_bfReaders{row_id, col_id}{j}.sizeT];
            if (j==1)
                nd2_frame_range(j, :) = temp;
            else
                nd2_frame_range(j, :) = temp + nd2_frame_range(j-1, 2);
            end
        end
    end
end

end