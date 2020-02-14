%% Monocular Visual Odometry
% Visual odometry is the process of determining the location and orientation
% of a camera by analyzing a sequence of images. Visual odometry is used in
% a variety of applications, such as mobile robots, self-driving cars, and 
% unmanned aerial vehicles. This example shows you how to estimate the
% trajectory of a single calibrated camera from a sequence of images. 

% Copyright 2016 The MathWorks, Inc. 

%% Overview
% This example shows how to estimate the trajectory of a calibrated camera
% from a sequence of 2-D views. This example uses images from the New Tsukuba
% Stereo Dataset created at Tsukuba University's CVLAB. (http://cvlab.cs.tsukuba.ac.jp). 
% The dataset consists of synthetic images, generated using computer graphics,
% and includes the ground truth camera poses.
%
% Without additional information, the trajectory of a monocular camera can 
% only be recovered up to an unknown scale factor. Monocular visual odometry 
% systems used on mobile robots or autonomous vehicles typically obtain the
% scale factor from another sensor (e.g. wheel odometer or GPS), or from an
% object of a known size in the scene. This example computes the scale 
% factor from the ground truth.
%
% The example is divided into three parts:
% 
% # *Estimating the pose of the second view relative to the first view.*
% Estimate the pose of the second view by estimating the essential matrix 
% and decomposing it into camera location and orientation. 
% # *Bootstrapping estimating camera trajectory using global bundle adjustment.* 
% Eliminate outliers using the epipolar constraint. Find 3D-to-2D 
% correspondences between points triangulated from the previous two views 
% and the current view. Compute the world camera pose for the current view 
% by solving the perspective-n-point (PnP) problem. Estimating the camera 
% poses inevitably results in errors, which accumulate over time. This 
% effect is called _the drift_. To reduce the drift, the example refines 
% all the poses estimated so far using bundle adjustment.
% # *Estimating remaining camera trajectory using windowed bundle adjustment.*
% With each new view the time it takes to refine all the poses increases. 
% Windowed bundle adjustment is a way to reduce computation time by only 
% optimizing the last _n_ views, rather than the entire trajectory. 
% Computation time is further reduced by not calling bundle adjustment 
% for every view. 

%% Read Input Image Sequence and Ground Truth
% This example uses images from the New Tsukuba Stereo Dataset created at 
% Tsukuba University's CVLAB. (http://cvlab.cs.tsukuba.ac.jp). If you use 
% these images in your own work or publications, please cite the following 
% papers:
%
% [1] Martin Peris Martorell, Atsuto Maki, Sarah Martull, Yasuhiro Ohkawa,
%     Kazuhiro Fukui, "Towards a Simulation Driven Stereo Vision System". 
%     Proceedings of ICPR, pp.1038-1042, 2012.
% 
% [2] Sarah Martull, Martin Peris Martorell, Kazuhiro Fukui, "Realistic CG 
%     Stereo Image Dataset with Ground Truth Disparity Maps", Proceedings of
%     ICPR workshop TrakMark2012, pp.40-42, 2012.

images = imageDatastore(fullfile(toolboxdir('vision'), 'visiondata', ...
    'NewTsukuba'));

% Create the camera parameters object using camera intrinsics from the 
% New Tsukuba dataset.
K = [615 0 320; 0 615 240; 0 0 1]';
cameraParams = cameraParameters('IntrinsicMatrix', K);

% Load ground truth camera poses.
load(fullfile(toolboxdir('vision'), 'visiondata', ...
    'visualOdometryGroundTruth.mat'));

%% Create a View Set Containing the First View of the Sequence
% Use a |viewSet| object to store and manage the image points and the
% camera pose associated with each view, as well as point matches between
% pairs of views. Once you populate a |viewSet| object, you can use it to
% find point tracks across multiple views and retrieve the camera poses to
% be used by |triangulateMultiview| and |bundleAdjustment| functions.

% Create an empty viewSet object to manage the data associated with each view.
vSet = viewSet;

% Read and display the first image.
Irgb = readimage(images, 1);
player = vision.VideoPlayer('Position', [20, 400, 650, 510]);
step(player, Irgb);

%%
% Convert to gray scale and undistort. In this example, undistortion has no 
% effect, because the images are synthetic, with no lens distortion. However, 
% for real images, undistortion is necessary.

prevI = undistortImage(rgb2gray(Irgb), cameraParams); 

% Detect features. 
prevPoints = detectSURFFeatures(prevI, 'MetricThreshold', 500);

% Select a subset of features, uniformly distributed throughout the image.
numPoints = 150;
prevPoints = selectUniform(prevPoints, numPoints, size(prevI));

