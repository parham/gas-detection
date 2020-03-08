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
        
        function [result] = process (obj, frame)
            % 
            % OUTPUT FIELDS:
            % Frame: input frame
            % Ref2d: Reference 2d coordinate
            % Transformation : the projective transformation
            % AbsoluteTransformation: The global transformation
            t = cputime;
            
            tmp = struct;
            tmp.Frame = frame;
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
                numMatches = size(matches,2);
                % Find pairs
                pairs = nan(numMatches, 3, 2);
                pairs(:,:,1) = [ ...
                    obj.previousFrame.Features(2,matches(1,:)) ; ...
                    obj.previousFrame.Features(1,matches(1,:)) ; ...
                    ones(1,numMatches)]';
                pairs(:,:,2) = [ ...
                    tmp.Features(2,matches(2,:)); ...
                    tmp.Features(1,matches(2,:)); ...
                    ones(1,numMatches)]';
                % Calculate the transformation
                [tmp.Transformation.T, ~] = phm.geometry.RANSAC(obj.confidence, obj.inlierRatio, 1, pairs, obj.epsilon);
                % Incrementally calculate general translation
                tmp.AbsoluteTransformation.T = ...
                    obj.previousFrame.AbsoluteTransformation.T * ...
                        tmp.Transformation.T;
            end
            
            result = tmp;
            obj.previousFrame = tmp;
            obj.lastExecutionTime = cputime - t;
        end
    end
end

