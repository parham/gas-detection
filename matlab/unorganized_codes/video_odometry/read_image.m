function [img] = read_image(images, index)
%READ_IMAGE Summary of this function goes here

img = readimage(images, index);
if size(img, 3) == 3
    img = rgb2gray(img);
end
img = imadjust(img);

end

