clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

%===============================================================================
% Read in gray scale demo image.
folder = pwd; % Determine where demo folder is (works with all versions).
baseFileName = './ellipseDetection/sample_2.tif';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% The file doesn't exist -- didn't find it there in that folder.
	% Check the entire search path (other folders) for the file by stripping off the folder.
	fullFileNameOnSearchPath = baseFileName; % No path this time.
	if ~exist(fullFileNameOnSearchPath, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
rgbImage = imread(fullFileName);
% Display the image.
subplot(2, 3, 1);
imshow(rgbImage, []);
title('Original Image', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
hp = impixelinfo();


% Get the dimensions of the image.
% numberOfColorChannels should be = 1 for a gray scale image, and 3 for an RGB color image.
[rows, columns, numberOfColorChannels] = size(rgbImage)
if numberOfColorChannels > 1
	% It's not really gray scale like we expected - it's color.
	% Use weighted sum of ALL channels to create a gray scale image.
	% 		grayImage = rgb2gray(rgbImage);
	% ALTERNATE METHOD: Convert it to gray scale by taking only the green channel,
	% which in a typical snapshot will be the least noisy channel.
	grayImage = rgbImage(:, :, 2); % Take green channel.
else
	grayImage = rgbImage; % It's already gray scale.
end
% Now it's gray scale with range of 0 to 255.

% Display the image.
subplot(2, 3, 1);
imshow(rgbImage, []);
title('Original Image', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
hp = impixelinfo();

%------------------------------------------------------------------------------
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;

% Binarize the image
% Get the mask where the region is solid.
binaryImage = grayImage ~= 255;
% Fill it and take the largest blob:
binaryImage = imfill(binaryImage, 'holes');
binaryImage = bwareafilt(binaryImage, 1);
% Display the image.
subplot(2, 3, 2);
imshow(binaryImage, []);
title('Initial Binary Image', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
hp = impixelinfo();
drawnow;

% Get a new binary image where it only includes "wide" rows.
regionWidth = zeros(rows, 1);
for row = 1 : rows
	thisWidth = find(binaryImage(row, :), 1, 'last') - find(binaryImage(row, :), 1, 'first');
	if ~isempty(thisWidth)
		regionWidth(row) = thisWidth;
	end
end
% Plot widths.
subplot(2, 3, [3,6]);
plot(regionWidth, 'b-', 'LineWidth', 2);
grid on;
title('Region Width vs. line down the image', 'FontSize', fontSize);
xlabel('Row', 'FontSize', fontSize);
ylabel('Width in pixels', 'FontSize', fontSize);
% Define what "too narrow" is
minWidth = 20;
binaryImage(regionWidth < minWidth, :) = false; % Erase too narrow rows.

% Display the image.
subplot(2, 3, 4);
imshow(binaryImage, []);
title('Final Binary Image', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
hp = impixelinfo();
drawnow;

% Measure elliptical properties
props = regionprops(binaryImage, 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Centroid', 'Perimeter')

%------------------------------------------------------------------
% Create an ellipse with specified
% semi-major and semi-minor axes, center, and image size.
% From the FAQ: https://matlab.wikia.com/wiki/FAQ#How_do_I_create_an_ellipse.3F
xCenter = props.Centroid(1);
yCenter = props.Centroid(2);
xRadius = props.MinorAxisLength / 2;
yRadius = props.MajorAxisLength / 2;
% Make an angle array of about the same number of angles as there are pixels in the perimeter.
theta = linspace(0, 2*pi, ceil(props.Perimeter));
x = xRadius * cos(theta) + xCenter;
y = yRadius * sin(theta) + yCenter;
% Now we might need to rotate the coordinates slightly.  Make a rotation matrix
% Reference: https://en.wikipedia.org/wiki/Rotation_matrix
angleInDegrees = props.Orientation - 90;
rotationMatrix = [cosd(angleInDegrees), -sind(angleInDegrees); sind(angleInDegrees), cosd(angleInDegrees)];
% Now do the rotation
xy = [x', y'];
xyRotated = xy * rotationMatrix;
x = xyRotated(:, 1);
y = xyRotated(:, 2);
subplot(2, 3, 5);
imshow(rgbImage, []);
title('Image with Fitted Ellipse', 'FontSize', fontSize, 'Interpreter', 'None');
axis('on', 'image');
hold on;
plot(x, y, 'r-', 'LineWidth', 2);
plot(xCenter, yCenter, 'r+', 'LineWidth', 2, 'MarkerSize', 13); % Put a cross at teh ellipse center.
axis('image', 'on');
grid on;
% Print results
fprintf('X Center = column #%.1f\n', xCenter);
fprintf('Y Center = row #%.1f\n', yCenter);
fprintf('Minor Axis Length = %.1f\n', xRadius);
fprintf('Major Axis Length = %.1f\n', yRadius);
fprintf('Orientation = %.1f degrees\n', angleInDegrees);

uiwait(helpdlg('Done!'));


