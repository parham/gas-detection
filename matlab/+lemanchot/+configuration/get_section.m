function [csec] = get_section(config,section)
%GET_SECTION returns the requested section of configuration
if ~isfield(config,section)
    error('The section does not exist.');
end

csec = getfield(config,section);
    
end

