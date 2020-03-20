% helperNormalizeViewSet Translate and scale camera poses to align with ground truth
%  vSet = helperNormalizedViewSet(vSet, groundTruth) returns a view set
%  with the camera poses translated to put the first camera at the origin
%  looking along the Z axes, and scaled to match the scale of the ground
%  truth. vSet is a viewSet object. groundTruth is a table containing the
%  actual camera poses.
%
%  See also viewSet, table

% Copyright 2016 The MathWorks, Inc. 

function vSet = helperNormalizeViewSet(vSet, groundTruth)

camPoses = poses(vSet);

% Move the first camera to the origin.
locations = cat(1, camPoses.Location{:});
locations = locations - locations(1, :);

locationsGT  = cat(1, groundTruth.Location{1:height(camPoses)});
magnitudes   = sqrt(sum(locations.^2, 2));
magnitudesGT = sqrt(sum(locationsGT.^2, 2));
scaleFactor = median(magnitudesGT(2:end) ./ magnitudes(2:end));

% Scale the locations
locations = locations .* scaleFactor;

camPoses.Location = num2cell(locations, 2);

% Rotate the poses so that the first camera points along the Z-axis
R = camPoses.Orientation{1}';
for i = 1:height(camPoses)
    camPoses.Orientation{i} = camPoses.Orientation{i} * R;
end

vSet = updateView(vSet, camPoses);
