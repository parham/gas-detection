
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

classdef (ConstructOnLoad) phmCore < dynamicprops
    %PHMCORE This class is the base of all main component of the LeManchot
    %system.
    
    properties (Constant)
        SERIAL_LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        SERIAL_DIGITS = '0123456789';
    end
    
    properties
        lastExecutionTime
    end

    methods (Access = protected)
        function [] = configure (obj, props)
            keys = fieldnames(props);
            if ~isempty(keys)
                for index=1:length(keys)
                    k = keys{index};
                    v = props.(k);
                    if ~isprop(obj,k)
                        addprop(obj,k);
                    end
                    obj.(k) = v;
                end
            end
        end
    end
    
    methods
        function [] = reset (obj)
            obj.lastExecutionTime = 0;
        end
    end
    
    methods
        function obj = phmCore(varargin)
            %PHMCORE Construct an instance of this class
            if nargin > 0
                configs = varargin{1};
                if ~isempty(configs)
                    obj.configure(configs{1});
                end
            end
            obj.lastExecutionTime = 0;
            if ~isprop(obj,'name')
                addprop(obj,'name');
                lttr = obj.SERIAL_LETTERS(ceil(rand(1,4)*length(obj.SERIAL_LETTERS)));
                digits = obj.SERIAL_DIGITS(ceil(rand(1,4)*length(obj.SERIAL_DIGITS)));
                obj.name = strcat(lttr,digits);
            end
        end
        
        function value = get.lastExecutionTime(obj)
            value = obj.lastExecutionTime;
        end
    end
end
