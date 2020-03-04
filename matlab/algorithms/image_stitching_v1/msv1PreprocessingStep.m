classdef PreprocessingSteps < matlab.System & ...
        lemanchot.configuration.YamlConfigurable
    % PreprocessingSteps All preprocessing steps required for the stitching
    % algorithm (version 1)

    % Public, tunable properties
    properties

    end

    % Public, non-tunable properties
    properties(Nontunable)

    end

    properties(DiscreteState)
        previousFrame
    end

    % Pre-computed constants
    properties(Access = private)

    end

    methods
        % Constructor
        function obj = PreprocessingSteps(varargin)
            obj = obj@lemanchot.configuration.YamlConfigurable(varargin);
            if nargin > 0
                % Support name-value pair arguments when constructing object
                setProperties(obj,nargin,varargin{:})
            end
        end
    end

    methods(Access = protected)
        % Common functions
        function setupImpl(obj)
            obj.previousFrame = [];
        end

        function [result, exeTime] = stepImpl(obj, frame)
            t = cputime;
            if size(frame,3) > 1
                result = mean(frame,3);
            else
                result = frame;
            end
            result = double(mat2gray(result));
            
            if ~isempty(obj.previousFrame)
                % Correct illumination differences between the moving and fixed images
                % using histogram matching. This is a common pre-processing step.
                result = imhistmatch(result, obj.previousFrame);
            end
            
            obj.previousFrame = result;
            exeTime = cputime - t;
        end

        function resetImpl(obj)
            obj.previousFrame = [];
        end

        % Backup/restore functions
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.previousFrame =  obj.previousFrame;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.previousFrame =  s.previousFrame;
            end
            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        % Advanced functions
        function validateInputsImpl(obj,u)
            % Validate inputs to the step method at initialization
        end

        function validatePropertiesImpl(obj)
            % Validate related or interdependent property values
        end

        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function processTunedPropertiesImpl(obj)
            % Perform actions when tunable properties change
            % between calls to the System object
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
