classdef ImageResizer < phm.core.phmCore
    
    methods
        function obj = ImageResizer(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function result = process (obj, frame)
            t = cputime;
            result = imresize(frame, obj.imgSize, obj.resizeMethod);
            obj.lastExecutionTime = cputime - t;
        end
    end
end

