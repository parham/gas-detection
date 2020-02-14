classdef ImageFolderDataSource < matlab.System & ...
        matlab.system.mixin.FiniteSource & ...
        lemanchot.configuration.YamlConfigurable
    % IMAGEDATASOURCE a image data source based on the specified directory
    %

    properties(Nontunable)
        datasetPath
    end
    
    properties(Access = private)
        imgDataset
    end

    properties(DiscreteState)
        currentFrameIndex
    end

    methods
        % Constructor
        function obj = ImageFolderDataSource(varargin)
            obj = obj@lemanchot.configuration.YamlConfigurable( ...
                cat(2, varargin, 'ConfigFileSection', 'img_dataset', ...
                    'DefaultConfigFilePath', './+lemanchot/+dsource/imgds_default.yaml'));
            
            if isprop(obj, 'imgSize') && iscell(obj.imgSize)
                obj.imgSize = reshape(cell2mat(obj.imgSize), [], 2);
            end
            
%             if nargin > 0
%                 % Support name-value pair arguments when constructing object
%                 setProperties(obj,nargin,varargin{:})
%             end
        end
    end

    methods(Access = private)
        function initialize(obj)
            if ~isprop(obj, 'datasetPath')
                addprop(obj, 'datasetPath');
                obj.datasetPath = './ds/test/';
            end
            if ~isprop(obj, 'imgSize')
                addprop(obj, 'imgSize');
                obj.imgSize = [600 800];
            end
            if ~isprop(obj, 'resizeMethod')
                addprop(obj, 'resizeMethod');
                obj.resizeMethod = 'nearest';
            end
        end
    end
    
    methods(Access = protected)
        function bDone = isDoneImpl(obj)
            bDone = obj.currentFrameIndex >= obj.imgDataset.Count;
        end

        function setupImpl(obj)
            obj.currentFrameIndex = 1;
            obj.initialize();
            obj.imgDataset = imageSet(obj.datasetPath);
        end

        function [img, index] = stepImpl(obj)
            index = obj.currentFrameIndex;
            img = read(obj.imgDataset, index);
            img = imresize(img, obj.imgSize, 'method', obj.resizeMethod);
            obj.currentFrameIndex = index + 1;
        end

        function resetImpl(obj)
            obj.currentFrameIndex = 1;
        end

        % Backup/restore functions
        function s = saveObjectImpl(obj)
            s = saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.currentFrameIndex =  obj.currentFrameIndex;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.currentFrameIndex =  s.currentFrameIndex;
            end
            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        % Advanced functions
        function validatePropertiesImpl(obj)
            if isempty(obj.datasetPath) || isa(obj.datasetPath,'string')
                error('dataset path must be a non-empty string array');
            end
            if ~isfolder(obj.datasetPath)
                error('The dataset path should be a directory');
            end
        end

        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct('currentFrameIndex', obj.currentFrameIndex);
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
