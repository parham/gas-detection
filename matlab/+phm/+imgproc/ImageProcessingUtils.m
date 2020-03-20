
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef ImageProcessingUtils
    %IMAGEPROCESSINGUTILS Utilies to be used in projects
    
    methods
        function obj = ImageProcessingUtils()
            % Empty body
        end
    end
    
    methods(Static)
        function result = normalizeAndMakingDouble(img)
            result = double(mat2gray(img));
        end
    end
end
