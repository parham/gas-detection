classdef GroundTruthDifferentiate < matlab.System & ...
    lemanchot.configuration.YamlConfigurable
    % ConsecutiveDifference measures the different between consecutive
    % frames and the first one.
    %

    properties(DiscreteState)
        groundTruth
    end

    methods
        % Constructor
        function obj = GroundTruthDifferentiate(varargin)
            obj = obj@lemanchot.configuration.YamlConfigurable();
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            obj.groundTruth = [];
        end

        function [result, exeTime] = stepImpl(obj,frame)
            t = cputime;
            if isempty(obj.groundTruth)
                obj.groundTruth = frame;
            end
            result = frame - obj.groundTruth;
            exeTime = cputime - t;
        end

        function resetImpl(obj)
            obj.groundTruth = [];
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        %% Advanced functions
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
