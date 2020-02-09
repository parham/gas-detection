
clear

windowSize = 3;

% Address of directory containing the files.
%dir_address = '/gel/usr/panoo/Projects/xd-espace/data/reflection_hand';
dir_address = '/home-local2/panoo.extra.nobkp/Datasets/OTCBVS Benchmark/OSU Thermal Pedestrian Database/00010';
% File extensions should be considered.
%file_extension = '*.jpg';
file_extension = '*.bmp';

flist = fullfile(dir_address, file_extension);

% List of files in the determined directory
files = dir(flist);
% Go through the retrieved files
frames = [];
for index = 1:length(files)
    f = files(index);
    % Check the path to avoid current and parent directory
    if ~f.isdir
        fpath = fullfile(dir_address, f.name);
        orig = imread(fpath);
        frames = cat(3, frames, orig);
    end
end

no_ref = min(frames, [], 3);
%no_ref = median(frames, 3);
%imshow(no_ref)

h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

of = opticalFlowFarneback;
%of = opticalFlowLK %('NoiseThreshold',0.009);

v = VideoWriter('newfile.avi');
open(v);

mask = [];
for i = 1:1:size(frames,3)
    frm = frames(:,:,i);
    flow = estimateFlow(of,frm);
    mask = cat(3, mask, flow.Magnitude);
    imshow(frm)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
    %image(flow.Magnitude);
    hold off
    pause(10^-3)
    
    fm = getframe(h);
    [X, mp] = frame2im(fm);
    writeVideo(v,X)
end

% Integrate the mask layers
integrated_mask = sum(mask,3) / size(mask,3);

% Normalize input data to range in [0,1].
Xmin = min(integrated_mask(:));
Xmax = max(integrated_mask(:));
if isequal(Xmax,Xmin)
    X = 0 * integrated_mask;
else
    X = (integrated_mask - Xmin) ./ (Xmax - Xmin);
end

% Threshold image - global threshold
BW = imbinarize(X);

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;

overlabed = imoverlay(max(frames,[],3),BW,'cyan');

tmpCenter = floor(windowSize / 2);
% Remove the reflection
result = frames(:,:,1);
for i = 1:size(frames,1)
    for j = 1:size(frames,2)
        if BW(i,j) == 1
            pvalue = min(frames(i,j,:));
            result(i,j) = pvalue;
        end 
    end
end

subplot(1,2,1), imshow(result);
subplot(1,2,2), imshow(overlabed);

for i = 1:40
    fm = getframe(h);
    [X, mp] = frame2im(fm);
    writeVideo(v,X)
end

close(v);


