
im1 = imread('/home/phm/MEGA/working_datasets/image_stitching/Pond_test2/DJI_0575.JPG') ;
if size(im1,3) > 1
    P = rgb2gray(im1);
else
    P = im1;
end
w = size(im1, 2);
h = size(im1, 1);
[X Y] = meshgrid(1:w,1:h);

arrX = reshape(X,1,length(X(:)));
arrY = reshape(Y,1,length(Y(:)));

arr = [arrX;arrY;ones(1,length(arrX))];

