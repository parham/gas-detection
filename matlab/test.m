
imgds = lemanchot.dsource.ImageFolderDataSource();
preps = lemanchot.stitching_v1.PreprocessingSteps();
videoPlayer = vision.VideoPlayer;

while ~isDone(imgds)
   [frame, index] = step(imgds);
   [result, exeTime] = step(preps,frame); 
   step(videoPlayer,result);
end

release(imgds);
release(preps);
release(videoPlayer);