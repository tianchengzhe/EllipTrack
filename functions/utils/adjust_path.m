function [ new_path ] = adjust_path ( old_path, varargin )
%ADJUST_PATH Adjust the path of files such that the code can be used in
%both windows and mac platforms
%
%   Input
%       old_path: Path before adjustment
%   Output
%       new_path: Path after adjustment

if isempty(old_path) % empty path
    new_path = old_path;
elseif iscell(old_path) % recursive execution for cell arrays
    new_path = cell(size(old_path));
    for i=1:length(old_path)
        new_path{i} = adjust_path(old_path{i}); % not used by GUI. OK to generate folders.
    end
else % normal path
    new_path = strrep(old_path, '\', '/');
    if ((~strcmpi(new_path(max(end-3,1):end), '.mat') && ~strcmpi(new_path(max(end-1,1):end), '.m')) && new_path(end)~='/')
        new_path = cat(2, new_path, '/');
        if (nargin == 1 || varargin{1})
            if ~exist(new_path, 'dir') % make directory if not exist
                mkdir(new_path);
            end
        end
    end
end

end