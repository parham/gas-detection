classdef glv1ROICropper < phm.core.phmCore
    %GLV1ROICROPPER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = glv1ROICropper(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function result = process (obj, frame)
            t = cputime;
            if obj.state
                x = obj.position(1);
                y = obj.position(2);
                w = obj.size(1);
                h = obj.size(2);
                result = frame(y:y+h,x:x+w,:);
            else
                result = frame;
            end
            obj.lastExecutionTime = cputime - t;
        end
    end
end

