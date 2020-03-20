
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef ROICropper < phm.core.phmCore
    
    properties
        doesInitialize
    end
    
    methods
        function obj = ROICropper(varargin)
            obj = obj@phm.core.phmCore(varargin);
            obj.reset();
        end
        
        function [] = reset (obj)
            reset@phm.core.phmCore(obj);
            obj.doesInitialize = false;
        end
        
        function [] = guiInitialize (obj, frame)
            figure('Name', 'Select Region of Interest (ROI)');
            imshow(frame, []);
            roi = drawrectangle();
            % Create a binary image ("mask") from the ROI object.
%             mask = roi.createMask();
            roi = floor(roi.Position());
            obj.position(1) = roi(1);
            obj.position(2) = roi(2);
            obj.size(1) = roi(3);
            obj.size(2) = roi(4);
            obj.doesInitialize = true;
%             cropped = imcrop(frame,roi);
        end
        
        function result = process (obj, frame)
            if ~obj.doesInitialize && obj.guiInit
                obj.guiInitialize(frame);
            end
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

