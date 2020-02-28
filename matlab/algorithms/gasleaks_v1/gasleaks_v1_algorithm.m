
clear;
clc;

%% Load configuration
phmConfig = phm.core.phmJsonConfigBucket('./algorithms/gasleaks_v1/gasleak_v1_configs.json');
showFootage = true;

%% System configuration check
if parallel.gpu.GPUDevice.isAvailable()
    disp('The installed GPU on this station can be used for data processing.');
end

%% Data Source initialization
dsConfig = phmConfig.getConfig('data_source');
imgds = imageDatastore(dsConfig.datasetPath, ...
    'FileExtensions', dsConfig.fileExtension);

%% Steps initialization
prepStep = glv1Preprocessing(phmConfig.getConfig('preprocessing'));


% Processing for Gas leak detection
while hasdata(imgds)
    frame = read(imgds);
    prepres = prepStep.process(frame);
    
    if showFootage
        imshow(prepres);
        pause(10^-3);
    end
end