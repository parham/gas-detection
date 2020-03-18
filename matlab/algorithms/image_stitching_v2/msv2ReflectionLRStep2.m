classdef msv2ReflectionLRStep2 < phm.core.phmCore
   
    properties
        previousFrame,
        reflectionMask
    end
    
    methods
        function obj = msv2ReflectionLRStep2(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.previousFrame = [];
            obj.reflectionMask = [];
        end
        
        function [result] = process (obj, frame)
            result = struct;
            if isempty(obj.previousFrame)
                obj.previousFrame = frame;
                obj.reflectionMask = zeros(size(frame.WarppedFrame));
                result.Result = frame.WarppedFrame;
                result.ReflectionArea = obj.reflectionMask;
                return;
            end
            
            frms = [obj.previousFrame; frame];
            
            confrm = cat(3,frms.WarppedFrame);
            conmsk = cat(3,frms.BlendMask);
            confrm(conmsk <= obj.intersecThreshold) = 0;
            
            pixarr = reshape(confrm,[],size(confrm,3));
            pixarr = mat2cell(pixarr,ones(1,size(pixarr,1)),size(pixarr,2));
            pixarr = reshape(pixarr, [size(confrm,1), size(confrm,2)]);
            pixarr = cellfun(@nonzeros, pixarr, 'UniformOutput', false);
            
            pixmask = cellfun(@std, pixarr, 'UniformOutput', false);
            msk = cellfun(@isempty, pixmask);
            pixmask(msk == 1) = {[0]};
            pixmask = cell2mat(pixmask);
            pixmask(isnan(pixmask)) = 0;
            pixmask = mat2gray(pixmask);

%             % Threshold image - global threshold
%             BW = imbinarize(pixmask, 'adaptive');
            
            prorg = cellfun(@min, pixarr, 'UniformOutput', false);
            msk = cellfun(@isempty, prorg);
            prorg(msk == 1) = {0};
            prorg = cell2mat(prorg);
            prorg(isnan(pixmask)) = 0;

            obj.previousFrame = frame;
            obj.reflectionMask = cat(3, obj.reflectionMask, pixmask);
            
            tmpCount = obj.reflectionMask;
            tmpCount(tmpCount ~= 0) = 1;
            tmp = sum(obj.reflectionMask,3) ./ sum(tmpCount,3);
            
            result = struct('Result', prorg, 'ReflectionArea', tmp);
        end
    end
end

