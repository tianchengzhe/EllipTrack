function visualize_tracking( all_ellipse_info, all_tracks, global_setting, row_id, col_id, site_id, track_para, cmosoffset, nuc_bias )
%VISUALIZE_TRACKING Visualize the tracking results
%
%   Input
%       all_ellipse_info: Segmentation results
%       all_tracks: Cell tracks
%       global_setting: Parameters used by all tracker module
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       track_para: Parameters for track linking
%       cmosoffset: Information of camera dark noise
%       nuc_bias: Information of illumination bias for the nuclear channel
%   Output: empty

num_tracks = length(all_tracks);
% iterate over all images
for i=1:length(global_setting.all_frames)
    % read the image
    disp([ 'Current Progress: ', num2str(i), '/', num2str(length(global_setting.all_frames)) ]);
    frame_id = global_setting.all_frames(i);
    I = read_image(global_setting.nuc_raw_image_path, global_setting.nd2_frame_range, row_id, col_id, site_id, global_setting.nuc_signal_name, frame_id, cmosoffset, nuc_bias);
    
    % plot the image
    h = figure(1); imshow(mat2gray(I)); hold on;
    all_boundary_points = all_ellipse_info{i}.all_boundary_points;
    all_parametric_para = all_ellipse_info{i}.all_parametric_para;
    for j=1:length(all_boundary_points)
        plot(all_boundary_points{j}(:,2), all_boundary_points{j}(:,1), 'Color', [0.8, 0.5, 0.5], 'LineWidth', 1);
    end
    
    % plot the tracks
    for j=1:num_tracks
        if (isnan(all_tracks{j}.current_id(i))) % track has no value at this frame
            continue;
        end
        if (all_tracks{j}.if_apoptosis(i)) % has apoptosis -> red text
            color_text = [0.8, 0.5, 0.5];
        elseif (~isempty(all_tracks{j}.daughters{i})) % has mitosis -> blue text
            color_text = [0.5, 0.5, 0.8];
        else % migration -> green text
            color_text = [0.5, 0.8, 0.5]; 
        end
        text(all_parametric_para{all_tracks{j}.current_id(i)}(3)+rand*4-2, all_parametric_para{all_tracks{j}.current_id(i)}(4)+rand*4-2,...
            num2str(j), 'Color', color_text, 'FontSize', 12);
    end
    
    % print the image
    h.PaperUnits = 'Points';
    h.PaperPosition = [0, 0, size(I)/2];
    filename = [num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', global_setting.nuc_signal_name, '_', num2str(frame_id)];
    print(gcf, '-dtiff', [track_para.vistrack_path, filename, '.tif']);
    close(h);
end

end
