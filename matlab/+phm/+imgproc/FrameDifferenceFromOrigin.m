
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef FrameDifferenceFromOrigin < phm.core.phmCore    

    properties
        groundTruth
    end
    
    methods
        function obj = FrameDifferenceFromOrigin(varargin)
            obj = obj@phm.core.phmCore(varargin);
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

