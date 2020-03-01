function visualize_tracking( movie_definition, inout_para, all_ellipse_info, all_tracks, row_id, col_id, site_id, cmosoffset, nuc_bias )
%VISUALIZE_TRACKING Visualize the tracking results
%
%   Input
%       movie_definition: Parameters defining the movie
%       inout_para: Parameters defining the inputs and outputs
%       all_ellipse_info: Segmentation results
%       all_tracks: Tracking results
%       row_id: Row ID of the movie
%       col_id: Column ID of the movie
%       site_id: Site ID of the movie
%       cmosoffset: Camera dark noise
%       nuc_bias: Illumination bias of the nuclear channel
%   Output: Empty

% adjust path
if ~isempty(inout_para.vistrack_path)
    inout_para.vistrack_path = [inout_para.vistrack_path, num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '/'];
    if ~exist(inout_para.vistrack_path, 'dir')
        mkdir(inout_para.vistrack_path);
    end
end

num_tracks = length(all_tracks);
% iterate over all images
for i=1:length(movie_definition.frames_to_track)
    % read the image
    disp([ 'Current Progress: ', num2str(i), '/', num2str(length(movie_definition.frames_to_track)) ]);
    frame_id = movie_definition.frames_to_track(i);
    I = read_image(movie_definition, {row_id, col_id, site_id, 1, frame_id}, cmosoffset, nuc_bias);
    
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
    h.PaperPosition = [0, 0, size(I')/2];
    h.PaperSize = size(I')/2;
    filename = [num2str(row_id), '_', num2str(col_id), '_', num2str(site_id), '_', movie_definition.channel_names{1}, '_', num2str(frame_id)];
    print(gcf, '-dtiff', [inout_para.vistrack_path, filename, '.tif']);
    close(h);
end

end