% Extract features. Using 'Upright' features improves matching quality if 
% the camera motion involves little or no in-plane rotation.
prevFeatures = extractFeatures(prevI, prevPoints, 'Upright', true);

% Add the first view. Place the camera associated with the first view
% at the origin, oriented along the Z-axis.
viewId = 1;
vSet = addView(vSet, viewId, 'Points', prevPoints, 'Orientation', eye(3),...
    'Location', [0 0 0]);

%% Plot Initial Camera Pose
% Create two graphical camera objects representing the estimated and the
% actual camera poses based on ground truth data from the New Tsukuba
% dataset.

% Setup axes.
figure
axis([-220, 50, -140, 20, -50, 300]);

% Set Y-axis to be vertical pointing down.
view(gca, 3);
set(gca, 'CameraUpVector', [0, -1, 0]);
camorbit(gca, -120, 0, 'data', [0, 1, 0]);

grid on
xlabel('X (cm)');
ylabel('Y (cm)');
zlabel('Z (cm)');
hold on

% Plot estimated camera pose. 
cameraSize = 7;
camEstimated = plotCamera('Size', cameraSize, 'Location',...
    vSet.Views.Location{1}, 'Orientation', vSet.Views.Orientation{1},...
    'Color', 'g', 'Opacity', 0);

% Plot actual camera pose.
camActual = plotCamera('Size', cameraSize, 'Location', ...
    groundTruthPoses.Location{1}, 'Orientation', ...
    groundTruthPoses.Orientation{1}, 'Color', 'b', 'Opacity', 0);

% Initialize camera trajectories.
trajectoryEstimated = plot3(0, 0, 0, 'g-');
trajectoryActual    = plot3(0, 0, 0, 'b-');

legend('Estimated Trajectory', 'Actual Trajectory');
title('Camera Trajectory');

%% Estimate the Pose of the Second View
% Detect and extract features from the second view, and match them to the
% first view using <matlab:edit('helperDetectAndMatchFeatures.m') helperDetectAndMatchFeatures>. 
% Estimate the pose of the second view relative to the first view using 
% <matlab:edit('helperEstimateRelativePose.m') helperEstimateRelativePose>,
% and add it to the |viewSet|.

% Read and display the image.
viewId = 2;
Irgb = readimage(images, viewId);
step(player, Irgb);

% Convert to gray scale and undistort.
I = undistortImage(rgb2gray(Irgb), cameraParams);

% Match features between the previous and the current image.
[currPoints, currFeatures, indexPairs] = helperDetectAndMatchFeatures(...
    prevFeatures, I);

% Estimate the pose of the current view relative to the previous view.
[orient, loc, inlierIdx] = helperEstimateRelativePose(...
    prevPoints(indexPairs(:,1)), currPoints(indexPairs(:,2)), cameraParams);

% Exclude epipolar outliers.
indexPairs = indexPairs(inlierIdx, :);
    
% Add the current view to the view set.
vSet = addView(vSet, viewId, 'Points', currPoints, 'Orientation', orient, ...
    'Location', loc);
% Store the point matches between the previous and the current views.
vSet = addConnection(vSet, viewId-1, viewId, 'Matches', indexPairs);

%%
% The location of the second view relative to the first view can only be
% recovered up to an unknown scale factor. Compute the scale factor from 
% the ground truth using <matlab:edit('helperNormalizeViewSet.m') helperNormalizeViewSet>,
% simulating an external sensor, which would be used in a typical monocular
% visual odometry system.

vSet = helperNormalizeViewSet(vSet, groundTruthPoses);

%%
% Update camera trajectory plots using 
% <matlab:edit('helperUpdateCameraPlots.m') helperUpdateCameraPlots> and
% <matlab:edit('helperUpdateCameraTrajectories.m') helperUpdateCameraTrajectories>.

helperUpdateCameraPlots(viewId, camEstimated, camActual, poses(vSet), ...
    groundTruthPoses);
helperUpdateCameraTrajectories(viewId, trajectoryEstimated, trajectoryActual,...
    poses(vSet), groundTruthPoses);

prevI = I;
prevFeatures = currFeatures;
prevPoints   = currPoints;

