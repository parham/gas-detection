
clear;
clc;

configFile = './algorithms/gasleak_v1_configs.yaml';
showFootage = true;

%%%%%%%%%% PRINT CONFIG INFO %%%%%%%%%%%%%
lemanchot.configuration.print_info( ...
    lemanchot.configuration.load_yaml_config(configFile));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Configure the image dataset using a folder
imgds = lemanchot.dsource.ImageFolderDataSource(...diso
    'ConfigFilePath', configFile);
% Preprocessing steps
preps = lemanchot.stitching_v1.PreprocessingSteps();
% Fernando's video stablizer
vstab = lemanchot.gasleak_v1.FernandoVideoStablizer(...
    'ConfigFilePath', configFile);
roicp = lemanchot.imgproc.ROICropper('ConfigFilePath', configFile);
% Initiate the video player
videoPlayer = vision.VideoPlayer('Name', ...
    'Enhancement of aerial gas leak using image flow analysis', ...
    'Position', [50 50 800 600]);


while ~isDone(imgds)
    % Read a frame from image dataset
    [frame, index] = step(imgds);
    disp(['Frame (', num2str(index), ') is being processed.']);
    % Preprocess the frames
    [result, exeTime] = step(preps,frame);
    disp(['>>> Preprocessing executed : ', num2str(exeTime), ' seconds']);
    % Video stabilization
%     [transImg, tform, exeTime] = step(vstab,result);
%     disp(['>>> V executed : ', num2str(exeTime), ' seconds']);
    % Extract Region of Interest
    [roi, exeTime] = step(roicp,result);
    disp(['>>> ROI Extraction executed : ', num2str(exeTime), ' seconds']);
    if showFootage
       % Show the consecutive frames
       pos = roicp.position;
       sz = roicp.size;
       out = zeros(size(result), 'like', result);
       out(pos(2):pos(2)+sz(2),pos(1):pos(1)+sz(1)) = roi;
       step(videoPlayer,out);
       pause(10^-3);
    end
end


release(imgds);
release(preps);
release(vstab);
release(roicp);
release(videoPlayer);