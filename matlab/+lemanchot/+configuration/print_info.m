function [] = print_info(config)
%PRINT_INFO Prints the info section of the yaml configuration 
%   Detailed explanation goes here

disp('');
disp('<strong>******************************</strong>');
if isfield(config,'info')
    info = config.info;
    fields = fieldnames(info);
    for i = 1:length(fields)
        disp(['<strong>', fields{i}, '</strong>:  ', getfield(info, fields{i})]);
    end
else
    disp('THERE IS NO AVAILABLE INFO');
end
disp('<strong>******************************</strong>');
disp('');

end

