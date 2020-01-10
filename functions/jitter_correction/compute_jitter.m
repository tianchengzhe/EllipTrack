function [ local_jitters ] = compute_jitter( movie_definition, cmosoffset, nuc_bias )
%COMPUTE_JITTER Compute jitters between images
%
%   Input
%       movie_definition: Parameters defining the movies
%       cmosoffset: Information of camera dark noise
%       nuc_bias: Illunimation bias of the nuclear channel
%   Output
%       local_jitters: jitters between images

% define structures to store all jitters
local_jitters = cell(length(movie_definition.frames_to_track), 1);
for i=1:length(movie_definition.frames_to_track)
    local_jitters{i} = nan(movie_definition.plate_def(1), movie_definition.plate_def(2), movie_definition.plate_def(3), 2);
end

% compute the local jitters
% version 1: no parallel computing
if (movie_definition.num_cores == 1) 
    for i=1:size(movie_definition.wells_to_track, 1)
        row_id = movie_definition.wells_to_track(i, 1); 
        col_id = movie_definition.wells_to_track(i, 2);
        site_id = movie_definition.wells_to_track(i, 3);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);

        % read image of the first frame
        curr_I = read_image(movie_definition, {row_id, col_id, site_id, 1, movie_definition.frames_to_track(1)}, cmosoffset, nuc_bias);

        % for other frames
        for j=2:length(movie_definition.frames_to_track)
            disp(['Current Progress: ', num2str(j), '/', num2str(length(movie_definition.frames_to_track))]);
            % put previous image to prev_I, and read the image of the current
            % frame
            prev_I = curr_I;
            curr_I = read_image(movie_definition, {row_id, col_id, site_id, 1, movie_definition.frames_to_track(j)}, cmosoffset, nuc_bias);
            local_jitters{j}(row_id, col_id, site_id, :) = compute_local_jitter(prev_I, curr_I);
        end
    end
else % version 2: parallel computing, need to redefine variables to optimize slicing
    all_row_id = movie_definition.wells_to_track(:, 1);
    all_col_id = movie_definition.wells_to_track(:, 2);
    all_site_id = movie_definition.wells_to_track(:, 3);
    temp_local_jitters = cell(length(all_row_id), 1);
    num_frames = length(movie_definition.frames_to_track);
    
    parfor i=1:length(all_row_id)
        row_id = all_row_id(i); 
        col_id = all_col_id(i);
        site_id = all_site_id(i);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);

        temp_local_jitters{i} = cell(num_frames, 1);
        
        % read image of the first frame
        curr_I = read_image(movie_definition, {row_id, col_id, site_id, 1, movie_definition.frames_to_track(1)}, cmosoffset, nuc_bias);
        
        % for other frames
        for j=2:num_frames
            disp(['Current Progress: ', num2str(j), '/', num2str(num_frames)]);
            % put previous image to prev_I, and read the image of the current
            % frame
            prev_I = curr_I;
            curr_I = read_image(movie_definition, {row_id, col_id, site_id, 1, movie_definition.frames_to_track(j)}, cmosoffset, nuc_bias);
            temp_local_jitters{i}{j} = compute_local_jitter(prev_I, curr_I);
        end
    end
    
    % put back to local_jitters
    for i=1:length(all_row_id)
        row_id = all_row_id(i); 
        col_id = all_col_id(i);
        site_id = all_site_id(i);
        for j=2:num_frames
            local_jitters{j}(row_id, col_id, site_id, :) = temp_local_jitters{i}{j};
        end
    end
end

% compute mean for imaging sites
for i=1:length(movie_definition.frames_to_track)
    local_jitters{i} = compute_mean_jitter(local_jitters{i});
end

% compute the global jitters
if strcmpi(movie_definition.jitter_correction_method, 'global') % do global jitter correction
    for i=2:length(movie_definition.frames_to_track)
        local_jitters{i} = compute_global_jitter( local_jitters{i} );
    end
end

end

function [ local_jitter ] = compute_local_jitter(image1, image2)
%COMPUTE_LOCAL_JITTER Compute jitter between two neighboring frames of the
%same well.
%
%   Input:
%       image1: image of the previous frame
%       image2: image of the current frame
%   Output:
%       local_jitter: jitter between two images, computed by
%       cross-correlation. Defined as image1-image2
%
%   This function is largely adapted from Cappell et al 2016's function
%   registerimages.m
%   Note that here x, y are defined as the image coordinate, which is
%   opposite to the plotting frame

% compute the cross-correlation score. find the point for best match 
score = normxcorr2(image1, image2);
[~, id] = max(score(:));
[best_x, best_y] = ind2sub(size(score), id);

% compute the jitters
local_jitter = size(image1) - [ best_x, best_y ];

end

function [ mean_jitter ] = compute_mean_jitter( local_jitter )
%COMPUTE_MEAN_JITTER Compute the mean of jitters across imaging sites
%
%   Input
%       local_jitter: jitter of every imaging well and site
%   Output
%       mean_jitter: mean jitter of every well

size_local_jitter = size(local_jitter);
mean_jitter = nan(size_local_jitter(1), size_local_jitter(2), size_local_jitter(4));
for i=1:size_local_jitter(1)
    for j=1:size_local_jitter(2)
        for k=1:size_local_jitter(4)
            mean_jitter(i,j,k) = nanmean(local_jitter(i,j,:,k));
        end
    end
end

end
