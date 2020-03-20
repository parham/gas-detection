function [value] = get_prop(config, key, defValue)
%GET_PROP Get the value of the asked property

if ~isfield(config,key) && nargin==2
    error(['The ', key, ' key does not exist and no default value has been determined.']);
end

if isfield(config,key)
    value = config.key;
else
    value = defValue;
end

end

