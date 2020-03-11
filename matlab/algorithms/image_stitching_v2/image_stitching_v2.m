

clear;
clc;

showFootage = false;

%% Load configuration
progressbar.textprogressbar('Load Configuration: ');
configPath = sprintf('./algorithms/image_stitching_v2/image_stitching_%s_v2.json', ...
    phm.utils.phmSystemUtils.getOSUser);
disp(['Config file: ', configPath]);
if ~isfile(configPath)
    progressbar.textprogressbar(100);
    progressbar.textprogressbar(' failed');
    error('Config File does not exist!')
end
phmConfig = phm.core.phmJsonConfigBucket(configPath);
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
prepStep = msv2PreprocessingStep(phmConfig.getConfig('preprocessing'));
matStep = msv2MatchingStep(phmConfig.getConfig('matching'));
regStep = msv2RegistrationStep(phmConfig.getConfig('register'));
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Frame processing and matching
progressbar.textprogressbar('Frame matching step: ');
figure('Name','Stitching result viewer'); 
matches = cell(1, length(imgds.Files));

index = 1;
while hasdata(imgds)
    frame = read(imgds);
    % Visual cell initialization
    viscell = {};
    viscell{end + 1} = frame;
    %%%%
    
    prepres = prepStep.process(frame);
    viscell{end + 1} = prepres;
    
    match = matStep.process(prepres);
    matches{index} = match;
    match.AbsoluteTransformation.T
    index = index + 1;
    
    if showFootage
        % Display the current frame and its processing steps
        montage(viscell,'BorderSize', [3 3]);
        pause(10^-3);
    end
    progressbar.textprogressbar((index / length(imgds.Files)) * 100.0);
end
progressbar.textprogressbar(' done');

%% Frame registration
disp('Perform pre-processing steps for the registration');
[envConfig, matches] = regStep.preprocess(matches);

progressbar.textprogressbar('Frame registration: ');
for index = 1:length(matches)
    frame = regStep.process(matches{index}, envConfig);
    progressbar.textprogressbar((index / length(matches)) * 100.0);
    
    imshow(frame.TransformedFrame);
    pause(10^-3);
end
progressbar.textprogressbar(' done');
