% We implemented a function that calculates the mask for each of the images, 
% and then used the intersection of those masks (mask3) to see where the two images intersect. 
% Used the rezult of the bwdist function on this mask, normalized, as a weight for how much of 
% each image to keep.
% target = stitch_blend( im1, im2, bestHomography,mask1,mask2)
% Adina Stoica, Derek Burrows 2012, CSE 559A Computer Vision, Washington University in St. Louis
function target = stitch_blend( im1, im2, bestHomography,mask1,mask2)

% the intersection mask
mask3=zeros(size(mask2));
for i=1:size(mask2,1)
    for j=1:size(mosIm2,2)
        if mask1(i,j)==1 && mask2(i,j)==0
            mask3(i,j)=1;
        end
    end
end

%%
% copy the first image over
target = im1;

target = padarray(target, [0 size(im2, 2)], 0, 'post');
target = padarray(target, [size(im2, 1) 0], 0, 'both');
%%
imagesc(target);colormap gray;
imwrite(target,'target.jpg');
%%
% copy the 2nd image over (white is 1, black is 0)
source = zeros(size(target));
for i = 1:size(source, 2)
    for j = 1:size(source, 1)
        p2 = bestHomography * [i; j-floor(size(im2, 1)); 1];
        p2 = p2 ./ p2(3);

        x2 = floor(p2(1));
        y2 = floor(p2(2));
        if x2 > 0 && x2 <= size(im2, 2) && y2 > 0 && y2 <= size(im2, 1)
            source(j, i) = im2(y2, x2);
        end
    end
end
%%
imagesc(source);colormap gray;


%%
% if mask(x,y) is 0:
%     final(x,y) = target(x,y)
% else:
%     final(x,y) = 0
%     for each neighbor (nx,ny) in (x-1,y), (x+1,y), (x,y-1), (x,y+1):
%         final(x,y) += source(x,y) - source(nx,ny)
%         if mask(nx,ny) is 0:
%             final(x,y) += target(nx,ny)
%         else:
%             final(x,y) += final(nx,ny)
%%
final = zeros(size(source));
for i=1:size(final,1)
    for j=1:size(final,2)
        if mask3(i,j) == 0
            final(i,j) = target(i,j);
        else
            if 1
                if i > 2
                    ni = i-1; nj = j;
                    final(i,j) = final(i,j) + source(i,j) - source(ni,nj);
                    if mask3(ni,nj) == 0
                       final(i,j) = final(i,j) + target(ni,nj);
                    else
                        final(i,j) = final(i,j) + final(ni,nj);
                    end
                end
                if i < size(source,1)
                    ni = i+1; nj = j;
                    final(i,j) = final(i,j) + source(i,j) - source(ni,nj);
                    if mask3(ni,nj) == 0
                       final(i,j) = final(i,j) + target(ni,nj);
                    else
                        final(i,j) = final(i,j) + final(ni,nj);
                    end
                end
                if j > 2
                    ni = i; nj = j-1;
                    final(i,j) = final(i,j) + source(i,j) - source(ni,nj);
                    if mask3(ni,nj) == 0
                       final(i,j) = final(i,j) + target(ni,nj);
                    else
                        final(i,j) = final(i,j) + final(ni,nj);
                    end
                end
                if j < size(source,2)
                    ni = i; nj = j+1;
                    final(i,j) = final(i,j) + source(i,j) - source(ni,nj);
                    if mask3(ni,nj) == 0
                       final(i,j) = final(i,j) + target(ni,nj);
                    else
                        final(i,j) = final(i,j) + final(ni,nj);
                    end
                end
            end
        end
    end
end
imagesc(final);colormap gray
            
%%

target = im1;

target = padarray(target, [0 size(im2, 2)], 0, 'post');
target = padarray(target, [size(im2, 1) 0], 0, 'both');

if x2 > 0 && x2 <= size(im2, 2) && y2 > 0 && y2 <= size(im2, 1)
     if target(j,i)~=0&&im2(y2, x2)~=0
        target(j,i)=target(j,i)*(1-bwd(j,i))+im2(y2, x2)*(bwd(j,i));
     else
         target(j, i) = im2(y2, x2);
     end
end

%crop
[row,col] = find(target);
c = max(col(:));
d = max(row(:));

st=imcrop(target, [1 1 c d]);

[row,col] = find(target ~= 0);
a = min(col(:));
b = min(row(:));
st=imcrop(st, [a b size(st,1) size(st,2)]);

target = st;

