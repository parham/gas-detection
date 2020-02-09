classdef ImageDatasetGrabber < matlab.System ...
        & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % ImageDatasetGrabber Reads all the images inside a folder
    %
    % This template includes most, but not all, possible properties, attributes,
    % and methods that you can implement for a System object in Simulink.

    % Public, tunable properties
    properties(Nontunable)
        datasetPath
    end
    
    properties(Access = private)
        imgDataset
    end

    properties(DiscreteState)
        processedFrames
    end
    
    properties(DiscreteState)
        currentFrameRate
    end
    
    properties(DiscreteState)
        currentFrameIndex
    end

    methods
        % Constructor
        function obj = ImageDatasetGrabber(varargin)
            if nargin > 0
                % Support name-value pair arguments when constructing object
                setProperties(obj,nargin,varargin{:})
            end
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            obj.processedFrames = 0;
            obj.currentFrameRate = 0;
            obj.currentFrameIndex = 1;
            if isempty(obj.datasetPath)
                obj.datasetPath = './le-manchot/matlab/ds/test';
            end
            obj.imgDataset = imageSet(obj.datasetPath);
        end

        function [img, index] = stepImpl(obj)
            index = obj.currentFrameIndex;
            read(obj.imgDataset, index);
            obj.currentFrameIndex = index + 1;
            path = obj.resourceList(index);
            img = imread(path);
        end

        function resetImpl(obj)
            obj.processedFrames = 0;
            obj.currentFrameRate = 0;
            obj.currentFrameIndex = 1;
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

        %% Simulink functions
        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function out = getOutputSizeImpl(obj)
            % Return size for each output port
            out = [1 1];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = mfilename("class"); % Use class name
            % icon = "My System"; % Example: text icon
            % icon = ["My","System"]; % Example: multi-line text icon
            % icon = matlab.system.display.Icon("myicon.jpg"); % Example: image file icon
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
        end
    end
end
