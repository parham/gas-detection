

dirPath = '/home-local2/panoo.extra.nobkp/Datasets/STM X8500 2020-02-21/Track_000013_TIFF16/';
fileExt = '*.tif';
disp(['Dataset --> ', dirPath]);

flist = fullfile(dirPath, fileExt);
fpaths = dir(flist);

if isempty(flist)
    error('There is no file to read');
end
files = {fpaths(:).name};

ind = 1;
for index = 1:length(files)
    fnm = files{index};
    parts = split(fnm,'_');
    a = parts{2};
    nm = strrep(a,'.tif','');
    dig = str2num(nm);
    txt = sprintf('%07d',dig);
    txt = strcat(txt,'.tif');
    orig = fullfile(dirPath,fnm);
    des = fullfile(dirPath,txt);
    disp(des)
    ind = ind + 1;
    movefile(orig,des);
end
disp(num2str(ind));