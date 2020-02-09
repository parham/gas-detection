function [] = checkExistAndLicensed(toolname)
%CHECKEXISTANDLICENSED Check the tool exists and licensed
    
    % For example: 'Video_and_Image_Blockset'

    % Check Computer Vision Toolbox license
    % Check for license to Computer Vision Toolbox
    CVSTStatus = license('test',toolname);
    if ~CVSTStatus
        error([toolname, ' does not exist or is not licensed!']);
    end

end

