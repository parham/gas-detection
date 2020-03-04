
clear;
clc;

%% Load the YAML configuration file from the determined path.
% config = configuration.load_yaml_config('./home_configs.yaml');
config = configuration.load_yaml_config('./gasleak_university_configs.yaml');
% print the info section of the config
configuration.print_info(config);
disp('Configuration file is loaded.');

%% Load dataset
dsConfig = configuration.get_section(config,'dataset');
configuration.print_section(config,'dataset');

flist = list_files(dsConfig.directory, dsConfig.filter);
if isempty(flist)
    error('There is no file to read');
end

%% Calculate the image size and properties
propConfig = configuration.get_section(config,'props');
configuration.print_section(config,'props');

disp('Read frames from the dataset');
warning('off','all')
[frames, exeTime] = read_image_as_batch(flist, propConfig.bounding_size);
warning('on','all')
disp(['The number of retrieved images (', num2str(exeTime), ' secs) --> ', num2str(size(frames,4))]);

%% Prepare the frames for further processing and apply preprocessing steps
[frames, exeTime] = stitching.preprocessing(frames,propConfig);
disp(['Preprocessing steps has been applied to the frames (', num2str(exeTime), ' secs).']);

for index = 1:length(frames)
    imshow(frames(:,:,index));
    pause(10^-3);
end

