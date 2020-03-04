function [] = imds2png(sourcePath, ffilter, desPath, prefunc)
%PHMTIFF2PNG The function read all the tiff images in a directory and then
%write them as PNG file in the destination directory
%   Detailed explanation goes here

if ~isa(prefunc, 'function_handle') && ~isempty(prefunc)
    error('prefunc must be a function reference that has atleast one argument that accept image');
end

if isempty(sourcePath) || ~isfolder(sourcePath)
    error('sourcePath is invalid. The path must refer to a directory');
end

% In case the destination path is empty, the output images will be saved in
% the source path.
if isempty(desPath)
    desPath = sourcePath;
end

if ~isfolder(desPath)
    error('desPath is invalid.');
end

flist = list_files(sourcePath, ffilter);
if isempty(flist)
    error('There is no file to read');
end

for index = 1:length(flist)
    fpath = flist{index};
    if ~isfile(fpath)
        continue;
    end
    
    info = imfinfo(fpath);
    if strcmp(info.Format, 'tif') && numel(info) > 1
        error(['This function only supports single page tiff files --> ', fpath])
    end
    
    % Read the image
    warning('off','all')
    orig = imread(flist{index});
    % Adjust the contrast to span it to all range
    warning('on','all')
    if isempty(prefunc)
        res = orig;
    else
        res = prefunc(orig);
    end
        
    [~, fname] = fileparts(fpath);
    ftPath = fullfile(desPath, strcat(fname, '.png'));
    imwrite(res, ftPath);
end


end

