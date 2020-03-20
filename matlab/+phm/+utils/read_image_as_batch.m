
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

function [batch, exeTime] = read_image_as_batch(flist, sizeBound)
%READ_IMAGE_AS_BATCH Read images and contain them into a batch matrix
t = cputime;

frameCount = length(flist);
batch = [];
for index = 1:frameCount
    frame = imread(flist{index});
    fsize = size(frame,1);
    scaleRatio = sizeBound / fsize;
    frame = imresize(frame,scaleRatio);
    if isempty(batch)
        fdim = size(frame);
        if length(fdim) < 3
            fdim = [fdim 1];
        end
        batch = zeros([fdim frameCount], 'like', frame);
    end
    batch(:,:,:,index) = frame;
end

exeTime = cputime - t;

end
