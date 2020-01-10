function [ new_variable ] = convert_accu_jitters( movie_definition, old_variable )
%CONVERT_ACCU_JITTERS Convert accumulated jitters for parallel computing
%
%   Input
%       movie_definition: Parameters defining the movie
%       old_variable: Variable before conversion
%   Output
%       new_variable: Variable after conversion

new_variable = cell(size(movie_definition.wells_to_track, 1), 1);
for i=1:size(movie_definition.wells_to_track, 1)
    row_id = movie_definition.wells_to_track(i, 1);
    col_id = movie_definition.wells_to_track(i, 2);
    new_variable{i} = squeeze(old_variable(row_id, col_id, :, :));
end

end