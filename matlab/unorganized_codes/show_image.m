h = figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);

% Address of directory containing the files.
dir_address = '/home-local2/panoo.extra.nobkp/Datasets/MY-DATASET/gas';
% File extensions should be considered.
file_extension = '*.tiff';

flist = fullfile(dir_address, file_extension);

% List of files in the determined directory
files = dir(flist);

last = [];
for index = 1:length(files)
    f = files(index);
    % Check the path to avoid current and parent directory
    if ~f.isdir
        fpath = fullfile(dir_address, f.name);
        orig = imread(fpath);
        if last
            orig = orig - last;
        end
        imagesc(orig);
        last = orig;
        pause(10^-3)
    end
end