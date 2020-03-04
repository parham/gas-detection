

clear;
clc;

%% Check Computer Vision Toolbox license
if ~phm.core.phmSystemCheck.checkCVLicense
    error('Computer Vision Toolbox is required!');
end

%% Load configuration
phmConfig = phm.core.phmJsonConfigBucket('./algorithms/image_stitching_v1/image_stitching_v1.json');
progressbar.textprogressbar('Load Configuration: ');
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% System configuration check
if parallel.gpu.GPUDevice.isAvailable()
    disp('The installed GPU on this station can be used for data processing.');
end
progressbar.textprogressbar('Check System Configuration: ');
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Data Source initialization
progressbar.textprogressbar('Data Source initialization: ');
dsConfig = phmConfig.getConfig('data_source');
imgds = imageDatastore(dsConfig.datasetPath, ...
    'FileExtensions', dsConfig.fileExtension);
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Steps initialization
progressbar.textprogressbar('Pipeline steps initialization: ');

progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');