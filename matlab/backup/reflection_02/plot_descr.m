function plot_descr(im1,im2,d1,d2,k1,k2,matches,npts)

figure(1), colormap gray; imagesc(im1);
figure(2), colormap gray; imagesc(im2);
for i = 1 : npts
    ind1 = matches(1,i);
    ind2 = matches(2,i);

    figure(1);
    plot1 = vl_plotsiftdescriptor(d1(:, ind1),k1(:, ind1));
    set(plot1, 'color', hsv2rgb([i / npts, 1, 1]));
    
    figure(2)
    plot2 = vl_plotsiftdescriptor(d2(:, ind2),k2(:, ind2));
    set(plot2, 'color', hsv2rgb([i / npts, 1, 1]));
    
    pause;
end