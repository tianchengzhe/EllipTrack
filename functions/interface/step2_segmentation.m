function [ all_ellipse_info, all_num_ellipses ] = step2_segmentation( movie_definition, inout_para, segmentation_para, cmosoffset, nuc_bias )
%STEP2_SEGMENTATION Interface function for egmentation
%
%   Input
%       movie_definition: Parameters for defining the movie
%       inout_para: Parameters for defining inputs and outputs
%       segmentation_para: Parameters for segmentation
%       cmosoffset: Camera dark noise
%       nuc_bias: Illumination bias of the nuclear channel
%   Output
%       all_ellipse_info: Segmentation results
%       all_num_ellipses: Number of ellipses at each frame

disp('Step 2. Segmentation');
rng(0); % set random seed to ensure reproducibility

% version 1: no parallel computing
if (movie_definition.num_cores == 1) 
    all_ellipse_info = cell(movie_definition.plate_def);
    all_num_ellipses = cell(movie_definition.plate_def);
    for i=1:size(movie_definition.wells_to_track, 1)
        % segmentation
        row_id = movie_definition.wells_to_track(i,1);
        col_id = movie_definition.wells_to_track(i,2);
        site_id = movie_definition.wells_to_track(i,3);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
        all_ellipse_info{row_id, col_id, site_id} = segmentation( movie_definition, inout_para, segmentation_para, row_id, col_id, site_id, cmosoffset, nuc_bias );

        % count detection number
        all_num_ellipses{row_id, col_id, site_id} = nan(length(movie_definition.frames_to_track), 1);
        for j=1:length(movie_definition.frames_to_track)
            all_num_ellipses{row_id, col_id, site_id}(j) = size(all_ellipse_info{row_id, col_id, site_id}{j}.all_parametric_para, 1);
        end
    end
else % version 2: parallel computing, need to redefine variables to optimize slicing
    all_row_id = movie_definition.wells_to_track(:, 1);
    all_col_id = movie_definition.wells_to_track(:, 2);
    all_site_id = movie_definition.wells_to_track(:, 3);
    
    temp_all_ellipse_info = cell(length(all_row_id), 1);
    temp_all_num_ellipses = cell(length(all_row_id), 1);
    
    % compute temp variable
    parfor i=1:length(all_row_id)
        row_id = all_row_id(i);
        col_id = all_col_id(i);
        site_id = all_site_id(i);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
        
        % segmentation
        temp_all_ellipse_info{i} = segmentation( movie_definition, inout_para, segmentation_para, row_id, col_id, site_id, cmosoffset, nuc_bias );
        
        % count ellipse number
        temp_all_num_ellipses{i} = nan(length(movie_definition.frames_to_track), 1);
        for j=1:length(movie_definition.frames_to_track)
            temp_all_num_ellipses{i}(j) = size(temp_all_ellipse_info{i}{j}.all_parametric_para, 1);
        end
    end
    
    % aggregate into final structure
    all_num_ellipses = convert_matrix_seq(movie_definition, temp_all_num_ellipses, 'a2m'); 
    all_ellipse_info = convert_matrix_seq(movie_definition, temp_all_ellipse_info, 'a2m'); 
end

% save results, switch to v7.3 if files are too large
save([inout_para.output_path, 'segmentation.mat'], 'all_ellipse_info', 'all_num_ellipses');
[~, id] = lastwarn('');
if strcmp(id,'MATLAB:save:sizeTooBigForMATFile') 
    save([inout_para.output_path, 'segmentation.mat'], 'all_ellipse_info', 'all_num_ellipses', '-v7.3');
    disp('Use v7.3 switch instead. All variables have been saved.');
end

end