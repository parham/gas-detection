classdef msv2RegistrationStep < phm.core.phmCore
    
    methods
        function obj = msv2RegistrationStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function [result, frames] = preprocess (~, frames)
            result = struct;
            
            % Initialize Frame size
            result.imageSize = [size(frames{1}.Frame,1), size(frames{1}.Frame,2)];
            
            trans = cellfun(@(x) double(x.AbsoluteTransformation.T), frames, 'UniformOutput', false);
            trans = cat(3,trans{:});
            
            width = result.imageSize(2);
            height = result.imageSize(1);
            minY = min(1,min(trans(1,3,:)));
            minX = min(1,min(trans(2,3,:)));
            maxY = max(height,max(trans(1,3,:) + height));
            maxX = max(width,max(trans(2,3,:) + width));
            
            % Create a 2-D spatial reference object defining the size of the panorama.
            result.worldXLimits = [minX maxX];
            result.worldYLimits = [minY maxY];
            stitchedHeight = ceil(maxY) - floor(minY) + 1;
            stitchedWidth = ceil(maxX) - floor(minX) + 1;
            result.stitchedSize = [stitchedHeight + 120, stitchedWidth + 120];
            result.worldRef2d = imref2d([stitchedHeight + 120, stitchedWidth + 120], ...
                result.worldXLimits, result.worldYLimits);
            
            % Update the frame's transformation matrix
            for index = 1:length(frames)
                frames{index}.AbsoluteTransformation.T(2, 3) = ... 
                    frames{index}.AbsoluteTransformation.T(2, 3) - floor(minX);
                frames{index}.AbsoluteTransformation.T(1, 3) = ... 
                    frames{index}.AbsoluteTransformation.T(1, 3) - floor(minY);                
            end
            
            % Merging
            maxH = 0;
            minH = 0;
            maxW = 0;
            minW = 0;
            
            for index = 1:length(frames)
                pPrime = absTrans(:,:,i) * [1;1;1];
                pPrime = pPrime ./ pPrime(3);
                baseH = floor(pPrime(1));
                baseW = floor(pPrime(2));
                if baseH > maxH
                    maxH = baseH;
                end
                if baseH < minH
                    minH = bashH;
                end
                if baseW > maxW
                    maxW = baseW;
                end
                if baseW < minW
                    minW = baseW;
                end
            end
            
        end
        
        function [result, frame] = process (obj, frame, envConfig)
            t = cputime;
            
            if isempty(obj.stitchedResult)
                obj.stitchedResult = zeros(envConfig.stitchedSize, 'like', frame.Frame(:,:,1));
            end
            
            img = im2double(frame.Frame);
            % Create the mask
%             mask = ones(height, width);
%             mask = warp(mask, focal);
%             mask = imcomplement(mask);
%             mask = bwdist(mask, 'euclidean');
%             mask = mask ./ max(max(mask));
            mask = nan(envConfig.imageSize); 
            
            
            obj.lastExecutionTime = cputime - t;
        end
    end
end