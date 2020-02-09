function [] = print_section(config,section)
%PRINT_SECTION Print all information inside the determined section of the
%configuration.
fprintf('\n');
if isfield(config,section)
    sec = getfield(config,section);
    fields = fieldnames(sec);
    for i = 1:length(fields)
        try
            disp(['<strong>', fields{i}, '</strong> --> ', getfield(sec, fields{i})]);
        catch
            disp(['<strong>', fields{i}, '</strong> --> ', 'NOT DISPLAYED']);
        end
    end
else
    disp([section, ' ', 'does not exist!']);
end
fprintf('\n');

end

