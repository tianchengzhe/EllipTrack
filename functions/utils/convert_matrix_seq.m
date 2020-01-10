function [ new_variable ] = convert_matrix_seq( movie_definition, old_variable, direction )
%CONVERT_MATRIX_SEQ Convert between cell matrices and cell arrays. For
%parallel computing
%
%   Input
%       movie_definition: Parameters defining the movie
%       old_variable: Variable before conversion
%       direction: 'm2a' for matrix -> array; 'a2m' for array -> matrix
%   Output
%       new_variable: Variable after conversion

switch lower(direction)
    case 'm2a'
        new_variable = cell(size(movie_definition.wells_to_track, 1), 1);
        for i=1:size(movie_definition.wells_to_track, 1)
            row_id = movie_definition.wells_to_track(i, 1);
            col_id = movie_definition.wells_to_track(i, 2);
            site_id = movie_definition.wells_to_track(i, 3);
            new_variable{i} = old_variable{row_id, col_id, site_id};
        end
        
    case 'a2m'
        new_variable = cell(movie_definition.plate_def);
        for i=1:size(movie_definition.wells_to_track, 1)
            row_id = movie_definition.wells_to_track(i, 1);
            col_id = movie_definition.wells_to_track(i, 2);
            site_id = movie_definition.wells_to_track(i, 3);
            new_variable{row_id, col_id, site_id} = old_variable{i};
        end
        
    otherwise
        error('convert_matrix_seq: unknown option');
end

end