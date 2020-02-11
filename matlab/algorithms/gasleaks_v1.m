
clear;
clc;

configFile = './algorithms/gasleak_v1_configs.yaml';
showFootage = false;

%%%%%%%%%% PRINT CONFIG INFO %%%%%%%%%%%%%
lemanchot.configuration.print_info( ...
    lemanchot.configuration.load_yaml_config(configFile));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configure the image dataset using a folder
imgds = lemanchot.dsource.ImageFolderDataSource(...
    'ConfigFilePath', configFile);
% Preprocessing steps
preps = lemanchot.stitching_v1.PreprocessingSteps();
% Fernando's video stablizer
vstab = lemanchot.gasleak_v1.FernandoVideoStablizer(...
    'ConfigFilePath', configFile);
% Initiate the video player
videoPlayer = vision.VideoPlayer('Name', ...
    'Enhancement of aerial gas leak using image flow analysis', ...
    'Position', [50 50 800 600]);

while ~isDone(imgds)
   % Read a frame from image dataset
   [frame, index] = step(imgds);
   % Preprocess the frames
   [result, exeTime] = step(preps,frame);
   % Video stabilization
   [transImg, tform, exeTime] = step(vstab,result);
   if showFootage
       % Show the consecutive frames
       step(videoPlayer,transImg);
   end
end

release(imgds);
release(preps);
release(videoPlayer);