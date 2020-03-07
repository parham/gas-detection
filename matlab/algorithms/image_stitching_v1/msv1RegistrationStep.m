classdef msv1RegistrationStep < phm.core.phmCore
    
    properties
        stitchedResult,
        blenderObj
    end
    
    methods
        function obj = msv1RegistrationStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.stitchedResult = [];
            obj.blenderObj = vision.AlphaBlender('Operation', ...
                'Binary mask', 'MaskSource', 'Input port'); 
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
                frames{index}.Transformation.T(2, 3) = ... 
                    frames{index}.Transformation.T(2, 3) - floor(minX);
                frames{index}.Transformation.T(1, 3) = ... 
                    frames{index}.Transformation.T(1, 3) - floor(minY);                
            end
        end
        
        function [result, frame] = process (obj, frame, envConfig)
            t = cputime;
            
            if isempty(obj.stitchedResult)
                obj.stitchedResult = zeros(envConfig.stitchedSize, 'like', frame.Frame(:,:,1));
            end
            
            frame.RegisteredMask = imwarp(true(size(frame.Frame,1), ...
                size(frame.Frame,2)), frame.AbsoluteTransformation, ...
                    'OutputView', envConfig.worldRef2d);
            frame.RegisteredImage = imwarp(frame.Frame, frame.Ref2d, ...
                frame.AbsoluteTransformation, 'OutputView', ...
                    envConfig.worldRef2d, 'SmoothEdges', obj.smoothEdge);
            obj.stitchedResult = step(obj.blenderObj, obj.stitchedResult, ...
                frame.RegisteredImage, frame.RegisteredMask);
            result = obj.stitchedResult;
                
            obj.lastExecutionTime = cputime - t;
        end
    end
end