classdef phmSystemUtils
    %PHMSYSTEMCHECK Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = phmSystemCheck()
            % Empty body
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

