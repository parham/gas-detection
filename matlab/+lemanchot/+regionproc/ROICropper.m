classdef ROICropper < matlab.System & ...
    lemanchot.configuration.YamlConfigurable
    % ROICropper crop the region of interests
    %

    % Public, non-tunable properties
    properties(Nontunable)
        position,
        size
    end

    methods
        % Constructor
        function obj = ROICropper(varargin)
            obj = obj@lemanchot.configuration.YamlConfigurable( ...
                cat(2, varargin, 'ConfigFileSection', 'roi_crop', ...
                    'DefaultConfigFilePath', './+lemanchot/+imgproc/roi_cropper.yaml'));
            
            if isprop(obj, 'position') && iscell(obj.position)
                obj.position = reshape(cell2mat(obj.position), [], 2);
            end
            
            if isprop(obj, 'size') && iscell(obj.size)
                obj.size = reshape(cell2mat(obj.size), [], 2);
            end
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            if ~isprop(obj, 'position')
                obj.position = [];
            end
            if ~isprop(obj, 'size')
                obj.size = [];
            end
        end

        function [result, exeTime] = stepImpl(obj,frame)
            t = cputime;
            x = obj.position(1);
            y = obj.position(2);
            w = obj.size(1);
            h = obj.size(2);
            result = frame(y:y+h,x:x+w,:);
            exeTime = cputime - t;
        end

        function resetImpl(obj)
            % empty body
        end

        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.position =  obj.position;
                s.size = obj.size;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.position =  s.position;
                obj.size =  s.size;
            end
            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct('position', obj.position, ... 
                'size', obj.size);
        end

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function flag = isInactivePropertyImpl(obj,prop)
            % Return false if property is visible based on object 
            % configuration, for the command line and System block dialog
            flag = false;
        end
    end
end
