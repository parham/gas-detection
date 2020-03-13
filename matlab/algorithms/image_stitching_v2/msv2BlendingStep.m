classdef msv2BlendingStep < phm.core.phmCore
    %MSV2BLENDINGSTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj = msv2BlendingStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function [result, overlapped] = process (obj, frames)
            t = cputime;

            result = frames{1}.WarppedFrame;
            for index = 2:length(frames)
                frm = frames{index}.WarppedFrame;
                msk = frames{index}.WarppedMask;
                edMask = edge(a.WarppedMask,'Prewitt');
                edMask = imdilate(edMask, strel('disk',10));
                edMask = imgaussfilt(double(edMask),11);
                edMask(msk == 0) = 0;
                edMask(msk ~= 0) = 1 - edMask(msk ~= 0);
            end
            
%             res = frames{1}.WarppedFrame;
%             resMask = frames{1}.WarppedMask;
%             for index = 2:length(frames)
%                 frm = frames{index}.WarppedFrame;
%                 msk = frames{index}.WarppedMask;
%                 res = cat(3,res, frm);
%                 resMask = cat(3,resMask,msk);
%             end
%             
%             [result, overlapped] = reflection_dr(res, resMask);
            obj.lastExecutionTime = cputime - t;
        end
    end
end

