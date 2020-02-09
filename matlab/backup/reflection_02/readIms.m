function [im1,im2] = readIms(name1,name2,res)
cd 'data/';
im1 = imread(name1);
im2 = imread(name2);
cd ..;
% make grayscale
if length(size(im1))==3
    im1 = rgb2gray(im1);
end
if length(size(im2))==3
    im2 = rgb2gray(im2);
end

% make single
im1 = single(im1);
im2 = single(im2);


% resize if needed
im1 = imresize(im1,res);
im2 = imresize(im2,res);

im1=imresize(im1,size(im2));

% % save ims
% im1 = im1-min(im1(:));
% im1 = im1./max(im1(:));
% imwrite(im1,['results/' name1]);
% 
% im2 = im2-min(im2(:));
% im2 = im2./max(im2(:));
% imwrite(im2,['results/' name2]);