classdef (ConstructOnLoad) YamlConfigurable < dynamicprops
    %YAMLCONFIGURABLE The base class for any Yaml-based configurable component
    
    methods
        function [obj, props] = YamlConfigurable(varargin)
            %CONFIGURABLE Construct an instance of this class
            props = [];
            if nargin > 0
                 args = lemanchot.utils.props2struct(varargin);
                 if isfield(args, 'ConfigFilePath')
                     props = lemanchot.configuration.YamlConfigurable.loadYamlConfig(args.ConfigFilePath);
                     if isfield(args, 'ConfigFileSection')
                         props = lemanchot.configuration.YamlConfigurable.getSection(props, args.ConfigFileSection);
                     end
                     obj.configure(props);
                 end
            end
        end
        
        function [] = configure (obj, props, section)
            targetProps = props;
            if nargin > 2
                targetProps = lemanchot.configuration.YamlConfigurable.getSection(props,section);
            end
            
            keys = fieldnames(targetProps);
            if isempty(keys)
                error('No property is determined!')
            end
            
            for index=1:length(keys)
                k = keys{index}
                v = targetProps.(k);
                if ~isprop(obj,k)
                    addprop(obj,k);
                end
                obj.(k) = v;
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

