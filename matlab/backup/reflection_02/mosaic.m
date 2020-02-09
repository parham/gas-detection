%% 
% Read the images and process
% [im1,im2] = readIms('yard-02.png','yard-01.png',.5);
% [im1,im2] = readIms('halfdome-01.png','halfdome-00.png',.5);
% [im1,im2] = readIms('yard-00.png','yard-01.png',.5);
% [im1,im2] = readIms('office-01.png','office-02.png',.5);
% [im1,im2] = readIms('photo_1.jpg','photo_2.jpg',.25);
% [im1,im2] = readIms('1.jpg','2.jpg',.2);
% [im1,im2] = readIms('shanghai-28.png','shanghai-29.png',.5); 
% [im1,im2] = readIms('shanghai-01.png','shanghai-02.png',.5);
% [im1,im2] = readIms('rio-04.png','rio-05.png',.5);
% [im1,im2] = readIms('rio-36.png','rio-37.png',.5);
% [im1,im2] = readIms('b.jpg','a.jpg',1);
[im1,im2] = readIms('goldengate-04.png','goldengate-05.png',1);

% Find SIFT Features and Descriptors
[k1,d1] = vl_sift(im1);
[k2,d2] = vl_sift(im2);

% Match local descriptors
[matches,~] = match_descr(d1,d2);

% RANSAC
[bestHomography, bestInlierCount] = RANSAC(k1,k2,matches);
%%
% Stitch 
mosIm2 = stitch (im1,im2,bestHomography);
%%
perc = bestInlierCount*100/size(matches,2);
% imwrite(mosIm2,'results/goldengate04_05.png');
%%
figure(1);
clf;
imagesc(mosIm2);
axis image off ;
title('Mosaic') ;
colormap gray;

%% Cylindrical Mapping

mosImCyl = stitch_cylinder (im1,im2,bestHomography);

figure(1);
clf;
imagesc(mosImCyl);
axis image off ;
title('Mosaic') ;
colormap gray;
%%
%Blend
[mask1, mask2] = masks(im1, im2, bestHomography);
%%
blended = stitch_blend(im1,im2,bestHomography,mask1,mask2);

figure(1);
clf;
imagesc(blended);
axis image off ;
title('Blended') ;
colormap gray;

%% Draw Some Matching Features
npts = 25;
plot_descr(im1,im2,d1,d2,k1,k2,matches,npts)