%% Bootstrap Estimating Camera Trajectory Using Global Bundle Adjustment
% Find 3D-to-2D correspondences between world points triangulated from the 
% previous two views and image points from the current view. Use 
% <matlab:edit('helperFindEpipolarInliers.m') helperFindEpipolarInliers> 
% to find the matches that satisfy the epipolar constraint, and then use
% <matlab:edit('helperFind3Dto2DCorrespondences.m') helperFind3Dto2DCorrespondences>
% to triangulate 3-D points from the previous two views and find the
% corresponding 2-D points in the current view.
%
% Compute the world camera pose for the current view by solving the 
% perspective-n-point (PnP) problem using |estimateWorldCameraPose|. For 
% the first 15 views, use global bundle adjustment to refine the entire
% trajectory. Using global bundle adjustment for a limited number of views
% bootstraps estimating the rest of the camera trajectory, and it is not
% prohibitively expensive.

for viewId = 3:15
    % Read and display the next image
    Irgb = readimage(images, viewId);
    step(player, Irgb);
    
    % Convert to gray scale and undistort.
    I = undistortImage(rgb2gray(Irgb), cameraParams);
    
    % Match points between the previous and the current image.
    [currPoints, currFeatures, indexPairs] = helperDetectAndMatchFeatures(...
        prevFeatures, I);
      
    % Eliminate outliers from feature matches.
    inlierIdx = helperFindEpipolarInliers(prevPoints(indexPairs(:,1)),...
        currPoints(indexPairs(:, 2)), cameraParams);
    indexPairs = indexPairs(inlierIdx, :);
    
    % Triangulate points from the previous two views, and find the 
    % corresponding points in the current view.
    [worldPoints, imagePoints] = helperFind3Dto2DCorrespondences(vSet,...
        cameraParams, indexPairs, currPoints);
    
    % Since RANSAC involves a stochastic process, it may sometimes not
    % reach the desired confidence level and exceed maximum number of
    % trials. Disable the warning when that happens since the outcomes are
    % still valid.
    warningstate = warning('off','vision:ransac:maxTrialsReached');
    
    % Estimate the world camera pose for the current view.
    [orient, loc] = estimateWorldCameraPose(imagePoints, worldPoints, ...
        cameraParams, 'Confidence', 99.99, 'MaxReprojectionError', 0.8);
    
    % Restore the original warning state
    warning(warningstate)
    
    % Add the current view to the view set.
    vSet = addView(vSet, viewId, 'Points', currPoints, 'Orientation', orient, ...
        'Location', loc);
    
    % Store the point matches between the previous and the current views.
    vSet = addConnection(vSet, viewId-1, viewId, 'Matches', indexPairs);    
    
    tracks = findTracks(vSet); % Find point tracks spanning multiple views.
        
    camPoses = poses(vSet);    % Get camera poses for all views.
    
    % Triangulate initial locations for the 3-D world points.
    xyzPoints = triangulateMultiview(tracks, camPoses, cameraParams);
    
    % Refine camera poses using bundle adjustment.
    [~, camPoses] = bundleAdjustment(xyzPoints, tracks, camPoses, ...
        cameraParams, 'PointsUndistorted', true, 'AbsoluteTolerance', 1e-9,...
        'RelativeTolerance', 1e-9, 'MaxIterations', 300);
        
    vSet = updateView(vSet, camPoses); % Update view set.
    
    % Bundle adjustment can move the entire set of cameras. Normalize the
    % view set to place the first camera at the origin looking along the
    % Z-axes and adjust the scale to match that of the ground truth.
    vSet = helperNormalizeViewSet(vSet, groundTruthPoses);
    
    % Update camera trajectory plot.
    helperUpdateCameraPlots(viewId, camEstimated, camActual, poses(vSet), ...
        groundTruthPoses);
    helperUpdateCameraTrajectories(viewId, trajectoryEstimated, ...
        trajectoryActual, poses(vSet), groundTruthPoses);
    
    prevI = I;
    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
end

%% Estimate Remaining Camera Trajectory Using Windowed Bundle Adjustment
% Estimate the remaining camera trajectory by using windowed bundle 
% adjustment to only refine the last 15 views, in order to limit the amount 
% of computation. Furthermore, bundle adjustment does not have to be called
% for every view, because |estimateWorldCameraPose| computes the pose in the
% same units as the 3-D points. This section calls bundle adjustment for
% every 7th view. The window size and the frequency of calling bundle
% adjustment have been chosen experimentally.

