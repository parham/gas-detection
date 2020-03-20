function [img] = read_image(images, index)
%READ_IMAGE Summary of this function goes here

mat = readimage(images, index);
img = mat2gray(mat);
% if size(img, 3) == 3
%     img = rgb2gray(img);
% end
img = imadjust(img);
img = imresize(img, [240 320]);

end

