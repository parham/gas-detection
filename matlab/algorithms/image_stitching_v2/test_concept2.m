

frms = cell2mat(matches);
numFrame = length(matches);
confrm = cat(3,frms.WarppedFrame);
conmsk = cat(3,frms.BlendMask);

of = opticalFlowFarneback;

% obj.flowObj = opticalFlowFarneback(...
%     'NumPyramidLevels', obj.pyramidLevel, ...
%     'PyramidScale', obj.pyramidScale,...
%     'NumIterations', obj.iteration, ...
%     'NeighborhoodSize', obj.neighborSize, ...
%     'FilterSize', obj.filterSize);

mask = [];
mskCount = [];
for index = 1:length(matches)-1
    inters = conmsk(:,:,index) .* conmsk(:,:,index+1);
    inters(inters > 0.3) = 1;
    inters(inters ~= 1) = 0;
    
    frm1 = confrm(:,:,index) .* inters;
    frm2 = confrm(:,:,index+1) .* inters;
    flow = estimateFlow(of, frm1);
    mag = flow.Magnitude;
    mag = mat2gray(mag);
    tmpMsk = mag;
    tmpMsk(tmpMsk ~= 0) = 1;
    
    mskCount = cat(3, mskCount, tmpMsk);
    mask = cat(3, mask, mag);
    reset(of);
    imshow(mag);
    pause(10^-3);
end

% Integrate the mask layers
integrated_mask = sum(mask,3) ./ sum(mskCount,3);

% Normalize input data to range in [0,1].
Xmin = min(integrated_mask(:));
Xmax = max(integrated_mask(:));
if isequal(Xmax,Xmin)
    X = 0 * integrated_mask;
else
    X = (integrated_mask - Xmin) ./ (Xmax - Xmin);
end

% Threshold image - global threshold
BW = imbinarize(X);

% Remove the reflection
result = zeros(size(confrm,1), size(confrm,2));
masks = conmsk;
frames = confrm;

pixarr = reshape(confrm,[],size(confrm,3));
pixarr = mat2cell(pixarr,ones(1,size(pixarr,1)),size(pixarr,2));
pixarr = reshape(pixarr, [frmSize(1), frmSize(2)]);
prorg = cellfun(@nonzeros, pixarr, 'UniformOutput', false);
prorg = cellfun(@min, prorg, 'UniformOutput', false);
msk = cellfun(@isempty, prorg);
prorg(msk == 1) = {[0]};
prorg = cell2mat(prorg);

overlapped = imoverlay(prorg,BW,'cyan');
imshow(overlapped);