classdef msv2ReflectionLRStep < phm.core.phmCore
   
    properties
        flowObj
    end
    
    methods
        function obj = msv2ReflectionLRStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            reset(obj.flowObj);
        end
        
        function [result] = process (obj, matches)
            if iscell(matches)
                frms = cell2mat(matches);
            else
                frms = matches;
            end
            
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
            % Threshold image - global threshold
            BW = imbinarize(pixmask, 'adaptive', 'Sensitivity',0.4);
            
            prorg = cellfun(@min, pixarr, 'UniformOutput', false);
            msk = cellfun(@isempty, prorg);
            prorg(msk == 1) = {0};
            prorg = cell2mat(prorg);

            result = struct('Result', prorg, 'ReflectionArea', BW);
            
        end
    end
end

