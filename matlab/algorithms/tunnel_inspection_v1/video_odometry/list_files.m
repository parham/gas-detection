function [flist] = list_files(dirPath,fileExt)
%LIST_IMAGES_FILES lists all files with the determined expension.
% dirPath: the parent directory that keeps the files.
% fileExt: the targeted file extension.
% the function returns the list of files ended with the determined file
% extension.

% Make the filter to list the files.
flist = fullfile(dirPath, fileExt);
% List of all files with the determined file extension. The list includes
% "." and ".." paths.
fpaths = dir(flist);
files = {fpaths(:).name};

% Check for the directories
is_dir = isfolder(files);
files = files(is_dir == 0);
% Prepare the path array for all included image
flist = fullfile(dirPath,files);
if isempty(flist)
    error('There is no file to read in this directory.');
end

end