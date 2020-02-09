function [f, d] = getSIFTFeatures(image, edgeThresh)

%convert images to greyscale
if (size(image, 3) == 3)
    Im = im2single(rgb2gray(image));
else
    Im = im2single(image);
end

% get features and descriptors
[f, d] = vl_sift(Im, 'EdgeThresh', edgeThresh);

end