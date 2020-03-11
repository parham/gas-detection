function mosaic = sift_mosaic(im1, im2)
% SIFT_MOSAIC Demonstrates matching two images using SIFT and RANSAC
%
%   SIFT_MOSAIC demonstrates matching two images based on SIFT
%   features and RANSAC and computing their mosaic.
%
%   SIFT_MOSAIC by itself runs the algorithm on two standard test
%   images. Use SIFT_MOSAIC(IM1,IM2) to compute the mosaic of two
%   custom images IM1 and IM2.

% AUTORIGHTS

if nargin == 0
  im1 = imread('/home/phm/MEGA/working_datasets/image_stitching/Pond_test2/DJI_0575.JPG') ;
  %im2 = imrotate(im1,30);
  im2 = imread('/home/phm/MEGA/working_datasets/image_stitching/Pond_test2/DJI_0576.JPG') ;
end

% make single
im1 = im2single(im1) ;
im2 = im2single(im2) ;

im1 = imresize(im1, [600 800]);
im2 = imresize(im2, [600 800]);

% make grayscale
if size(im1,3) > 1, im1g = rgb2gray(im1) ; else im1g = im1 ; end
if size(im2,3) > 1, im2g = rgb2gray(im2) ; else im2g = im2 ; end

% --------------------------------------------------------------------
%                                                         SIFT matches
% --------------------------------------------------------------------

[f1,d1] = vl_sift(im1g, 'EdgeThresh', 10);
[f2,d2] = vl_sift(im2g, 'EdgeThresh', 10);

[matches, scores] = vl_ubcmatch(d1,d2) ;

numMatches = size(matches,2) ;

X1 = f1(1:2,matches(1,:));
X2 = f2(1:2,matches(2,:));

[trans, ~, ~, status] = estimateGeometricTransform(X2', X1', 'affine');



res = imwarp(im2g, trans);

montage({im1g, im2g, res})

end