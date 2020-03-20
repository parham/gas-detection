classdef ROICropper < phm.core.phmCore
    
    methods
        function obj = ROICropper(configs)
            obj = obj@phm.core.phmCore(configs);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
        end
        
        function [roi, mask, cropped] = guiInitialize (obj, frame)
            figure('Name', 'Select Region of Interest (ROI)');
            imshow(frame, []);
            roi = drawrectangle();
            % Create a binary image ("mask") from the ROI object.
            mask = roi.createMask();
            roi = roi.Position();
            cropped = imcrop(frame,roi);
        end
        
        function result = process (obj, frame)
            t = cputime;
            if obj.state
                x = obj.position(1);
                y = obj.position(2);
                w = obj.size(1);
                h = obj.size(2);
                result = frame(y:y+h,x:x+w,:);
            else
                result = frame;
            end
            obj.lastExecutionTime = cputime - t;
        end
    end
end

