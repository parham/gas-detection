
frms = cell2mat(matches);
numFrame = length(matches);
confrm = cat(3,frms.WarppedFrame);
conmsk = cat(3,frms.BlendMask);

pixarr = reshape(confrm,[],size(confrm,3));
pixarr = mat2cell(pixarr,ones(1,size(pixarr,1)),size(pixarr,2));
pixarr = reshape(pixarr, [size(confrm,1), size(confrm,2)]);
pixarr = cellfun(@nonzeros, pixarr, 'UniformOutput', false);
pixarr = cellfun(@std, pixarr, 'UniformOutput', false);
msk = cellfun(@isempty, pixarr);
pixarr(msk == 1) = {[0]};
pixarr = cell2mat(pixarr);

% Threshold image - global threshold
BW = imbinarize(pixarr);

% Remove the reflection
result = zeros(size(confrm,1), size(confrm,2));
masks = conmsk;
frames = confrm;

pixarr = reshape(confrm,[],size(confrm,3));
pixarr = mat2cell(pixarr,ones(1,size(pixarr,1)),size(pixarr,2));
pixarr = reshape(pixarr, [size(confrm,1), size(confrm,2)]);
prorg = cellfun(@nonzeros, pixarr, 'UniformOutput', false);
prorg = cellfun(@min, prorg, 'UniformOutput', false);
msk = cellfun(@isempty, prorg);
prorg(msk == 1) = {[0]};
prorg = cell2mat(prorg);

montage({prorg, BW});