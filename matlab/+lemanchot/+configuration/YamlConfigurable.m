classdef (ConstructOnLoad) YamlConfigurable < dynamicprops
    %YAMLCONFIGURABLE The base class for any Yaml-based configurable component
    
    methods(Access = public)
        function [obj, props] = YamlConfigurable(varargin)
            %CONFIGURABLE Construct an instance of this class
            props = [];
            if nargin > 0
                section = [];
                args = lemanchot.utils.props2struct(varargin);
                props = struct();
                if isfield(args, 'ConfigFileSection')
                    section = args.ConfigFileSection;
                end
                if isfield(args, 'ConfigFilePath')
                    props = lemanchot.configuration.YamlConfigurable.loadYamlConfig(args.ConfigFilePath);
                elseif isfield(args, 'ConfigStructure')
                    props = args.ConfigStructure;
                elseif isfield(args, 'DefaultConfigFilePath')
                    props = lemanchot.configuration.YamlConfigurable.loadYamlConfig(args.DefaultConfigFilePath);
                end
                
                if ~isempty(section) && ~isempty(fieldnames(props))
                    props = lemanchot.configuration.YamlConfigurable.getSection(props, section);
                end
                
                obj.configure(props);
            end
        end
        
        function [] = configure (obj, props, section)
            targetProps = props;
            if nargin > 2
                targetProps = lemanchot.configuration.YamlConfigurable.getSection(props,section);
            end
            
            keys = fieldnames(targetProps);
            if ~isempty(keys)
                for index=1:length(keys)
                    k = keys{index};
                    v = targetProps.(k);
                    if ~isprop(obj,k)
                        addprop(obj,k);
                    end
                    obj.(k) = v;
                end
            end
        end
    end
    
    methods(Static)
        function config = loadYamlConfig (cfile)
            % LOADYAMLCONFIG Loads the yaml file containing the user
            % defined configurations.
            if ~isfile(cfile)
                error('The file does not exist');
            end

            config = yaml.ReadYaml(cfile);
        end
        
        function config = getSection (origConfig, section)
            %GETSECTION returns the requested section of configuration
            if ~isfield(origConfig,section)
                error('The section does not exist.');
            end

            config = origConfig.(section);
        end
    end
end

