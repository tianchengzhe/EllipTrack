function [ I ] = read_image( movie_definition, image_info, cmosoffset, bias )
%READ_IMAGE Global controller to read images from files.
%
%   Input
%       movie_definition: Parameters defining the movie
%       image_info: Information of the image. In the order of 
%       {row_id, col_id, site_id, channel_id, frame_id}
%       cmosoffset: Camera dark noise
%       bias: Illumination bias
%   Output
%       I: image after cmosoffset and bias correction

% order now be {row_id, col_id, site_id, channel_id, frame_id, channel_names, letter form of row_id, letter form of row_id(Cap)}
image_info = cat(2, image_info, {movie_definition.channel_names{image_info{4}}, char(image_info{1}-1+'a'), char(image_info{1}-1+'A')});
switch lower(movie_definition.image_type)
    case 'seq'
        I = imread([movie_definition.image_path{image_info{4}}, sprintf(movie_definition.filename_format, image_info{movie_definition.image_info_order})]);
        
    case 'stack'
        try
            I = imread([movie_definition.image_path{image_info{4}}, sprintf(movie_definition.filename_format, image_info{movie_definition.image_info_order})], 'Frames', image_info{5});
        catch
            I = imread([movie_definition.image_path{image_info{4}}, sprintf(movie_definition.filename_format, image_info{movie_definition.image_info_order})], 'Index', image_info{5});
        end
        
    case 'nd2'
        % determine the readers
        reader_id = find(image_info{5} >= movie_definition.nd2_frame_range(:,1) & image_info{5} <= movie_definition.nd2_frame_range(:,2), 1);
        bfReader = movie_definition.nd2_readers{image_info{1}, image_info{2}}{reader_id};
        
        % determine channel ID
        channel_id = [];
        for i=1:length(bfReader.channelNames)
            if (strcmpi(bfReader.channelNames{i}, image_info{6}))
                channel_id = i;
                break;
            end
        end
        if (isempty(channel_id))
            error('read_image: Image not found. Check the channel name.');
        end
        
        % read images
        I = bfReader.getXYplane(channel_id, image_info{3}, image_info{5}-movie_definition.nd2_frame_range(reader_id,1)+1);

    otherwise
        error('read_image: Unknown image type.');
end

% cmosoffset and bias correction
I = (double(I)-cmosoffset)./bias; I = max(I, 1);

end
