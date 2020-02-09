
windowSize = 3;

% Address of directory containing the files.
dir_address = '/home-local2/panoo.extra.nobkp/Datasets/TORNGATS_Optical_Gas/2040_exp01';
%dir_address = '/home-local2/panoo.extra.nobkp/Datasets/TORNGATS_Optical_Gas/2038_exp02';
% File extensions should be considered.
file_extension = '*.png';

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
        orig = orig(10:250, 300:700, :);
        frames = cat(3, frames, orig);
    end
end

no_ref = min(frames, [], 3);

h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

of = opticalFlowFarneback;
mask = [];
last = frames(:,:,1);

threshold = 100;

for i = 2:1:size(frames,3)
    frm = frames(:,:,i);
    diffrm = frm - last;
    tmp = adaptthresh(diffrm) .* 255;
    %tmp(tmp < mean(tmp(:))) = 0;
    tmp = imbinarize(tmp);
    %flow = estimateFlow(of,tmp);
    %mask = cat(3, mask, flow.Magnitude);
    
    %res = frm;
    %res(tmp ~= 0) = tmp(tmp ~= 0);
    %imagesc(flow.Magnitude);
    imshow(tmp);
    %hold on
    %plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
    %image(flow.Magnitude);
    %hold off
    pause(10^-3)
    %last = frm;
end