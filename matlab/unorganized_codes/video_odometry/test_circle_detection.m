
clear;
clc;

images = imageDatastore('/home-local2/panoo.extra.nobkp/current_dataset/tunnel_inspection/22_png_samples');
flist = images.Files;

kernel = -1*ones(3);
kernel(2,2) = 17;

for i = 30:length(flist)
    img = readimage(images, i);
    img = rgb2gray(img);
    img = imadjust(img);
    %img = imgradient(img);
    [centers, radii, metric] = imfindcircles(img, [70 130], ...
       'ObjectPolarity', 'Dark');
   	imshow(img);
    viscircles(centers,radii);
    pause(10^-3);
end
