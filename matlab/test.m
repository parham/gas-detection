
% imgds = lemanchot.dsource.ImageFolderDataSource();
% preps = lemanchot.stitching_v1.PreprocessingSteps();
% videoPlayer = vision.VideoPlayer;
% 
% while ~isDone(imgds)
%    [frame, index] = step(imgds);
%    [result, exeTime] = step(preps,frame); 
%    step(videoPlayer,result);
% end
% 
% release(imgds);
% release(preps);
% release(videoPlayer);

frms = cell2mat(matches);
numFrame = length(matches);
confrm = cat(3,frms.WarppedFrame);
conmsk = cat(3,frms.BlendMask);

conmsk(conmsk > 0.3) = 1;
conmsk(conmsk ~= 1) = 0;

confrm = confrm .* conmsk;
frmSize = size(confrm);
pixarr = reshape(confrm,[],size(confrm,3));
pixarr = mat2cell(pixarr,ones(1,size(pixarr,1)),size(pixarr,2));
prorg = reshape(pixarr, [frmSize(1), frmSize(2)]);
% prorg = cellfun(@(x) min(x(x ~= 0)), prorg, 'UniformOutput', false);
% prorgRes = cellfun(@reduceRef, prorg, 'UniformOutput', false);
% ploc = cellfun(@findRef, prorg, 'UniformOutput', false);
loc = cell2mat(ploc);

vals = zeros([frmSize(1), frmSize(2)], 'like', confrm);
panels = zeros([frmSize(1), frmSize(2)], 'like', confrm);
for row = 4:size(confrm,1)-4
    for col = 4:size(confrm,2)-4        
        val = cell2mat(prorg(row,col));
        ind = 1:length(val);
        nzval = val(val ~= 0);
        nzind = ind(val ~= 0);
        if min(size(nzval)) == 0
            vals(row,col) = 0;
            panels(row,col) = 0;
            continue;
        end
        
        vmat = confrm(row-3:row+3,col-3:col+3,nzind);
        if length(nzind) == 1
            vals(row,col) = mean(nonzeros(vmat(:)));
            panels(row,col) = 0;
            continue;
        end
        
        vmat = reshape(vmat,[], size(vmat,3));
        vmat = mat2cell(vmat,ones(1,size(vmat,1)),size(vmat,2));
        vmat = cellfun(@(x) mean(nonzeros(x)),vmat);
        vals(row,col) = min(vmat);
        panels(row,col) = 1;
%         tmp = reshape(vmat,[], size(vmat,3));
%         tmp = mat2cell(tmp,ones(1,size(tmp,1)),size(tmp,2));
%         tmp = tmp(tmp ~= 0);
%         vmat = min(mean(tmp,2));
%         vals(row,col) = vmat;
    end
end
% 
% 
% result = cell2mat(prorgRes);
% imshow(result);
% 
% function [res] = findRef (x)
%     ind = 1:length(x);
%     tmp = x(x ~= 0);
%     ind = ind(x ~= 0);
%     if min(size(tmp)) == 0
%         res = 0;
%     else
% %         Rres = lengt(tmp);
%         [~, res] = min(tmp);
%         res = ind(res);
%     end
% end
% 
% function [res] = reduceRef (x)
%     tmp = x(x ~= 0);
%     if min(size(tmp)) == 0
%         res = 0;
%     else
%         res = min(tmp);
%     end
% end



