
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef ImageResizer < phm.core.phmCore
    
    methods
        function obj = ImageResizer(varargin)
            obj = obj@phm.core.phmCore(varargin);
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

