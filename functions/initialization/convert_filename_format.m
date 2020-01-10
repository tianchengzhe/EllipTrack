function [ filename_format, image_info_order ] = convert_filename_format( movie_definition )
%CONVERT_FILENAME_FORMAT Convert filename_format
%
%   Input
%       movie_definition: Parameters defining the movie
%   Output
%       filename_format: Converted filename format
%       image_info_order: Order of information for sprintf

% find % in filename format
filename_format = movie_definition.filename_format;
identifier_pos = strfind(filename_format, '%');
num_identifier = length(identifier_pos);
image_info_order = nan(num_identifier, 1);
identifier_pos = [identifier_pos, length(filename_format)+1];

% iterate over every %
for i=1:num_identifier
    temp = filename_format(identifier_pos(i):identifier_pos(i+1)-1);
    first_letter_pos = find(isletter(temp), 1);
    if (isempty(first_letter_pos))
        error('convert_filename_format: filename format is not valid.');
    end
    
    switch lower(temp(first_letter_pos))
        case 'r' % row, numeric
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'd';
            image_info_order(i) = 1;
        case 'a' % row, alphabet
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'c';
            image_info_order(i) = 7;
        case 'b' % row, alphabet, CAP
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'c';
            image_info_order(i) = 8;
        case 'c' % column, numeric
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'd';
            image_info_order(i) = 2;
        case 's' % site, numeric
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'd';
            image_info_order(i) = 3;
        case 'i' % channel id, numeric
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'd';
            image_info_order(i) = 4;
        case 'n' % channel name, string
            filename_format(identifier_pos(i)+first_letter_pos-1) = 's';
            image_info_order(i) = 6;
        case 't' % frame, numeric
            filename_format(identifier_pos(i)+first_letter_pos-1) = 'd';
            image_info_order(i) = 5;
        otherwise
            error('convert_filename_format: filename format is not valid.');
    end
end

% examine whether filename_format match image type
if strcmpi(movie_definition.image_type, 'nd2')
    if any(ismember(image_info_order, 3:6))
        error('convert_filename_format: filename format is not valid. Only Row ID (number or letter) and Column ID are allowed for ND2 format.');
    end
elseif strcmpi(movie_definition.image_type, 'stack')
    if any(ismember(image_info_order, 5))
        error('convert_filename_format: filename format is not valid. Frame ID is not allowed for image stacks.');
    end
elseif strcmpi(movie_definition.image_type, 'gui')
    if ~isempty(find(image_info_order~=5, 1))
        error('convert_filename_format: filename format is not valid. Only Frame ID is allowed for Training Data GUI.');
    end
end

end