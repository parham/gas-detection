function [results, exeTime] = matching(frames, config)
%MATCHING Detect the features and perform the matching between consecutive
%frames

t = cputime;
metricThreshold = configuration.get_prop(config, 'metric_threshold', 600);
numOctave = configuration.get_prop(config, 'num_octave', 3);
scaleLevel = configuration.get_prop(config, 'scale_level', 5);
matchThreshold = configuration.get_prop(config, 'match_threshold');
maxRatio = configuration.get_prop(config, 'max_ratio');

frameCount = size(frames,3);
if frameCount == 1
    error('The matching requires at least two frames');
end

results = [];
for index = 1:(frameCount-1)
    first = frames(:,:,index);
    second = frames(:,:,index+1);
    % Prepare the ref object (world coordinate)
    firstRefObj = imref2d(size(first));
    secondRefObj = imref2d(size(second));
    % Detect features
    firstPoints = detectSURFFeatures(first,'MetricThreshold', ...
        metricThreshold,'NumOctaves',numOctave,'NumScaleLevels',scaleLevel);
    secondPoints = detectSURFFeatures(second,'MetricThreshold', ...
        metricThreshold,'NumOctaves',numOctave,'NumScaleLevels',scaleLevel);
    % Extract features and descriptors
    [firstFeatures,firstValidPoints] = extractFeatures(first, ...
        firstPoints,'Upright',false);
    [secondFeatures,secondValidPoints] = extractFeatures(second, ...
        secondPoints,'Upright',false);
    % Match the extracted features
    indexPairs = matchFeatures(firstFeatures,secondFeatures, ...
        'MatchThreshold',matchThreshold,'MaxRatio',maxRatio);
    % Extract the valid feature points
    firstMatchedPoints = firstValidPoints(indexPairs(:,1));
    secondMatchedPoints = secondValidPoints(indexPairs(:,2));
    
    % Create the structure for matched sequences
    rec.FirstMatchedFeatures = firstMatchedPoints;
    rec.SecondMatchedFeatures = secondMatchedPoints;
    % Apply transformation - Results may not be identical between runs 
    %because of the randomized nature of the algorithm.
    [transMatrix, ~, ~, status] = estimateGeometricTransform(secondMatchedPoints, ...
        firstMatchedPoints,'projective');
    if status == 1
        warning(['features of frame (', str2double(index), ') do not contain enough points']);
        continue;
    elseif status == 2
        warning(['For frame (', str2double(index), '), Not enough inliers have been found.']);
        continue;
    end
    
    rec.Transformation = transMatrix;

    rec.SpatialRefObj = firstRefObj;
    rec.CurrentRefObj = secondRefObj;
    rec.FrameIndex = index + 1;
    rec.RefFrameIndex = index;
    
    results = [results rec];
end

exeTime = cputime - t;
