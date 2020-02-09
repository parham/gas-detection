

%% Parham Nooralishahi

clear;
clc;

%% Load the dataset
% Dataset path
dirPath = '/home-local2/panoo.extra.nobkp/current_dataset/image_stitching/airplane_exp01';
% dirPath = '/home/phm/MEGA/working_datasets/reflection_reduction/exp02_sensefly_solar_panel_reflection';
%dirPath = '/home/phm/MEGA/working_datasets/data/reflection_02';
fileExt = '*.tif';

disp(['Dataset --> ', dirPath]);
disp(['Determined file format --> ', fileExt]);

flist = list_files(dirPath, fileExt);
if isempty(flist)
    error('There is no file to read');
end

%% Parameters initialization 
% The first assumption in this code is all the images inside the dataset,
% have same size
% specified bounding image size
size_bound=400.0;
% focal length for cylander projection
focal = 2000;

%% Calculate the image size and properties
disp('Calculate the required properties for images');
warning('off','all')
initial_frame = imread(flist{1});
initial_frame = imadjust(initial_frame);
warning('on','all')
fsize = size(initial_frame,1);

scaleRatio = 1.0;
if fsize 
    scaleRatio = size_bound / fsize;
end
disp(['Determined scale ration --> ', num2str(scaleRatio)]);

%% Load all the images inside the dataset
t = cputime;
frames = imresize(initial_frame,scaleRatio);
clear initial_frame;

for index = 2:length(flist) 
    % Read the image
    warning('off','all')
    orig = imread(flist{index});
    % Adjust the contrast to span it to all range
    warning('on','all')
    orig = imadjust(orig);
    % Apply the image resize
    frame = imresize(orig, scaleRatio);
    % Append the read frame to the collection
    frames = cat(3, frames, frame);
end

disp(['Load dataset (time) --> ', int2str(cputime - t), ' seconds']);

%% Determine the frame count and frame dimensions
dimFrames = size(frames);
frameCount = dimFrames(end);
disp(['Frame counts --> ', num2str(frameCount)]);

%% Transform frames to cylindar projection

t = cputime;
cyFrames = single(zeros(size(frames), 'like', frames));
for i = 1:frameCount
    tmp = warp(frames(:, :, i), focal);
    cyFrames(:, :, i) = im2single(tmp);
end
disp(['Cylindrical projection warping (time) --> ', int2str(cputime - t),' seconds']);

%% Calculate translations
edgeThresh = 10;
confidence = 0.99;
inlierRatio = 0.3;
epsilon = 1.5;

% Initialize the translation matrix
trans = zeros(3, 3, frameCount);
trans(:, :, 1) = eye(3);
% Calculate translations
firstFrame = cyFrames(:,:,1);
% Calculate features and descriptors
[fsecond, dsecond] = vl_sift(firstFrame, 'EdgeThresh', edgeThresh);
tarr = zeros(frameCount, 1);
for i = 2:frameCount
    t = cputime;
    ffirst = fsecond;
    dfirst = dsecond;
    % Retrieve the frame
    tmpFrame = cyFrames(:,:,i);
    % Calculate features and descriptors
    [fsecond, dsecond] = vl_sift(tmpFrame, 'EdgeThresh', edgeThresh);
    % Match two consecutive frames using features
    [matches, scores] = vl_ubcmatch(dfirst, dsecond);
    numMatches = size(matches,2);
    % Find pairs
    pairs = nan(numMatches, 3, 2);
    pairs(:,:,1)=[ffirst(2,matches(1,:));ffirst(1,matches(1,:));ones(1,numMatches)]';
    pairs(:,:,2)=[fsecond(2,matches(2,:));fsecond(1,matches(2,:));ones(1,numMatches)]';
	% Calculate translations
    [trans(:, :, i), ~] = RANSAC(confidence, inlierRatio, 1, pairs, epsilon);
    tarr(i) = cputime - t;
end
disp(['Find translation [SIFT & RANSAC] (time) --> ', num2str(mean(tarr)),' seconds']);

