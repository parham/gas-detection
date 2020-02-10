function [result, exeTime] = preprocessing(frames, props)
%PREPROCESSING all the required preprocessing steps are executed here
t = cputime;

frameCount = size(frames, 4);
result = zeros([size(frames,1) size(frames,2) frameCount], 'like', frames);
result = double(result);

% STEP #1: Flat the image and adjust the value levels
for index = 1:frameCount
    frame = frames(:,:,:,index);
    if size(frame,3) > 1
        frame = mean(frame,3);
    end
    frame = mat2gray(frame);
    result(:,:,index) = frame;
end

% STEP #2: adjust the moving frame based on the histogram of the reference
% frame
previousFrame = result(:,:,1);
for index = 2:frameCount
    frame = result(:,:,index);
    % Correct illumination differences between the moving and fixed images
    % using histogram matching. This is a common pre-processing step.
    frame = imhistmatch(frame,previousFrame);
    result(:,:,index) = frame;
end

exeTime = cputime - t;

end

