
%% Project Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%
% @description In recent decades, thanks to the advancement of IR cameras, 
% the use of this equipment for the non-destructive inspection of industrial
% sites has been growing increasingly for a variety of oil and gas applications, 
% such as mechanical inspection, and the examination of pipe integrity. 
% Recently, there is a rising interest in the application of gas imaging in 
% various industries. Gas imaging can significantly enhance functional 
% safety by early detection of hazardous gas leaks. Moreover, based on 
% current efforts to decrease greenhouse gas emissions all around the world 
% by using new technologies such as Optical Gas Imaging (OGI) to identify 
% possible gas leakages regularly, the need for techniques to automate the 
% inspection process can be essential. One of the main challenges in gas 
% imaging is the proximity condition required for data to be more reliable 
% for analysis. Therefore, the use of unmanned aerial vehicles can be very 
% advantageous as they can provide significant access due to their maneuver
% capabilities. Despite the advantages of using drones, their movements, 
% and sudden motions during hovering can diminish data usability. 
% In this paper, we investigate the employment of drones in gas imaging 
% applications. Also, we present a novel approach to enhance the visibility 
% of gas leaks in aerial thermal footages using image flow analysis. 
% Moreover, we investigate the use of the phase correlation technique for 
% the reduction of drone movements during hovering. The significance of the 
% results presented in this paper demonstrates the possible use of this 
% approach in the industry.

% First add vlfeat-0.9.21 library included in the project to the path!

clear;
clc;

%% Load configuration
configPath = sprintf('gasleak_%s_v1_configs.json', ...
    phm.utils.phmSystemUtils.getOSUser);
phmConfig = phm.core.phmJsonConfigBucket(configPath);
showFootage = false;
progressbar.textprogressbar('Load Configuration: ');
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');
%% System configuration check

if parallel.gpu.GPUDevice.isAvailable()
    disp('The installed GPU on this station can be used for data processing.');
end
progressbar.textprogressbar('Check System Configuration: ');
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Data Source initialization
progressbar.textprogressbar('Data Source initialization: ');
dsConfig = phmConfig.getConfig('data_source');
imgds = imageDatastore(dsConfig.datasetPath, ...
    'FileExtensions', dsConfig.fileExtension);
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Steps initialization
progressbar.textprogressbar('Pipeline steps initialization: ');
flattenStep = phm.imgproc.FlattenImage();
normStepFunc = @phm.imgproc.ImageProcessingUtils.normalizeAndMakingDouble;
resizeStep = phm.imgproc.ImageResizer(phmConfig.getConfig('resizing'));
histStep = phm.imgproc.HistogramBasedStreamNormalizer();
roiStep = phm.roi.ROICropper(phmConfig.getConfig('roi'));
fdifStep = phm.imgproc.FrameDifferenceFromOrigin(struct);
% Initialize Optical Flow
ofconfig = phmConfig.getConfig('optical_flow');
of = opticalFlowFarneback( ...
    'NeighborhoodSize', ofconfig.neighborhoodSize, ...
    'FilterSize', ofconfig.filterSize);
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Processing for Gas leak detection
progressbar.textprogressbar('Process the frames for gas leak detection: ');
magnitude = [];
frameSize = [];

progressStep = 1 / double(length(imgds.Files));
index = 1;
frames = cell(1,length(imgds.Files));
while hasdata(imgds)
    frame = read(imgds);
    prp = flattenStep.process(frame);
    prp = normStepFunc(prp);
    prp = resizeStep.process(prp);
    prp = histStep.process(prp);
    frames{index} = prp;
    if isempty(frameSize)
        frameSize = size(prp);
    end
    roires = roiStep.process(prp);
    fdres = fdifStep.process(roires);
    
    diffimg = adaptthresh(fdres, 0.8, 'ForegroundPolarity', 'bright');
    diffimg = mat2gray(diffimg);
    level = graythresh(diffimg);
    bw = imbinarize(diffimg,level);
    diffimg(bw == 0) = 0;
    
    flow = estimateFlow(of,diffimg);
    magFrame = mat2gray(flow.Magnitude);
    magFrame(magFrame < mean(magFrame(:))) = 0;
    magnitude = cat(3, magnitude, magFrame);
    
    if showFootage
        pos = roiStep.position;
        sz = roiStep.size;
        out = zeros(size(prepres), 'like', prepres);
        out(pos(2):pos(2)+sz(2),pos(1):pos(1)+sz(1)) = diffimg;
        resimg = imfuse(prepres, out, 'blend','Scaling','joint');
        imshow(resimg);
        pause(10^-3);
    end
    progressbar.textprogressbar(uint8(index * progressStep * 100));
    index = index + 1;
