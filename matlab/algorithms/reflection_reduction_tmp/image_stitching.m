
clear;
clc;

%% Load the YAML configuration file from the determined path.
% config = configuration.load_yaml_config('./home_configs.yaml');
config = configuration.load_yaml_config('./stitching_configs.yaml');
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
propConfig = configuration.get_section(config,'preprocessing');
configuration.print_section(config,'preprocessing');

boundingSize = configuration.get_prop(propConfig, 'bounding_size', '450');

disp('Read frames from the dataset');
warning('off','all')
[frames, exeTime] = read_image_as_batch(flist, boundingSize);
warning('on','all')
disp(['The number of retrieved images (', num2str(exeTime), ' secs) --> ', num2str(size(frames,4))]);

clear boundingSize;

%% Prepare the frames for further processing and apply preprocessing steps
[frames, exeTime] = stitching.preprocessing(frames,propConfig);
disp(['Preprocessing steps has been applied to the frames (', num2str(exeTime), ' secs).']);

%% Camera's lens distortion removal 


%% Image stitching
matchingConfig = configuration.get_section(config,'matching');
configuration.print_section(config,'matching');

[matches, exeTime] = stitching.matching(frames, matchingConfig);
disp(['Matching steps has been applied to the frames (', num2str(exeTime), ' secs).']);

regConfig = configuration.get_section(config,'register');
configuration.print_section(config,'register');

[regs, stitchedSize, exeTime] = stitching.registration(frames, matches, regConfig);
disp(['Registering steps has been applied to the frames (', num2str(exeTime), ' secs).']);

for index = 1:length(regs)-1
%     imshowpair(regs(index).RegisteredImage, regs(index + 1).CurrentRefObj,...
%         regs(index + 1).RegisteredImage, regs(index + 1).CurrentRefObj, ...
%         'blend','Scaling','joint')
    imshow(regs(index).RegisteredImage);
    pause(10^-4);
end