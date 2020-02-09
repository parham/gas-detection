function [matches scores]= match_descr(d1,d2)

thresh = 1.5;
npts1 = size(d1,2);
npts2 = size(d2,2);

temp = zeros(2,npts2);
k=0;
scores = zeros(1,npts1);
matches = zeros(2,npts1);

for i = 1 : npts1
    for j = 1 : npts2
        temp(1 , j) = j;
        temp(2 , j) = norm(double(d1(:,i)-d2(:,j)),2);
    end
    % sort on the 3rd row
    sorted = transpose(sortrows(transpose(temp),2));
    min1 = sorted(:,1);
    min2 = sorted(:,2);
    if min2(2,:) / min1(2,:) >= thresh
        k = k + 1;
        matches(1,k) = i;
        matches(2,k) = min1(1,:);
        scores(1,k) = min1(2,:);        
    end
end
matches = matches(:,1:k);
scores = scores(:,1:k);