%% Incrementally calculate general translation
absTrans = zeros(size(trans));
absTrans(:, :, 1) = trans(:, :, 1);
for i = 2:frameCount
    absTrans(:, :, i) = absTrans(:, :, i - 1) * trans(:, :, i);
end

%% end to end adjustment

t = cputime;
width = size(cyFrames, 2);
height = size(cyFrames, 1);

maxY = height;
minY = 1;
minX = 1;
maxX = width;
for i = 2:frameCount 
    maxY = max(maxY, absTrans(1,3,i) + height);
    maxX = max(maxX, absTrans(2,3,i) + width);
    minY = min(minY, absTrans(1,3,i));
    minX = min(minX, absTrans(2,3,i));
end
stitchedHeight = ceil(maxY) - floor(minY) + 1;
stitchedWidth = ceil(maxX) - floor(minX) + 1;

absTrans(2, 3, :) = absTrans(2, 3, :) - floor(minX);
absTrans(1, 3, :) = absTrans(1, 3, :) - floor(minY);
disp(['end2end alignment:', int2str(cputime-t), ' sec']);


%% Create the mask
% Convert the frames to double
mapFrames = im2double(cyFrames);

mask = ones(height, width);
mask = warp(mask, focal);
mask = imcomplement(mask);
mask = bwdist(mask, 'euclidean');
mask = mask ./ max(max(mask));

% Merging
maxH = 0;
minH = 0;
maxW = 0;
minW = 0;

for i = 1:frameCount
    pPrime = absTrans(:,:,i) * [1;1;1];
    pPrime = pPrime ./ pPrime(3);
    baseH = floor(pPrime(1));
    baseW = floor(pPrime(2));
    if baseH > maxH
        maxH = baseH;
    end
    if baseH < minH
        minH = bash_h;
    end
    if baseW > maxW
        maxW = baseW;
    end
    if baseW < minW
        minW = baseW;
    end
end

result = zeros([stitchedHeight + 20, stitchedWidth + 20], 'like', mapFrames);
denominator = zeros([stitchedHeight + 20, stitchedWidth + 20], 'like', mapFrames);

% Create the reflection confussion matrix
resRefl = zeros([stitchedHeight + 20, stitchedWidth + 20, frameCount], 'like', mapFrames);
resMask = zeros([stitchedHeight + 20, stitchedWidth + 20, frameCount], 'like', mapFrames);
resWindow = zeros(4, frameCount);
%% Merge frames
for i = 1:frameCount
    template = zeros([stitchedHeight + 20, stitchedWidth + 20], 'like', mapFrames);
    pPrime = absTrans(:,:,i) * [minH + 10; minW + 10; 1];
    pPrime = pPrime ./ pPrime(3);
    baseH = floor(pPrime(1));
    baseW = floor(pPrime(2));
    if baseH == 0
        baseH = 1;
    end
    if baseW == 0
        baseW = 1;
    end
    
    % Keep thermal data
    resRefl(baseH:baseH+height-1, baseW:baseW+width-1, i) = mapFrames(:,:,i);
    % Create the frame mask
    resMask(baseH:baseH+height-1, baseW:baseW+width-1, i) = 1;
    % Keep the window coordinate
    resWindow(:, i) = [baseW, baseH, width, height];
    
    
    result(baseH:baseH+height-1, baseW:baseW+width-1) = ...
        result(baseH:baseH+height-1, baseW:baseW+width-1) + ...
        mapFrames(:,:,i) .* mask;
    denominator(baseH:baseH+height-1, baseW:baseW+width-1) = ...
        denominator(baseH:baseH+height-1, baseW:baseW+width-1) + ...
        mask;
end

result = result ./ denominator;

[refOutput, overlapped] = reflection_dr(resRefl, resMask, resWindow);

subplot(1,2,1), imshow(refOutput);
subplot(1,2,2), imshow(overlapped);


disp('The Reflection removal algorithm has been finished!');





