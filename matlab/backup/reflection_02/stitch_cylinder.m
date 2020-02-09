% Write a program which takes two images and automatically solves for the image warp.
% stitchedImage = stitch( im1, im2, homography), stitches images im1 and
% im2 using homography homography. Obtain homography from RANSAC
% Adina Stoica, Derek Burrows 2012, CSE 559A Computer Vision, Washington University in St. Louis
function stitchedImage = stitch_cylinder(nearImage, farImage, homography)
    f = size(nearImage, 2);

    calibration = [f 0 size(nearImage, 2)/2; 0 f size(nearImage, 1)/2; 0 0 1];
        
    stitchedImage = zeros(size(nearImage) .* 2);
    
    for imageYIndex = 1:size(farImage, 1)
        for imageXIndex = 1:size(farImage, 2)
            nearCylinderPoint = inv(calibration) * [imageXIndex; imageYIndex; 1];
            farCylinderPoint = inv(calibration) * inv(homography) * [imageXIndex; imageYIndex; 1];
                        
            nearCylinderPoint = nearCylinderPoint ./ sqrt(nearCylinderPoint(1)^2 + nearCylinderPoint(3)^2);
            farCylinderPoint = farCylinderPoint ./ sqrt(farCylinderPoint(1)^2 + farCylinderPoint(3)^2);
            
            nearStitchedImageTheta = round(f*real(asin(nearCylinderPoint(1)))+size(stitchedImage, 2)/2);
            nearStitchedImageH = round(f*nearCylinderPoint(2)+size(stitchedImage, 1)/2);

            if nearStitchedImageH > 0 && nearStitchedImageH <= size(stitchedImage, 1) && nearStitchedImageTheta > 0 && nearStitchedImageTheta <= size(stitchedImage, 2)
                stitchedImage(nearStitchedImageH, nearStitchedImageTheta) = nearImage(imageYIndex, imageXIndex);
            end
            
            farStitchedImageTheta = round(f*real(asin(farCylinderPoint(1)))+size(stitchedImage, 2)/2);
            farStitchedImageH = round(f*farCylinderPoint(2)+size(stitchedImage, 1)/2);
            
            if farStitchedImageH > 0 && farStitchedImageH <= size(stitchedImage, 1) && farStitchedImageTheta > 0 && farStitchedImageTheta <= size(stitchedImage, 2)
                stitchedImage(farStitchedImageH, farStitchedImageTheta) = farImage(imageYIndex, imageXIndex);
            end 
        end
    end
    
    [row,col] = find(stitchedImage);
    c = max(col(:));
    d = max(row(:));

    st=imcrop(stitchedImage, [1 1 c d]);

    [row,col] = find(stitchedImage ~= 0);
    a = min(col(:));
    b = min(row(:));
    st=imcrop(st, [a b size(st,1) size(st,2)]);

    stitchedImage = st;
    
    