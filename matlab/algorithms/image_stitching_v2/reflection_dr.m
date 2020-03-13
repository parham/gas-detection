function [result, overlapped] = reflection_dr(frames, masks)
%REFLECTION_DR The proposed method to detect and remove reflections
%   Detailed explanation goes here

of = opticalFlowFarneback;

trimWindow = 20;

mask = [];
for i = 1:1:size(frames,3)
    frm = frames(:,:,i);
    %pos = wins(:,i);
    %tmpFrame = imcrop(frm,pos);
    tmpFrame = frm;
    
    mm = masks(:,:,i);
    flow = estimateFlow(of,tmpFrame);
    magTemplate = flow.Magnitude;
    
    %magTemplate = zeros(size(frm), 'like', frm);
    %magTemplate(pos(2):pos(2)+pos(4)-trimWindow, pos(1):pos(1)+pos(3)-trimWindow) = ...
     %   mag(1:end-trimWindow,1:end-trimWindow);
    
    mask = cat(3, mask, magTemplate);
    imshow(magTemplate);
    pause(10^-3)
end

% Integrate the mask layers
integrated_mask = sum(mask,3) / size(mask,3);

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
result = zeros(size(frames(:,:,1)));

for i = 1:size(frames,1)
    for j = 1:size(frames,2)
        ftmp = frames(i,j,:);
        mtmp = masks(i,j,:);
        pixelValues = ftmp(mtmp ~= 0);
        pvalue = 0;
        %%%%%
        if ~isempty(pixelValues)
            pvalue = min(pixelValues);
        end
        %%%%%
%         if ~isempty(pixelValues)
%             if BW(i,j) == 1
%                 pvalue = min(pixelValues);
%             else
%                 pvalue = median(pixelValues);
%             end 
%         end
        %%%%%%
        result(i,j) = pvalue;
    end
end

overlapped = imoverlay(max(frames,[],3),BW,'cyan');

end

