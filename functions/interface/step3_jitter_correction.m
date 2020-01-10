function [ accumulated_jitters ] = step3_jitter_correction( movie_definition, inout_para, cmosoffset, nuc_bias )
%STEP3_JITTER_CORRECTION Interface function for jitter correction
%
%   Input
%       movie_definition: Parameters defining the movies
%       inout_para: Parameters defining the inputs and outputs
%       cmosoffset: Camera dark noises
%       nuc_bias: Illumination bias of the nuclear channel
%   Output
%       accumulated_jitters: Jitters compared to the first frame

disp('Step 3. Jitter Correction');
accumulated_jitters = zeros(movie_definition.plate_def(1), movie_definition.plate_def(2), length(movie_definition.frames_to_track), 2);

% update accumulated_jitters only when performing jitter correction
if ~strcmpi(movie_definition.jitter_correction_method, 'none')  
    jitters = compute_jitter( movie_definition, cmosoffset, nuc_bias );
    
    for i=1:size(movie_definition.wells_to_track, 1)
        row_id = movie_definition.wells_to_track(i, 1);
        col_id = movie_definition.wells_to_track(i, 2);
        for j=2:length(movie_definition.frames_to_track)
            % compute accumulated jitter compared to the first image
            curr_jitter = squeeze(jitters{j}(row_id, col_id, :));
            accumulated_jitters(row_id, col_id, j, :) = squeeze(accumulated_jitters(row_id, col_id, j-1, :)) + curr_jitter;
        end
    end
end

% save data
save([inout_para.output_path, 'jitter_correction.mat'], 'accumulated_jitters');
[~, id] = lastwarn('');
if strcmp(id,'MATLAB:save:sizeTooBigForMATFile') 
    save([inout_para.output_path, 'jitter_correction.mat'], 'accumulated_jitters', '-v7.3');
    disp('Use v7.3 switch instead. All variables have been saved.');
end

end