for viewId = 16:numel(images.Files)
    % Read and display the next image
    Irgb = readimage(images, viewId);
    step(player, Irgb);
    
    % Convert to gray scale and undistort.
    I = undistortImage(rgb2gray(Irgb), cameraParams);

    % Match points between the previous and the current image.
    [currPoints, currFeatures, indexPairs] = helperDetectAndMatchFeatures(...
        prevFeatures, I);    
          
    % Triangulate points from the previous two views, and find the 
    % corresponding points in the current view.
    [worldPoints, imagePoints] = helperFind3Dto2DCorrespondences(vSet, ...
        cameraParams, indexPairs, currPoints);

    % Since RANSAC involves a stochastic process, it may sometimes not
    % reach the desired confidence level and exceed maximum number of
    % trials. Disable the warning when that happens since the outcomes are
    % still valid.
    warningstate = warning('off','vision:ransac:maxTrialsReached');
    
    % Estimate the world camera pose for the current view.
    [orient, loc] = estimateWorldCameraPose(imagePoints, worldPoints, ...
        cameraParams, 'MaxNumTrials', 5000, 'Confidence', 99.99, ...
        'MaxReprojectionError', 0.8);
    
    % Restore the original warning state
    warning(warningstate)
    
    % Add the current view and connection to the view set.
    vSet = addView(vSet, viewId, 'Points', currPoints, 'Orientation', orient, ...
        'Location', loc);
    vSet = addConnection(vSet, viewId-1, viewId, 'Matches', indexPairs);
        
    % Refine estimated camera poses using windowed bundle adjustment. Run 
    % the optimization every 7th view.
    if mod(viewId, 7) == 0        
        % Find point tracks in the last 15 views and triangulate.
        windowSize = 15;
        startFrame = max(1, viewId - windowSize);
        tracks = findTracks(vSet, startFrame:viewId);
        camPoses = poses(vSet, startFrame:viewId);
        [xyzPoints, reprojErrors] = triangulateMultiview(tracks, camPoses, ...
            cameraParams);
                                
        % Hold the first two poses fixed, to keep the same scale. 
        fixedIds = [startFrame, startFrame+1];
        
        % Exclude points and tracks with high reprojection errors.
        idx = reprojErrors < 2;
        
        [~, camPoses] = bundleAdjustment(xyzPoints(idx, :), tracks(idx), ...
            camPoses, cameraParams, 'FixedViewIDs', fixedIds, ...
            'PointsUndistorted', true, 'AbsoluteTolerance', 1e-9,...
            'RelativeTolerance', 1e-9, 'MaxIterations', 300);
        
        vSet = updateView(vSet, camPoses); % Update view set.
    end
    
    % Update camera trajectory plot.
    helperUpdateCameraPlots(viewId, camEstimated, camActual, poses(vSet), ...
        groundTruthPoses);    
    helperUpdateCameraTrajectories(viewId, trajectoryEstimated, ...
        trajectoryActual, poses(vSet), groundTruthPoses);    
    
    prevI = I;
    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
end

hold off

%% Summary
% This example showed how to estimate the trajectory of a calibrated
% monocular camera from a sequence of views. Notice that the estimated
% trajectory does not exactly match the ground truth. Despite the
% non-linear refinement of camera poses, errors in camera pose estimation
% accumulate, resulting in drift. In visual odometry systems this problem is
% typically addressed by fusing information from multiple sensors, and by
% performing loop closure.

%% References
%
% [1] Martin Peris Martorell, Atsuto Maki, Sarah Martull, Yasuhiro Ohkawa,
%     Kazuhiro Fukui, "Towards a Simulation Driven Stereo Vision System". 
%     Proceedings of ICPR, pp.1038-1042, 2012.
% 
% [2] Sarah Martull, Martin Peris Martorell, Kazuhiro Fukui, "Realistic CG 
%     Stereo Image Dataset with Ground Truth Disparity Maps", Proceedings of
%     ICPR workshop TrakMark2012, pp.40-42, 2012.
%
% [3] M.I.A. Lourakis and A.A. Argyros (2009). "SBA: A Software Package for
%     Generic Sparse Bundle Adjustment". ACM Transactions on Mathematical
%     Software (ACM) 36 (1): 1-30.
%
% [4] R. Hartley, A. Zisserman, "Multiple View Geometry in Computer
%     Vision," Cambridge University Press, 2003.
%
% [5] B. Triggs; P. McLauchlan; R. Hartley; A. Fitzgibbon (1999). "Bundle
%     Adjustment: A Modern Synthesis". Proceedings of the International
%     Workshop on Vision Algorithms. Springer-Verlag. pp. 298-372.
%
% [6] X.-S. Gao, X.-R. Hou, J. Tang, and H.-F. Cheng, "Complete Solution 
%     Classification for the Perspective-Three-Point Problem," IEEE Trans. 
%     Pattern Analysis and Machine Intelligence, vol. 25, no. 8, pp. 930-943, 
%     2003.
