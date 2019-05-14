function [ global_jitters ] = compute_jitter( global_setting, cmosoffset, nuc_bias )
%COMPUTE_JITTER Compute jitters between images
%
%   Input
%       global_setting: Parameters used by all tracker modules
%       cmosoffset: Information of camera dark noise
%       nuc_bias: Information of illunimation bias of the nuclear channel
%   Output
%       global_jitters: jitters between images

% define structures to store all jitters
local_jitters = cell(length(global_setting.all_frames), 1);
num_sites = max(global_setting.valid_wells(:,3));
for i=1:length(global_setting.all_frames)
    local_jitters{i} = nan(8, 12, num_sites, 2);
end

% compute the local jitters
for i=1:size(global_setting.valid_wells, 1)
    row_id = global_setting.valid_wells(i, 1); 
    col_id = global_setting.valid_wells(i, 2);
    site_id = global_setting.valid_wells(i, 3);
    disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
    
    % read image of the first frame
    curr_I = read_image(global_setting.nuc_raw_image_path, global_setting.nd2_frame_range, row_id, col_id, site_id, global_setting.nuc_signal_name, global_setting.all_frames(1), cmosoffset, nuc_bias);

    % for other frames
    for j=2:length(global_setting.all_frames)
        disp(['Current Progress: ', num2str(j), '/', num2str(length(global_setting.all_frames))]);
        % put previous image to prev_I, and read the image of the current
        % frame
        prev_I = curr_I;
        curr_I = read_image(global_setting.nuc_raw_image_path, global_setting.nd2_frame_range, row_id, col_id, site_id, global_setting.nuc_signal_name, global_setting.all_frames(j), cmosoffset, nuc_bias);
        local_jitters{j}(row_id, col_id, site_id, :) = compute_local_jitter(prev_I, curr_I);
    end
end

% compute the global jitters
global_jitters = cell(length(global_setting.all_frames), 1);
for i=1:length(global_setting.all_frames)
    global_jitters{i} = compute_mean_jitter(local_jitters{i});
end

if (global_setting.if_global_correction) % do global jitter correction
    if (size(global_setting.valid_wells, 1) <= 5) % too few entries
        warning('Too few wells to perform global jitter correction. Will output local jitters instead.');
    else % perform jitter correction
        for i=2:length(global_setting.all_frames)
            global_jitters{i} = compute_global_jitter( global_jitters{i} );
        end
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
