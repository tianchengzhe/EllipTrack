function [ movie_definition, inout_para, segmentation_para, prob_para, track_para, signal_extraction_para, cmosoffset, all_bias ] = step1_initialization()
%STEP1_INITIALIZATION Interface function for preparation work
%
%   Input: empty
%   Output
%       movie_definition: Parameters defining the movie
%       inout_para: Parameters defining inputs and outputs
%       segmentation_para: Parameters for segmentation
%       prob_para: Parameters for prediction of events
%       track_para: Parameters for track linking
%       signal_extraction_para: Parameters for signal extraction
%       cmosoffset: Camera dark noise
%       all_bias: Illumination bias

disp('Step 1. Initialization');

% read parameters
all_parameters = parameters();
movie_definition = all_parameters.movie_definition;
inout_para = all_parameters.inout_para;
segmentation_para = all_parameters.segmentation_para;
prob_para = all_parameters.prob_para;
track_para = all_parameters.track_para; 
signal_extraction_para = all_parameters.signal_extraction_para;

% compute plate_def
movie_definition.plate_def = max(movie_definition.wells_to_track, [], 1);

% convert filename
[ filename_format, image_info_order ] = convert_filename_format( movie_definition );
movie_definition.filename_format = filename_format;
movie_definition.image_info_order = image_info_order;

% obtain readers for nd2 files
if strcmpi(movie_definition.image_type, 'nd2')
    [ nd2_frame_range, all_bfReaders ] = init_nd2_readers( movie_definition );
    movie_definition.nd2_frame_range = nd2_frame_range;
    movie_definition.nd2_readers = all_bfReaders;
end

% get image size
movie_definition.size_image = size(read_image(movie_definition, {movie_definition.wells_to_track(1,1), movie_definition.wells_to_track(1,2), ...
    movie_definition.wells_to_track(1,3), 1, movie_definition.frames_to_track(1)}, 0, 1));

% load cmosoffset and bias
try
    h = load(movie_definition.cmosoffset_path); cmosoffset = h.cmosoffset;
catch
    warning('Fail to load cmosoffset. Will not correct camera dark noise.');
    cmosoffset = 0;
end

all_bias = cell(length(movie_definition.channel_names), 1);
for i=1:length(movie_definition.channel_names)
    try
        h = load(movie_definition.bias_paths{i}); all_bias{i} = h.bias;
    catch
        warning(['Fail to load bias for ', movie_definition.channel_names{i}, ' channel. Will not correct illumination bias for this channel.']);
        all_bias{i} = 1;
    end
end

% initialize parpool
if (movie_definition.num_cores > 1)
    myCluster = parcluster('local');
    movie_definition.num_cores = min(movie_definition.num_cores, myCluster.NumWorkers);
end
if (movie_definition.num_cores > 1)
    parpool(movie_definition.num_cores);
end

end