end
progressbar.textprogressbar(' done');

%% Calculate the probabilistic map
progressbar.textprogressbar('Calculate the probabilistic map: ');
numThresh = 10;
progressStep = 1 / numThresh;
index = 1;
resProbMap = cell(1,numThresh);
for thresh = 1:numThresh
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
    resProbMap{thresh} = flowPropMap;
    progressbar.textprogressbar(uint8(index * progressStep * 100));
    index = index + 1;
end
figure('Name','Results: thresholding of probability map'); 
montage(resProbMap, 'BorderSize', [3 3]);
progressbar.textprogressbar(' done');

%% Use the probabilistic map to determine the area of gas flow and hot spot
progressbar.textprogressbar('Determine the hotspots: ');
flowPropMap = resProbMap{4};
numberOfHistCluster = 10;
hotspotLevel = 5;
backgroundLevel = 1;

[binCount, binIntensity, binMask] = histcounts(flowPropMap,numberOfHistCluster);
hotspotMask = zeros(size(flowPropMap), 'like', flowPropMap);
hotspotMask(binMask > hotspotLevel) = 1;
gasFlowMask = zeros(size(flowPropMap), 'like', flowPropMap);
gasFlowMask(binMask > backgroundLevel) = 1;
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Merge the mask
progressbar.textprogressbar('Prepare the masks: ');
x = roiStep.position(1);
y = roiStep.position(2);
w = roiStep.size(1);
h = roiStep.size(2);
hotspotOriginMask = zeros(frameSize);
flowOriginMask = zeros(frameSize);

if roiStep.state
    hotspotOriginMask(y:y+h,x:x+w,:) = hotspotMask;
    flowOriginMask(y:y+h,x:x+w,:) = gasFlowMask;
else
    hotspotOriginMask = hotspotMask;
    flowOriginMask = gasFlowMask;
end

pause(3);
figure('Name','Gas Leak Detection'); 
% reset(imgds);
stats = regionprops(hotspotOriginMask, 'BoundingBox');
flowStats = regionprops(flowOriginMask, 'BoundingBox');
progressStep = 1 / double(length(imgds.Files));
progressIndex = 1;
for index = 1:length(frames)
    frame = frames{index};
    imagesc(frame);
    hold on
    BB = [];
    for k = 1 : length(stats)
         BB = stats(k).BoundingBox;
         str = 'The aera with highest gas flow intensity';
         rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','r','LineWidth',2) ;
    end
    text('Position',[BB(1)-10,BB(2)-20],'string', str, 'Color', 'r', 'FontSize', 11);
    BB = [];
    for k = 1 : length(flowStats)
         BB = flowStats(k).BoundingBox;
         str = 'The aera with gas flow';
         rectangle('Position', [BB(1),BB(2),BB(3),BB(4)],'EdgeColor','b','LineWidth',2) ;
    end
    text('Position',[BB(1)-10,BB(2)-20],'string', str, 'Color', 'b', 'FontSize', 11);
    hold off
    progressbar.textprogressbar(uint8(progressIndex * progressStep * 100));
    progressIndex = progressIndex + 1;
    pause(10^-3);
end
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');
pause(0.1);

%% probability map display
figure('Name','Probability map of the gas flow');
mesh(flowPropMap);

pause(5);
figure('Name','Detection of hotspots and gas flows'); 
montage({hotspotOriginMask, flowOriginMask}, 'BorderSize', [3 3]);













