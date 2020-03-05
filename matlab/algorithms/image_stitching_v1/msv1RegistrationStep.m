classdef msv1RegistrationStep < phm.core.phmCore

    properties
        Property1
    end
    
    methods
        function obj = msv1RegistrationStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function [result, status] = process (obj, frame)
            t = cputime;
            
            obj.lastExecutionTime = cputime - t;
        end
    end
end

