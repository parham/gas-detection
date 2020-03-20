classdef glv1FrameDisplacementFromOrigin < phm.core.phmCore

    properties
        groundTruth
    end
    
    methods
        function obj = glv1FrameDisplacementFromOrigin()
            obj = obj@phm.core.phmCore();
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.groundTruth = [];
        end
        
        function result = process (obj, frame)
            t = cputime;
            if isempty(obj.groundTruth)
                obj.groundTruth = frame;
            end
            result = frame - obj.groundTruth;
            obj.lastExecutionTime = cputime - t;
        end
    end
end

