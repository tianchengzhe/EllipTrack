function [ all_signals ] = step7_signal_extraction( movie_definition, inout_para, signal_extraction_para, all_ellipse_info, accumulated_jitters, all_tracks, cmosoffset, all_bias )
%STEP7_SIGNAL_EXTRACTION Interface function for signal extraction
%
%   Input
%       movie_definition: Parameters for defining the movie
%       inout_para: Parameters defining inputs and outputs
%       signal_extraction_para: Parameters for signal extraction
%       all_ellipse_info: Segmentation results
%       accumulated_jitters: Jitters compared to the first image
%       all_tracks: Tracking results
%       cmosoffset: Camera dark noise
%       all_bias: Illumination bias
%   Output
%       all_signals: Extracted signals

disp('Step 7. Signal Extraction');

% version 1: no parallel computing
if (movie_definition.num_cores == 1) 
    all_signals = cell(movie_definition.plate_def);
    for i=1:size(movie_definition.wells_to_track, 1)
        row_id = movie_definition.wells_to_track(i, 1);
        col_id = movie_definition.wells_to_track(i, 2);
        site_id = movie_definition.wells_to_track(i, 3);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
        all_signals{row_id, col_id, site_id} = signal_extraction ( movie_definition, signal_extraction_para, all_ellipse_info{row_id, col_id, site_id}, ...
            squeeze(accumulated_jitters(row_id, col_id, :, :)), all_tracks{row_id, col_id, site_id}, row_id, col_id, site_id, cmosoffset, all_bias );
    end
else % version 2: parallel computing, need to redefine variables to optimize slicing
    all_row_id = movie_definition.wells_to_track(:, 1);
    all_col_id = movie_definition.wells_to_track(:, 2);
    all_site_id = movie_definition.wells_to_track(:, 3);
    temp_all_ellipse_info = convert_matrix_seq(movie_definition, all_ellipse_info, 'm2a');
    temp_all_tracks = convert_matrix_seq(movie_definition, all_tracks, 'm2a');
    temp_accu_jitters = convert_accu_jitters(movie_definition, accumulated_jitters);
    
    temp_all_signals = cell(length(all_row_id), 1);
    parfor i=1:length(all_row_id)
        row_id = all_row_id(i);
        col_id = all_col_id(i);
        site_id = all_site_id(i);
        disp(['Current Progress: Row ', num2str(row_id), ', Column ', num2str(col_id), ', Site ', num2str(site_id)]);
        temp_all_signals{i} = signal_extraction ( movie_definition, signal_extraction_para, temp_all_ellipse_info{i}, ...
            temp_accu_jitters{i}, temp_all_tracks{i}, row_id, col_id, site_id, cmosoffset, all_bias );
    end
    all_signals = convert_matrix_seq(movie_definition, temp_all_signals, 'a2m');
end

save([inout_para.output_path, 'signals.mat'], 'all_signals');
[~, id] = lastwarn('');
if strcmp(id,'MATLAB:save:sizeTooBigForMATFile') 
    save([inout_para.output_path, 'signals.mat'], 'all_signals', '-v7.3');
    disp('Use v7.3 switch instead. All variables have been saved.');
end

end