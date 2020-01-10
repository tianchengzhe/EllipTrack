function step6_visualize_tracking(movie_definition, inout_para, all_ellipse_info, all_tracks, cmosoffset, nuc_bias)
%STEP6_VISUALIZE_TRACKING Interface function for visualization of tracking
%results
%
%   Input
%       movie_definition: Parameters defining the movie
%       inout_para: Parameters defining the inputs and outputs
%       all_ellipse_info: Segmentation results
%       all_tracks: Tracking results
%       cmosoffset: Camera dark noise
%       nuc_bias: Illumination bias of the nuclear channel
%   Output: Empty

disp('Step 6. Visualize Tracking Results');
if ~isempty(inout_para.vistrack_path)
    % version 1: no parallel computing
    if (movie_definition.num_cores == 1) 
        for i=1:size(movie_definition.wells_to_track)
            row_id = movie_definition.wells_to_track(i, 1);
            col_id = movie_definition.wells_to_track(i, 2);
            site_id = movie_definition.wells_to_track(i, 3);
            disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
            visualize_tracking( movie_definition, inout_para, all_ellipse_info{row_id, col_id, site_id}, all_tracks{row_id, col_id, site_id}, row_id, col_id, site_id, cmosoffset, nuc_bias);
        end
    else % version 2: parallel computing, need to redefine variables to optimize slicing
        all_row_id = movie_definition.wells_to_track(:, 1);
        all_col_id = movie_definition.wells_to_track(:, 2);
        all_site_id = movie_definition.wells_to_track(:, 3);
        temp_all_ellipse_info = convert_matrix_seq(movie_definition, all_ellipse_info, 'm2a');
        temp_all_tracks = convert_matrix_seq(movie_definition, all_tracks, 'm2a');
        
        parfor i=1:length(all_row_id)
            row_id = all_row_id(i);
            col_id = all_col_id(i);
            site_id = all_site_id(i);
            disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
            visualize_tracking( movie_definition, inout_para, temp_all_ellipse_info{i}, temp_all_tracks{i}, row_id, col_id, site_id, cmosoffset, nuc_bias);
        end
    end
end

end