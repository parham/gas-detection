tgImg = imread('target.jpg');
srcImg= imread('source.jpg');
w = size(tgImg, 1);
h = size(tgImg, 2);
SizeSrcY = size(srcImg, 1);
SizeSrcX = size(srcImg, 2);
SizeTargetY = size(tgImg, 1);
SizeTargetX = size(tgImg, 2);
imagesc(tgImg);colormap gray;figure;
imagesc(srcImg);colormap gray;
%%
GrdSrc = zeros(size(srcImg));
for i = 2:SizeSrcX-1
    for j = 2:SizeSrcY-1
        GrdSrc(j, i) = int16(srcImg(j-1, i)) + int16(srcImg(j+1, i)) + int16(srcImg(j, i-1)) + int16(srcImg(j, i+1)) - 4*int16(srcImg(j, i));
    end 
end

%%
GrdTg = zeros(size(tgImg));
for i = 2:SizeTargetX-1
    for j = 2:SizeTargetY-1
        GrdTg(j, i, :) = int16(tgImg(j-1, i, :)) + int16(tgImg(j+1, i, :)) + int16(tgImg(j, i-1, :)) + int16(tgImg(j, i+1, :)) - 4*int16(tgImg(j, i, :));
    end
end

imshow(GrdSrc);
imshow(GrdTg);

GrdBlend = GrdSrc;
for i=1:cly
    for j=1:clx
        if(polyMask(i+cy-1, j+cx-1))
            GrdBlend(i+py, j+px, :) =  GrdTg(i+cy-1, j+cx-1, :);
        else
            GrdBlend(i+py, j+px, :) =  GrdSrc(i+py, j+px, :);
        end
    end
end
axes(handles.DispArea3);
imshow(GrdBlend);

N = (cly) * (clx);
Y = zeros(N, 3);
X = zeros(N, 3);

for kk = 1:3
    for i=1:cly
        for j = 1:clx
            Y((i-1)*clx + j) = GrdBlend(py-1+i, px-1+j);
        end
    end

    for i=1:clx   % first row
        Y(i) = srcImg(py, px+i-1);
    end
    for j=2:cly-1 % first and last column from 2 to one to the last row.
        Y((j-1)*clx + 1) = srcImg(py-1+j, px);
        Y((j-1)*clx + clx) = srcImg(py-1+j, px-1+clx);
    end
    for i=1:clx
        Y(clx*(cly-1)+i) = srcImg(py-1+cly, px-1+i);
    end
end

SparseCount = 1;
for i=1:clx   % first row
    U(SparseCount) = i;
    V(SparseCount) = i;
    S(SparseCount) = 1;
    SparseCount = SparseCount+1;
end

for j=2:cly-1 % first and last column from 2 to one to the last row.
    U(SparseCount) = (j-1)*clx + 1;
    V(SparseCount) = (j-1)*clx + 1;
    S(SparseCount) = 1;
    U(SparseCount+1) = (j-1)*clx + clx;
    V(SparseCount+1) = (j-1)*clx + clx;
    S(SparseCount+1) = 1;
    SparseCount = SparseCount + 2;
end

for i=1:clx
    U(SparseCount) = clx*(cly-1)+i;
    V(SparseCount) = clx*(cly-1)+i;
    S(SparseCount) = 1;
    SparseCount = SparseCount+1;
end
    
for i=2:cly-1   %Boundaries are done, now get to the core gradient part
    for j = 2:clx-1
        U(SparseCount) = (i-1)*clx + j;
        V(SparseCount) = (i-1)*clx + j;
        S(SparseCount) = -4;
        U(SparseCount+1) = (i-1)*clx + j;
        V(SparseCount+1) = (i-1)*clx + j-1;
        S(SparseCount+1) = 1;
        U(SparseCount+2) = (i-1)*clx + j;
        V(SparseCount+2) = (i-1)*clx + j+1;
        S(SparseCount+2) = 1;
        U(SparseCount+3) = (i-1)*clx + j;
        V(SparseCount+3) = (i-1)*clx + j-clx;
        S(SparseCount+3) = 1;
        U(SparseCount+4) = (i-1)*clx + j;
        V(SparseCount+4) = (i-1)*clx + j+clx;
        S(SparseCount+4) = 1;      
        SparseCount = SparseCount+5;
    end
end

SC = sparse(U, V, S, N, N);
%fSC = full(SC);
%dif = fSC - Cm;
%dif = sum(abs(sum(abs(dif))));

%CInv = inv(Cm);

for kk=1:3
    %X(:) = CInv * Y(:);
    X(:) = SC\Y(:);
end

for i=1:cly
    for j=1:clx
        for kk=1:3
            OutBlend(i, j) = uint8(X((i-1)*clx + j));
        end
    end
end    
    
%Ro = srcImg(:, :, 1);
%Ri = OutBlend(:, :, 1);
global MergedImage;
MergedImage = srcImg;
for i=1:cly
    for j=1:clx
        if(polyMask(i+cy-1, j+cx-1))
            MergedImage(i+py, j+px, :) =  OutBlend(i, j, :);
        else
            MergedImage(i+py, j+px, :) =  srcImg(i+py, j+px, :);
        end
    end
end
imshow(MergedImage);