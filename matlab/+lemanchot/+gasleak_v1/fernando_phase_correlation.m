function [registeredMoving] = fernando_phase_correlation(ref, moving)
%FERNANDO_PHASE_CORRELATION Summary of this function goes here
%   Based on Fernando Lopez's implementation

if length(size(ref)) > 2
    error('Reference image must be plained!');
end

if length(size(ref)) > 2
    error('targeted image must be plained!');
end

% Estimate the registration required to bring these two images into 
% alignment. imregcorr returns an affine2d object that defines the 
% transformation.

tformEstimate = imregcorr(moving,ref, 'similarity');

% Apply the estimated geometric transform to the misaligned image. 
% Specify 'OutputView' to make sure the registered image is the same size as
% the reference image. Display the original image and the registered image 
% side-by-side. 
% You can see that imregcorr has done a good job handling the rotation and 
% scaling differences between the images. The registered image, movingReg, 
% is very close to being aligned with the original image, fixed. 
% But there is some misalignment left. imregcorr can handle rotation and 
% scale distortions well, but not shear distortion.
% 
% ref2dFixed = imref2d(size(ref));
% movingReg = imwarp(moving,tformEstimate,'OutputView',ref2dFixed);

% To finish the registration, use imregister, passing the estimated 
% transformation returned by imregcorr as the initial condition. imregister 
% is more effective if the two images are roughly in alignment at the start 
% of the operation. The transformation estimated by imregcorr provides this 
% information for imregister. The example uses the default optimizer and 
% metric values for a registration of two images taken with the same sensor 
% ( 'monomodal' ).

[optimizer, metric] = imregconfig('monomodal');
registeredMoving = imregister(moving, ref,...
    'affine', optimizer, metric,'InitialTransformation',tformEstimate);