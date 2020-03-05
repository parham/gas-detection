classdef msv1MatchingStep < phm.core.phmCore
   
    properties
        previousFrame
    end
    
    methods
        function obj = msv1MatchingStep(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function [result, status] = process (obj, frame)
            t = cputime;
            
            tmp = struct;
            tmp.Frame = frame;
            tmp.Ref2d = imref2d(size(frame));
            tmp.Features = ...
                detectSURFFeatures(frame, ...
                    'MetricThreshold', obj.metricThreshold, ...
                    'NumOctaves', obj.numOctave, ...
                    'NumScaleLevels', obj.scaleLevel);
            [tmp.Descriptors, tmp.ValidPoints] = ...
                extractFeatures(frame, ...
                    tmp.Features, 'Upright', false);
            
            status = 0;
            currentFrame = tmp;
            if ~isempty(obj.previousFrame)
                indexPairs = matchFeatures(obj.previousFrame.Descriptors, ...
                    currentFrame.Descriptors, ...
                    'MatchThreshold', obj.matchThreshold, ...
                    'MaxRatio',obj.maxRatio);
                obj.previousFrame.SelectedFeatures = obj.previousFrame.ValidPoints(indexPairs(:,1));
                currentFrame.SelectedFeatures = currentFrame.ValidPoints(indexPairs(:,2));
                % Apply transformation - Results may not be identical between runs 
                % because of the randomized nature of the algorithm.
                [currentFrame.Transformation, ~, ~, status] = estimateGeometricTransform( ...
                    currentFrame.SelectedFeatures, ...
                    obj.previousFrame.SelectedFeatures, obj.transformType);
            end
            % Calculate global transformation matrix
            if ~isempty(obj.previousFrame) && status == 0
                if isfield(obj.previousFrame, 'AbsoluteTransformation')
                    ptrans = obj.previousFrame.AbsoluteTransformation.T;
                    ctrans = currentFrame.Transformation.T;
                    currentFrame.AbsoluteTransformation = obj.previousFrame.AbsoluteTransformation;
                    currentFrame.AbsoluteTransformation.T = ptrans * ctrans;
                else
                    currentFrame.AbsoluteTransformation = currentFrame.Transformation;
                end
            end
            
            result = currentFrame;
            obj.previousFrame = currentFrame;
            obj.lastExecutionTime = cputime - t;
        end
    end
end

