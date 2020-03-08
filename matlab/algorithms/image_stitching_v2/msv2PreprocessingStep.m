classdef msv2PreprocessingStep < phm.core.phmCore
    % PreprocessingSteps All preprocessing steps required for the stitching
    % algorithm

    properties
        previousFrame
    end
    
    methods
        % Constructor
        function obj = msv2PreprocessingStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.previousFrame = [];
        end
        
        function result = process (obj, frame)
            t = cputime;
            if size(frame,3) ~= 1
                result = mean(frame,3);
            else
                result = frame;
            end
            result = double(mat2gray(result));
            frameHeight = size(frame,1);
            scaleRatio = obj.heightBound / frameHeight;
            result = imresize(result, scaleRatio, obj.resizeMethod);
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
