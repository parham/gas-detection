
img = imread('./0019629.tif');
img = mat2gray(img);
img = imadjust(img);
[L,NumLabels] = superpixels(img, 2000, 'Compactness', 15);
res = zeros(size(img));
for index = 1:NumLabels
    region = zeros(size(img));
    region(L == index) = img(L == index);
    v = median(median(region(region ~= 0)));
    res(region ~= 0) = v;
end


imshow(res)