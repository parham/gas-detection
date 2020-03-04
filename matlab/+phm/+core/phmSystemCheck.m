classdef phmSystemCheck
    %PHMSYSTEMCHECK Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = phmSystemCheck()
            % Empty body
        end
    end
    
    methods(Static)
        function [res] = checkCVLicense ()
            % Check for license to Computer Vision Toolbox
            progressbar.textprogressbar('Check Computer Vision Toolbox license: ');
            CVSTStatus = license('test','Video_and_Image_Blockset');
            progressbar.textprogressbar(100);
            if ~CVSTStatus
        %         error(message('images:imageRegistration:CVSTRequired'));
                progressbar.textprogressbar(' failed');
                res = false;
            else
                progressbar.textprogressbar(' passed');
                res = true;
            end
        end
    end
end

