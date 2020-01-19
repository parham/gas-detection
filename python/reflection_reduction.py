
import cv2
import numpy as np
import yaml
import matplotlib.pyplot as plt
import grabber.data_loader as dl
import grabber.data_grabber as dg

from scipy.io import savemat

def onclick(event):
    if event.xdata != None and event.ydata != None:
        print(event.x, event.y)
        ix = int(event.xdata)
        iy = int(event.ydata)
        sig = mx[iy,ix,:]
        sig -= min(sig)
        # sig = sorted(sig)
        print(sig)
        fsig = plt.figure(2)
        plt.clf()
        plt.ylim(0,10)
        plt.plot(range(0,len(sig)), sig)
        plt.draw()
        fsig.show()
dataset_dir = '/gel/usr/panoo/Projects/xd-espace/data/reflection_hand'

flg = dg.FilteredListGraber()
flg.data_loader = dl.OpenCVRGBImageSource(flags=cv2.IMREAD_GRAYSCALE)
flg.filter = r'.*\.jpg'
# flg.frame_rate = 3
flg.directory = dataset_dir
genr = flg.create_generator()

fusion3d = []
for frame, index in genr:
    fusion3d.append(frame)
    # plt.imshow(frame,cmap="gray")
    # plt.pause(0.05)
# plt.show()

mx = np.dstack(fusion3d)

plot = plt.imshow(mx[:,:,0],cmap="gray", interpolation='none')
plot.figure.canvas.mpl_connect('button_press_event', onclick)
plt.show()

# DIFF MAP
mask = np.zeros([mx.shape[0], mx.shape[1]])
for r in range(0,mx.shape[0]):
    for c in range(0,mx.shape[1]):
        vs = mx[r,c,:]
        std = max(vs) - min(vs)
        mask[r,c] = std

box = (5,5)
sigmax = 0
# mask = cv2.GaussianBlur(mask,box,sigmax)

plot = plt.imshow(mask,cmap="gray", interpolation='none')
plt.show()

savemat('test.mat', {'mask' : mask, 'mx' : mx})

print('ooo yee')
