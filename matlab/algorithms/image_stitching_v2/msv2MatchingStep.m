classdef msv2MatchingStep < phm.core.phmCore
   
    properties
        previousFrame
    end
    
    methods
        function obj = msv2MatchingStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function [result, status] = process (obj, frame)
            % 
            % OUTPUT FIELDS:
            % Frame: input frame
            % Ref2d: Reference 2d coordinate
            % Transformation : the projective transformation
            % AbsoluteTransformation: The global transformation
            t = cputime;
            status = 0;
            
            tmp = struct;
            tmp.Frame = frame;
            tmp.WarppedFrame = frame;
            tmp.WarppedMask = ones(size(frame), 'like', frame);
            tmp.Ref2d = imref2d(size(frame));
            tmp.Transformation = projective2d;
            tmp.AbsoluteTransformation = projective2d;
            % Calculate features and descriptors
            imgtmp = im2single(frame);
            [tmp.Features, tmp.Descriptors] = ... 
                vl_sift(imgtmp, 'EdgeThresh', obj.edgeThresh);
            
            if isempty(obj.previousFrame)
                obj.previousFrame = tmp;
            else
                % Match two consecutive frames using features
                [matches, scores] = vl_ubcmatch( ...
                    obj.previousFrame.Descriptors, tmp.Descriptors);
                % Find pairs
                firstPairs = obj.previousFrame.Features(1:2,matches(1,:));
                secondPairs = tmp.Features(1:2,matches(2,:));
                % Calculate the transformation
                [tmp.Transformation, ~, ~, status] = estimateGeometricTransform(secondPairs', firstPairs', obj.transformType);
                if status == 0
                    % Incrementally calculate general translation
                    tmp.AbsoluteTransformation.T = ...
                        obj.previousFrame.AbsoluteTransformation.T * ...
                            tmp.Transformation.T;
                    reftmp = tmp.Ref2d;
                    [tmp.WarppedFrame, tmp.Ref2d] = imwarp(tmp.WarppedFrame, reftmp, tmp.AbsoluteTransformation);
                    [tmp.WarppedMask, tmp.Ref2d] = imwarp(tmp.WarppedMask, reftmp, tmp.AbsoluteTransformation);
                else
                    warning('the transformation is not valid or not accurate enough');
                end
            end
            
            result = tmp;
            obj.previousFrame = tmp;
            obj.lastExecutionTime = cputime - t;
        end
    end
end

