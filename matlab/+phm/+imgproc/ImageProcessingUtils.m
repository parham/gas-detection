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