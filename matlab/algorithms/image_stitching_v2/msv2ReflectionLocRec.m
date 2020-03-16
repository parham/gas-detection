classdef msv2ReflectionLocRec < phm.core.phmCore
   
    properties
        flowObj
    end
    
    methods
        function obj = msv2ReflectionLocRec(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            reset(obj.flowObj);
        end
        
        function [result] = process (obj, frames)
            obj.flowObj = opticalFlowFarneback(...
                'NumPyramidLevels', obj.pyramidLevel, ...
                'PyramidScale', obj.pyramidScale,...
                'NumIterations', obj.iteration, ...
                'NeighborhoodSize', obj.neighborSize, ...
                'FilterSize', obj.filterSize);
            
            conmax = zeros([size(frames{1}.WarppedFrame,2), size(frames{1}.WarppedFrame,1), length(frames)];
            for index = 1:length(frames)-1
                first = frames{index};
                second = frames{index+1};
                intersec = first.BlendMask .* second.BlendMask;
                intersec(intersec > obj.intersecThreshold) = 1;
                
            end
        end
    end
end

