
clear;
clc;

% Configuration path
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
% ROI Cropper
roicp = lemanchot.regionproc.ROICropper('ConfigFilePath', configFile);
% Frame Differentiate
fdiffp = lemanchot.imgstream.GroundTruthDifferentiate('ConfigFilePath', configFile);
% Initiate the video player
videoPlayer = vision.VideoPlayer('Name', ...
    'Enhancement of aerial gas leak using image flow analysis', ...
    'Position', [50 50 800 600]);

of = opticalFlowFarneback('NeighborhoodSize', 9, 'FilterSize', 25);

magnitude = [];
frameSize = [];
while ~isDone(imgds)
%% Read a frame from image dataset
    [frame, index] = step(imgds);
    disp(['Frame (', num2str(index), ') is being processed.']);
%% Preprocess the frames
    [prepr, exeTime] = step(preps,frame);
    if isempty(frameSize)
        frameSize = size(prepr);
    end
    disp(['>>> Preprocessing executed : ', num2str(exeTime), ' seconds']);
%% Video stabilization
%     [transImg, tform, exeTime] = step(vstab,result);
%     disp(['>>> V executed : ', num2str(exeTime), ' seconds']);
%% Extract Region of Interest
    [roi, exeTime] = step(roicp,prepr);
    disp(['>>> ROI Extraction executed : ', num2str(exeTime), ' seconds']);
%% Calculate frame difference
    [diffimg, exeTime] = step(fdiffp, roi);
    
    diffimg = adaptthresh(diffimg, 0.8, 'ForegroundPolarity', 'bright');
    diffimg = mat2gray(diffimg);
    level = graythresh(diffimg);
    bw = imbinarize(diffimg,level);
    diffimg(bw == 0) = 0;
    
    %diffimg(diffimg <= std(diffimg(:))) = 0;
    flow = estimateFlow(of,diffimg);
    
    magFrame = mat2gray(flow.Magnitude);
    magFrame(magFrame < mean(magFrame(:))) = 0;
    magnitude = cat(3, magnitude, magFrame);
    
    disp(['>>> Frame Difference executed : ', num2str(exeTime), ' seconds']);
    if showFootage
       % Show the consecutive frames
       pos = roicp.position;
       sz = roicp.size;
       out = zeros(size(prepr), 'like', prepr);
       out(pos(2):pos(2)+sz(2),pos(1):pos(1)+sz(1)) = diffimg;
       resimg = imfuse(prepr, out, 'blend','Scaling','joint');
       %step(videoPlayer,resimg);
       %pause(10^-3);
    end
end

%% Calculate the probabilistic map
res = {};
for thresh = 1:10
    % ** Parameters
    severityThreshold = 0.1 * thresh;
    flowPropMap = magnitude;
    % Remove the outliers which their magnitude is lower than the determined
    % threshold.
    flowPropMap(flowPropMap < severityThreshold) = 0;
    % Determine the areas that may gas flow occurred!
    flowPropMap(flowPropMap ~= 0) = 1;
    % Calculate the probabilistic map of the flow
    flowPropMap = mean(flowPropMap,3);
    res{end+1} = flowPropMap;
end
figure('Name','Results: thresholding of probability map'); 
montage(res, 'BorderSize', [3 3]);

%% Use the probabilistic map to determine the area of gas flow and hot spot
flowPropMap = res{4};
% ** Parameters
numberOfHistCluster = 10;
hotspotLevel = 5;
backgroundLevel = 1;

[binCount, binIntensity, binMask] = histcounts(flowPropMap,numberOfHistCluster);
hotspotMask = zeros(size(flowPropMap), 'like', flowPropMap);
hotspotMask(binMask > hotspotLevel) = 1;
gasFlowMask = zeros(size(flowPropMap), 'like', flowPropMap);
gasFlowMask(binMask > backgroundLevel) = 1;

%% Merge the mask
x = roicp.position(1);
y = roicp.position(2);
w = roicp.size(1);
h = roicp.size(2);
hotspotOriginMask = zeros(frameSize);
flowOriginMask = zeros(frameSize);

hotspotOriginMask(y:y+h,x:x+w,:) = hotspotMask;
flowOriginMask(y:y+h,x:x+w,:) = gasFlowMask;

pause(3);
figure('Name','Gas Leak Detection'); 
reset(imgds);
stats = regionprops(hotspotOriginMask, 'BoundingBox');
flowStats = regionprops(flowOriginMask, 'BoundingBox');
while ~isDone(imgds)
    [frame, index] = step(imgds);
    % Show the consecutive frames
    %resimg = imfuse(flowOriginMask .* 255, hotspotOriginMask .* 150, 'blend','Scaling','joint');
    %resimg = imfuse(frame, resimg, 'blend','Scaling','joint');
    imagesc(frame);
    hold on
    BB = [];
    for k = 1 : length(stats)
         BB = stats(k).BoundingBox;
         str = 'The aera with highest gas flow intensity';
         %annotation('rectangle',[BB(1),BB(2),BB(3),BB(4)],'String',str)
         rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','r','LineWidth',2) ;
    end
    text('Position',[BB(1)-10,BB(2)-20],'string', str, 'Color', 'r', 'FontSize', 11);
    BB = [];
    for k = 1 : length(flowStats)
         BB = flowStats(k).BoundingBox;
         str = 'The aera with gas flow';
         %annotation('rectangle',[BB(1),BB(2),BB(3),BB(4)],'String',str)
         rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','b','LineWidth',2) ;
    end
    text('Position',[BB(1)-10,BB(2)-20],'string', str, 'Color', 'b', 'FontSize', 11);
    hold off
    pause(10^-3);
end

pause(1);
%% probability map display
figure('Name','Probability map of the gas flow');
mesh(flowPropMap);

pause(5);
figure('Name','Detection of hotspots and gas flows'); 
montage({hotspotOriginMask, flowOriginMask}, 'BorderSize', [3 3]);

release(imgds);
release(preps);
release(vstab);
release(roicp);
release(videoPlayer);