classdef ListImageGrabber < matlab.System & matlab.system.mixin.Propagates
    % ListImageGrabber list-based data grabber
    % *list-based data grabber* uses the defined list of resources to load
    % data.

    properties(Nontunable)
        resourceList
    end
    
    properties(Nontunable)
        frameRate = uint8(32);
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
        function obj = ListImageGrabber(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            obj.processedFrames = 0;
            obj.currentFrameRate = 0;
            obj.currentFrameIndex = 1;
            if isempty(obj.resourceList)
                obj.resourceList = ["test","yes"];
            end
        end

        function [img, index] = stepImpl(obj)
            index = obj.currentFrameIndex;
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
            s = saveObjectImpl@matlab.System(obj);

            if isLocked(obj)
                s.processedFrames =  obj.processedFrames;
                s.currentFrameRate =  obj.currentFrameRate;
                s.currentFrameIndex =  obj.currentFrameIndex;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.processedFrames =  s.processedFrames;
                obj.currentFrameRate =  s.currentFrameRate;
                obj.currentFrameIndex =  s.currentFrameIndex;
            end
            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        %% Validation
        function validatePropertiesImpl(obj)
            if ~isinteger(obj.frameRate) || obj.frameRate <= 0
                error('Framerate must be a positive integer');
            end
            if isempty(obj.resourceList) || ~isa(obj.resourceList,'string')
                error('resource list must be a non-empty string array');
            end
        end

        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct('processedFrames', obj.processedFrames, ...
                'currentFrameRate', obj.processedFrames, ...
                'currentFrameIndex', obj.currentFrameIndex);
        end
    end
    
  methods (Static, Access = protected)
      function header = getHeaderImpl
         header = matlab.system.display.Header(...
              'Title', 'List Image Grabber');
      end
  end
   
  methods(Static, Access=protected)
    function group = getPropertyGroupsImpl
      group = matlab.system.display.Section(mfilename('class'));
    end
  end
  
  methods(Access=protected)
    
  function [sz,dt,cp] = getDiscreteStateSpecificationImpl(~,name)
     if strcmp(name,'processedFrames')
        sz = [1 1];
        dt = 'double';
        cp = false;
     elseif strcmp(name,'currentFrameRate')
        sz = [1 1];
        dt = 'double';
        cp = false;
     elseif strcmp(name,'currentFrameIndex')
        sz = [1 1];
        dt = 'double';
        cp = false;
     else
         error('shit');
     end
  end
      
    function num = getNumOutputsImpl(~)
        num = 2;
    end

    function [sz1, sz2] = getOutputSizeImpl(obj)
        % Maximum length of linear indices and element vector is the
        % number of elements in the input
        sz1 = [512 640];
        sz2 = [1 1];
    end
    
     function [fz1, fz2] = isOutputFixedSizeImpl(~)
      %Both outputs are always variable-sized
      fz1 = true;
      fz2 = true;
    end
    
    function [dt1, dt2] = getOutputDataTypeImpl(~)
        dt1 = 'uint8';
        dt2 = 'double';
    end
    
    function [cp1, cp2] = isOutputComplexImpl(~)
        cp1 = false; %Linear indices are always real values
        cp2 = false;
    end
    
  end
    
end
