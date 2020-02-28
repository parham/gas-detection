classdef glv1Preprocessing < phm.core.phmCore
    %GLPREPROCESSING Summary of this class goes here
    %   Detailed explanation goes here

    properties
        previousFrame
    end
    
    methods
        function obj = glv1Preprocessing(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.previousFrame = [];
        end
        
        function result = process (obj, frame)
            t = cputime;
            if size(frame,3) > 1
                result = mean(frame,3);
            else
                result = frame;
            end
            result = double(mat2gray(result));
            
            if ~isempty(obj.previousFrame)
                % Correct illumination differences between the moving and fixed images
                % using histogram matching. This is a common pre-processing step.
                result = imhistmatch(result, obj.previousFrame);
            end
            
            obj.previousFrame = result;
            obj.lastExecutionTime = cputime - t;
        end
    end
end

