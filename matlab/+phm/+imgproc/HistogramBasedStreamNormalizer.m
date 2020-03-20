
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef HistogramBasedStreamNormalizer < phm.core.phmCore

    properties
        previousFrame
    end
    
    methods
        function obj = HistogramBasedStreamNormalizer(varargin)
            obj = obj@phm.core.phmCore(varargin);
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

