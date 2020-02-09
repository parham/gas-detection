function [results, stitchedSize, exeTime] = registration(frames, transStruct, config)
%REGISTRATION Register the frames

t = cputime;
smoothEdge = configuration.get_prop(config, 'smooth_edge', true);
nonRigidTrans = configuration.get_prop(config, 'nonrigid_trans', false);
numIteration = configuration.get_prop(config, 'num_iteration', 100);
accuFieldSmoothing = configuration.get_prop(config, 'accu_fieldsmoothing');
pyramidLevel = configuration.get_prop(config, 'pyramidLevel');

frameCount = length(transStruct);
% Incrementally calculate general translation
transStruct(1).AbsolutTrans = transStruct(1).Transformation;
for index = 2:frameCount
    rec = transStruct(index);
    prevFrameTrans = transStruct(index-1).AbsolutTrans.T;
    trans = rec.Transformation.T;
    transStruct(index).AbsolutTrans = rec.Transformation;
    transStruct(index).AbsolutTrans.T = prevFrameTrans * trans;
end

% End 2 end adjustment
width = size(frames, 2);
height = size(frames, 1);

maxY = height;
minY = 1;
minX = 1;
maxX = width;

for index = 1:frameCount
    absoluteTrans = transStruct(index).Transformation.T;
    maxY = max(maxY, absoluteTrans(1,3) + height);
    maxX = max(maxX, absoluteTrans(2,3) + width);
    minY = min(minY, absoluteTrans(1,3));
    minX = min(minX, absoluteTrans(2,3));
end

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [minX maxX];
yLimits = [minY maxY];
stitchedHeight = ceil(maxY) - floor(minY) + 1;
stitchedWidth = ceil(maxX) - floor(minX) + 1;

stitchedSize = [stitchedHeight + 20, stitchedWidth + 20];
worldRefObj = imref2d([stitchedHeight + 120 stitchedWidth + 120], xLimits, yLimits);

for index = 1:frameCount
    transStruct(index).Transformation.T(2, 3) = ... 
        transStruct(index).Transformation.T(2, 3) - floor(minX);
    transStruct(index).Transformation.T(1, 3) = ... 
        transStruct(index).Transformation.T(1, 3) - floor(minY);
end

% https://www.mathworks.com/help/vision/examples/feature-based-panoramic-image-stitching.html?prodcode=VP&language=en
% Initialize the "empty" panorama.
panorama = zeros(stitchedSize, 'like', frames(:,:,1));

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port'); 

% Register the frames
for index = 1:frameCount
    rec = transStruct(index);
    first = frames(:,:,index);
    second = frames(:,:,index+1);
    secondRefObj = rec.CurrentRefObj;
    %firstRefObj = rec.SpatialRefObj;
    
    transStruct(index).RegisteredMask = imwarp(true(size(second,1), ...
        size(second,2)), rec.AbsolutTrans, 'OutputView', worldRefObj);
    
    % Overlay the warpedImage onto the panorama.
    transStruct(index).RegisteredImage = imwarp(second, secondRefObj, ...
        rec.AbsolutTrans, 'OutputView', worldRefObj, 'SmoothEdges', smoothEdge);
    
    panorama = step(blender, panorama, ...
        transStruct(index).RegisteredImage, ... 
            transStruct(index).RegisteredMask);
    
    if nonRigidTrans
        [transStruct(index).DisplacementField,transStruct(index).RegisteredImage] = ...
            imregdemons(transStruct(index).RegisteredImage,first,numIteration,...
                'AccumulatedFieldSmoothing',accuFieldSmoothing,...
                    'PyramidLevels',pyramidLevel);
    end
    
    imshow(panorama);
    pause(10^-3);
end

maxH = 0;
minH = 0;
maxW = 0;
minW = 0;



results = transStruct;
exeTime = cputime - t;

end

