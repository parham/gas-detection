function [bestH, maxInl] = RANSAC (k1,k2,matches)

numMatches = size(matches,2);
pixelError = 6;

numIters = 100;
numPts = 4;

A = zeros(2 * numPts, 8);
b = zeros(2 * numPts, 1);

bestH = zeros(3,3);
maxInl = -Inf;

for ind = 1 : numIters
    
    randSample = randperm(numMatches, numPts);
    
    i = 1;
    for j = 1 : numPts
        matchInd = randSample(j);
        
        d1Ind = matches(1, matchInd);
        d2Ind  = matches(2, matchInd);
    
        X1 = k1(1, d1Ind); Y1 = k1(2, d1Ind);
        X2  = k2(1, d2Ind); Y2  = k2(2, d2Ind);
        
        A(i, :) = [X1 Y1 1 0 0 0 -X1*X2 -Y1*X2];
%         A(i, :) = [X1 Y1 1 0 0 0 -X1*X2 -Y1*X2];
        b(i) = X2;
        i = i + 1;
        
        A(i, :) = [0 0 0 X1 Y1 1 -X1*Y2 -Y1*Y2];
%         A(i, :) = [0 0 0 -X1 -Y1 -1 X1*Y2 Y1*Y2];
        b(i) = Y2;
        i = i + 1; 
        
%         A(i, :) = [-Y2*X1 -Y2*Y1 -Y2 X1*X2 Y1*X2 X2 0 0];
%         b(i) = 0;
        i = i + 1; 
    end
    
    x = A\b;
    
    homography = [x(1) x(2) x(3); x(4) x(5) x(6); x(7) x(8) 1];
    numInl = 0;

    for matchIndex = 1:numMatches
        d1Ind = matches(1, matchIndex);
        d2Ind  = matches(2, matchIndex);
        
        X1 = k1(1, d1Ind); Y1 = k1(2, d1Ind);
        X2  = k2(1, d2Ind); Y2  = k2(2, d2Ind);
    
        P1 = [X1; Y1; 1];
        P2  = [X2; Y2; 1];
        
        P11 = homography*P1;
        P11 = P11 ./ P11(3);
        err = norm((P11 - P2),2);
        if err <= pixelError
            numInl = numInl + 1;
        end
    end
    if numInl > maxInl
       maxInl = numInl;
       bestH = homography;
    end
end

