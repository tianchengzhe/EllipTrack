function [ I ] = read_image( image_path, nd2_frame_range, row_id, col_id, site_id, sig_name, frame_id, cmosoffset, bias )
%READ_IMAGE Global controller to read images from files. Can choose ND2 or
%TIF, dependent on whether nd2_frame_range is empty or not.
%
%   Input
%       image_path: Path to the raw images
%       nd2_frame_range: Range of frames each nd2 file covers
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       sig_name: Name of the fluorescence marker
%       frame_id: Frame ID of the movie
%       cmosoffset: Information of camera dark noise
%       bias: Information of illumination bias
%   Output
%       I: Image after CMOS Offset and Bias correction

% read files
if (isempty(nd2_frame_range)) % read tif
    I = read_image_tif( image_path, row_id, col_id, site_id, sig_name, frame_id );
else % read from nd2
    I = read_image_nd2( image_path, nd2_frame_range, row_id, col_id, site_id, sig_name, frame_id );
end

% cmosoffset and bias correction    
I = (double(I)-cmosoffset)./bias; I = max(I, 1);

end

function [ I ] = read_image_tif( image_path, row_id, col_id, site_id, sig_name, frame_id )
%READ_IMAGE_TIF Read one image directly from tif files
%
%   Input
%       image_path: Path to the raw images
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       sig_name: Name of the fluorescence marker
%       frame_id: Frame ID of the movie
%   Output
%       I: Image

try
    I = imread([image_path, num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', sig_name, '_', num2str(frame_id), '.tif']);
catch
    I = imread([image_path, num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', sig_name, '_', num2str(frame_id), '.TIFF']);
end

end

function [ I ] = read_image_nd2( image_path, nd2_frame_range, row_id, col_id, site_id, sig_name, frame_id )
%READ_IMAGE_ND2 Read one image from Nikon ND2 files. Require to install 
% BioformatsImage.mltbx. Adapted from Jian Tay's code
%
%   Input
%       image_path: Path to the raw images
%       nd2_frame_range: Range of frames each nd2 file covers
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       sig_name: Name of the fluorescence marker
%       frame_id: Frame ID of the movie
%   Output
%       I: Image

% find the right path to ND2 file
image_path_id = find(nd2_frame_range(:,1) <= frame_id & nd2_frame_range(:,2) >= frame_id, 1);
if (isempty(image_path_id))
    error('Image not found. Check image_path and nd2_frame_range');
end

% find the right ND2 file
all_files = dir(image_path{image_path_id});
leading_filename = ['Well', char(row_id-1+'A'), sprintf('%02d',col_id) ];
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
    error('Image not found. Check the names of ND2 files.');
end
bfReader = BioformatsImage([image_path{image_path_id}, all_files(recorded_file_id).name]);

% get channel ID
channel_id = [];
for i=1:length(bfReader.channelNames)
    if (strcmp(bfReader.channelNames{i}, sig_name))
        channel_id = i;
        break;
    end
end
if (isempty(channel_id))
    error('Image not found. Check the channel name.');
end

% read the image
I = bfReader.getXYplane(channel_id, site_id, frame_id - nd2_frame_range(image_path_id, 1) + 1);

end
