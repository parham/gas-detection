classdef msv2BlendingStep < phm.core.phmCore
    %MSV2BLENDINGSTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        currentOutput
    end
    
    methods
        function obj = msv2BlendingStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.currentOutput = [];
        end
        
        function [result] = process (obj, frame)
            t = cputime;
            if isempty(obj.currentOutput)
                obj.currentOutput = struct;
                obj.currentOutput.Frame = frame.WarppedFrame;
                obj.currentOutput.Mask = frame.BlendMask;
            else
                frm = frame.WarppedFrame;
                if strcmp(obj.operation,'EdgedOrientedOverwrite')
                    [obj.currentOutput.Mask, pos] = max(cat(3,obj.currentOutput.Mask,frame.BlendMask), [], 3);
                    obj.currentOutput.Frame(pos == 2) = frm(pos == 2);
                elseif strcmp(obj.operation,'WeightedBlend')
%                     [obj.currentOutput.Mask, pos] = max(cat(3,obj.currentOutput.Mask,frame.BlendMask), [], 3);
                    div = obj.currentOutput.Mask + frame.BlendMask;
                    tmp = ((obj.currentOutput.Frame .* obj.currentOutput.Mask) + ...
                        (frm .* frame.BlendMask)) ./ div;
                    res = obj.currentOutput.Frame;
                    res(obj.currentOutput.Mask ~= 0) = obj.currentOutput.Frame(obj.currentOutput.Mask ~= 0);
                    res(obj.currentOutput.Mask == 0 & frame.BlendMask ~= 0) = ...
                        frm(obj.currentOutput.Mask == 0 & frame.BlendMask ~= 0);
                    res(obj.currentOutput.Mask ~= 0 & frame.BlendMask ~= 0) = ...
                        tmp(obj.currentOutput.Mask ~= 0 & frame.BlendMask ~= 0);
                    obj.currentOutput.Frame = res;
                    obj.currentOutput.Mask = div;
                    obj.currentOutput.Mask(div > 1) = 1;
                end
            end
            
            result = obj.currentOutput;
            obj.lastExecutionTime = cputime - t;
        end
    end
end
