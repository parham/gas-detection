classdef HistogramBasedStreamNormalizer < phm.core.phmCore

    properties
        previousFrame
    end
    
    methods
        function obj = HistogramBasedStreamNormalizer(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.previousFrame = [];
        end
        
        function result = process (obj, frame)
            t = cputime;
            result = frame;
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

