
clear;
clc;


%% Load configuration
phmConfig = phm.core.phmJsonConfigBucket('./algorithms/gasleaks_v1/gasleak_v1_configs.json');

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
prepStep = glv1Preprocessing(phmConfig.getConfig('preprocessing'));
roiStep = glv1ROICropper(phmConfig.getConfig('roi_crop'));
fdifStep = glv1FrameDisplacementFromOrigin();
of = opticalFlowFarneback('NeighborhoodSize', 9, 'FilterSize', 25);
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Processing for Gas leak detection
progressbar.textprogressbar('Process the frames for gas leak detection: ');
magnitude = [];
frameSize = [];

progressStep = 1 / double(length(imgds.Files));
index = 1;
while hasdata(imgds)
    frame = read(imgds);
    prepres = prepStep.process(frame);
    if isempty(frameSize)
        frameSize = size(prepres);
    end
    roires = roiStep.process(prepres);
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
reset(imgds);
stats = regionprops(hotspotOriginMask, 'BoundingBox');
flowStats = regionprops(flowOriginMask, 'BoundingBox');
progressStep = 1 / double(length(imgds.Files));
progressIndex = 1;
while hasdata(imgds)
    [frame, index] = read(imgds);
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













