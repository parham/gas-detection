classdef msv2RegistrationStep < phm.core.phmCore
    
    properties
        StitchedFrame,
        StitchedMask
    end
    
    methods
        function obj = msv2RegistrationStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.StitchedFrame = [];
            obj.StitchedMask = [];
        end
        
        function [result, frames] = preprocess (obj, frames)
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
            
            % Merging
            maxH = 0;
            minH = 0;
            maxW = 0;
            minW = 0;
            
            % Update the frame's transformation matrix
            for index = 1:length(frames)
                frames{index}.AbsoluteTransformation.T(2, 3) = ... 
                    frames{index}.AbsoluteTransformation.T(2, 3) - floor(minX);
                frames{index}.AbsoluteTransformation.T(1, 3) = ... 
                    frames{index}.AbsoluteTransformation.T(1, 3) - floor(minY);
                
                pPrime = frames{index}.AbsoluteTransformation.T * [1; 1; 1];
                pPrime = pPrime ./ pPrime(3);
                baseH = floor(pPrime(1));
                baseW = floor(pPrime(2));
                
                maxH = max(maxH, baseH);
                minH = min(minH, baseH);
                maxW = max(maxW, baseW);
                minW = min(minW, baseW);
                
                frames{index}.Frame = im2double(frames{index}.Frame);
            end
            
            tmp = frames{1}.Frame;
            result.baseDimension = [minW minH; maxW maxH];
            obj.StitchedFrame = zeros(result.stitchedSize, 'like', tmp);
            obj.StitchedMask = zeros(result.stitchedSize, 'like', tmp);
        end
        
        function [frame] = process (obj, frame, envConfig)
            t = cputime;
            pPrime = frame.AbsoluteTransformation.T * ...
                [envConfig.baseDimension(2,1) + 10; envConfig.baseDimension(1,1) + 10; 1];
            pPrime = pPrime ./ pPrime(3);
            baseH = floor(pPrime(1));
            baseW = floor(pPrime(2));
            if baseH == 0
                baseH = 1;
            end
            if baseW == 0
                baseW = 1;
            end
            % Keep thermal data
            frame.TransformedFrame = zeros(envConfig.stitchedSize, 'like', frame.Frame);
            frame.TransformedMask = zeros(envConfig.stitchedSize, 'like', frame.Frame);
            
            width = envConfig.imageSize(2);
            height = envConfig.imageSize(1);
            frame.TransformedFrame(baseH:baseH+height-1, baseW:baseW+width-1) = frame.Frame;

            obj.lastExecutionTime = cputime - t;
        end
    end
end