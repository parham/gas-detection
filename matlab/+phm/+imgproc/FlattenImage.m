
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef FlattenImage < phm.core.phmCore
    
    methods
        function obj = FlattenImage(varargin)
            obj = obj@phm.core.phmCore(varargin);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function result = process (obj, frame)
            t = cputime;
            if size(frame,3) == 3
                result = rgb2gray(frame);
            elseif size(frame,3) ~= 1
                result = mean(frame,3);
            else
                result = frame;
            end
            obj.lastExecutionTime = cputime - t;
        end
    end
end

