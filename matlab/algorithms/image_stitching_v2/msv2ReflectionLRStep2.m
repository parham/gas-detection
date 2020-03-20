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
            if isempty(obj.reflectionMask)
                obj.reflectionMask = zeros(size(frame.WarppedFrame));
            else
                frms = [obj.previousFrame; frame];
                confrm = cat(3,frms.WarppedFrame);
                mask = obj.previousFrame.WarppedMask .* ...
                frame.WarppedMask;
            
                tmp = reshape(confrm,[],size(confrm,3));
                tmp = mat2cell(tmp,ones(1,size(tmp,1)),size(tmp,2));
                tmp = reshape(tmp, [size(confrm,1), size(confrm,2)]);
                tmp = cellfun(@(x) std(nonzeros(x)), tmp, 'UniformOutput', false);
                msk = cellfun(@isempty, tmp);
                tmp(msk == 1) = {[0]};
                tmp = cell2mat(tmp);
                tmp(isnan(tmp)) = 0;
                tmp = tmp .* mask; %mat2gray();
                intValue = (max(tmp(:)) - min(tmp(:))) * obj.intersecThreshold;
                tmp(tmp < intValue) = 0;
                tmp = imbinarize(tmp);
                
                obj.previousFrame = frame;
                obj.reflectionMask = cat(3, obj.reflectionMask, tmp);
            end
            
            obj.previousFrame = frame;
            tmpCount = obj.reflectionMask;
            tmpCount(tmpCount ~= 0) = 1;
            result = sum(obj.reflectionMask, 3) ./ sum(tmpCount,3);
            result(isnan(result)) = 0;
        end
        
    end
end

