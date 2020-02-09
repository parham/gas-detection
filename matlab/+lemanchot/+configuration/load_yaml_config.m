function [config] = load_yaml_config(cfile)
%LOAD_YAML_CONFIG Loads the yaml file containing the user defined
%configurations

if ~isfile(cfile)
    error('The file does not exist');
end

config = yaml.ReadYaml(cfile);

end

