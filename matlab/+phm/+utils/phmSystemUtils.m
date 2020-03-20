classdef phmSystemUtils
    %PHMSYSTEMCHECK Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = phmSystemUtils()
            % phmSystemUtils constructor
            % Empty body
        end
    end
    
    methods(Access = public)
        function [flist] = list_files(dirPath,fileExt)
            %LIST_IMAGES_FILES lists all files with the determined expension.
            % dirPath: the parent directory that keeps the files.
            % fileExt: the targeted file extension.
            % Return: the function returns the list of files ended with the determined file
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
        
        function [] = imds2png(sourcePath, ffilter, desPath, prefunc)
            %PHMTIFF2PNG The function read all the tiff images in a directory and then
            %write them as PNG file in the destination directory

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

    end
    
    methods(Static)
        function [CVSTStatus] = checkCVLicense ()
            % Check for license to Computer Vision Toolbox
            CVSTStatus = license('test','Video_and_Image_Blockset');
        end

        function name = getOSUser ()
            if isunix()
            name = getenv('USER'); 
            else 
            name = getenv('username'); 
            end
        end
    end
end

