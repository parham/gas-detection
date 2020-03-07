

clear;
clc;

showFootage = true;

%% Check Computer Vision Toolbox license
progressbar.textprogressbar('Check Computer Vision Toolbox license: ');
progressbar.textprogressbar(100);
if ~phm.utils.phmSystemUtils.checkCVLicense
    progressbar.textprogressbar(' failed');
    error('Computer Vision Toolbox is required!');
else
    progressbar.textprogressbar(' passed');
end

%% Load configuration
progressbar.textprogressbar('Load Configuration: ');
configPath = sprintf('./algorithms/image_stitching_v1/image_stitching_%s_v1.json', ...
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
prepStep = msv1PreprocessingStep(phmConfig.getConfig('preprocessing'));
matStep = msv1MatchingStep(phmConfig.getConfig('matching'));

%% Frame processing and matching
progressbar.textprogressbar('Pipeline steps initialization: ');
figure('Name','Stitching result viewer'); 

matches = cell(1, length(imgds.Files));
index = 1;
while hasdata(imgds)
    frame = read(imgds);
    prepres = prepStep.process(frame);
    [fmat, status] = matStep.process(prepres);
    if status == 1
        warning(['features of frame (', str2double(index), ') do not contain enough points']);
        continue;
    elseif status == 2
        warning(['For frame (', str2double(index), '), Not enough inliers have been found.']);
        continue;
    end
    
    matches{index} = fmat;
    index = index + 1;
    
    if isfield(fmat, 'Transformation')
        RegisteredImage = imwarp(fmat.Frame, fmat.Ref2d, fmat.Transformation);
    else
        RegisteredImage = fmat.Frame;
    end
    
    if showFootage
        % Display the current frame and its processing steps
        montage({frame, prepres, RegisteredImage},'BorderSize', [3 3]);
        pause(10^-3);
    end
    progressbar.textprogressbar((index / length(imgds.Files)) * 100.0);
end
progressbar.textprogressbar(100);
progressbar.textprogressbar(' done');

%% Image registeration
figure('Name','Registering result viewer'); 
regStep = msv1RegistrationStep(phmConfig.getConfig('register'));
[envConfig] = regStep.preprocess(matches);
for index = 1:length(matches)
    frame = matches{index};
    registered = regStep.process(frame, envConfig);
    imshow(registered);
    pause(10^-3);
end









