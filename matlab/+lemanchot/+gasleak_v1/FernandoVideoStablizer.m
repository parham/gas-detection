classdef FernandoVideoStablizer < matlab.System & ...
    lemanchot.configuration.YamlConfigurable
    % FernandoVideoStablizer The video stablizer based on provided method
    % by Dr. Fernando Lopez

    % Public, non-tunable properties
    properties(Nontunable)
        transformType
    end

    properties(DiscreteState)
        fixedFrame,
        optimizer,
        metric
    end

    methods
        % Constructor
        function obj = FernandoVideoStablizer(varargin)
            obj = obj@lemanchot.configuration.YamlConfigurable( ...
                cat(2, varargin, 'ConfigFileSection', 'fernando_vstab'));
        end
    end

    methods(Access = private)
        function initialize(obj)
            if ~isprop(obj, 'transformType')
                addprop(obj, 'transformType');
                obj.resizeMethod = 'similarity';
            end
        end
    end
    
    methods(Access = protected)
        % Common functions
        function setupImpl(obj)
            obj.fixedFrame = [];
            obj.initialize();
        end

        function [result, tform, exeTime] = stepImpl(obj,frame)
            t = cputime;
            if (isempty(obj.optimizer) || isempty(obj.metric))
                [optimizerValue, metricValue] = imregconfig('monomodal');
                obj.optimizer = optimizerValue;
                obj.metric = metricValue;
            end
            if isempty(obj.fixedFrame)
                obj.fixedFrame = frame;
                result = frame;
                tform = [];
            else
                tform = imregcorr(frame, obj.fixedFrame, obj.transformType);
                result = imregister(frame, obj.fixedFrame, ...
                    obj.transformType, obj.optimizer, obj.metric, ... 
                        'InitialTransformation', tform); % 'affine'
            end
            obj.fixedFrame = result;
            exeTime = t - cputime;
        end

        function resetImpl(obj)
            obj.fixedFrame = [];
            obj.optimizer = [];
            obj.metric = [];
        end

        % Backup/restore functions
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.fixedFrame =  obj.fixedFrame;
                s.metric = obj.metric;
                s.optimizer = obj.optimizer;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.fixedFrame =  s.fixedFrame;
                obj.metric =  s.metric;
                obj.optimizer =  s.optimizer;
            end
            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        % Advanced functions
        function validatePropertiesImpl(obj)
            if isempty(obj.transformType) || isa(obj.transformType,'string')
                error('transformation type must be a non-empty string');
            end
        end

        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct('fixedFrame', obj.fixedFrame, ... 
                'metric', obj.metric, ...
                    'optimizer', obj.optimizer);
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
