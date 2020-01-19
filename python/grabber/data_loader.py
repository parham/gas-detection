
#%%[markdown]
# ![Université Laval](src/img/ulaval.jpg)
# 
# ***
# __Course__: Directed Reading Course (GEL7065) <br>
# __Description__: This project contains the codes implemented as part of directed reading course. <br>
# __Supervisor__: Professor Xavier Maldague <br>
# __Developed by__: Parham Nooralishahi <br>
# __Organization__: Université Laval <br>
# ***

#%%
import time
import os
import sys
import mycore
import re
import cv2
import numpy as np

from abc import ABC, abstractmethod
from os.path import isfile, join
from importlib import reload

from scipy.io import loadmat
import tifffile as tif

#%%
class DataSource(ABC):
    """Abstract data source is the origin class for all data handlers"""
    @abstractmethod
    def load(self,src):
        """
            load function is the main method in DataSource class containing required codes to read and handle a predefined file format.
            Parameters:
            - src : the path to where the data has been stored
        """
        pass

#%%
class FileDataSource(DataSource):
    """ Abstract file data source is the origin class for all file data handlers """
    def load(self,src):
        """
            The load function is the main method in charge of loading the data. It checks whether the file exist.
            Parameters:
            - src: the path to where the file has been placed.
            Returns:
            - The loaded data.
            Exceptions:
            - FileNotFoundError: in case of invalid file path or a path aimed to a non-file entity.
        """
        if not os.path.exists(src) or not os.path.isfile(src):
            raise FileNotFoundError('Specified file (%s) does not exist.' % src)
        return self._load_file(src)
    
    @abstractmethod
    def _load_file(self,src):
        """This function is wrapped by \"load\" method. All subclasses must implement this method."""
        pass

#%%
class OpenCVRGBImageSource(FileDataSource):
    """ 
        OpenCV RGB Wrapper to load wide variety of images. 
        Parameters:
            flags: determines how to read the pixel formats. It can be set as one of the following values:
                - IMREAD_UNCHANGED: If set, return the loaded image as is (with alpha channel, otherwise it gets cropped).
                - IMREAD_GRAYSCALE: If set, always convert image to the single channel grayscale image (codec internal conversion).
                - IMREAD_COLOR: If set, always convert image to the 3 channel BGR color image.
                - IMREAD_ANYDEPTH: If set, return 16-bit/32-bit image when the input has the corresponding depth, otherwise convert it to 8-bit.
                - IMREAD_ANYCOLOR: If set, the image is read in any possible color format.
                - IMREAD_LOAD_GDAL: If set, use the gdal driver for loading the image.
                - IMREAD_REDUCED_GRAYSCALE_2: If set, always convert image to the single channel grayscale image and the image size reduced 1/2.
                - IMREAD_REDUCED_COLOR_2: If set, always convert image to the 3 channel BGR color image and the image size reduced 1/2.
                - IMREAD_REDUCED_GRAYSCALE_4: If set, always convert image to the single channel grayscale image and the image size reduced 1/4.
                - IMREAD_REDUCED_COLOR_4: If set, always convert image to the 3 channel BGR color image and the image size reduced 1/4.
                - IMREAD_REDUCED_GRAYSCALE_8: If set, always convert image to the single channel grayscale image and the image size reduced 1/8.
                - IMREAD_REDUCED_COLOR_8: If set, always convert image to the 3 channel BGR color image and the image size reduced 1/8.
                - IMREAD_IGNORE_ORIENTATION: If set, do not rotate the image according to EXIF's orientation flag.
                Default: None
    """
    def __init__(self, flags = None):
        super().__init__()
        self.flags = flags if flags is not None else cv2.IMREAD_UNCHANGED

    def _load_file(self,src):
        """load images based on given files"""
        return cv2.imread(src, self.flags)

#%%
class MatImageSource(FileDataSource):
    """ 
        Mat Image Source is the base class to read MATLAB Mat files containing image data. 
        Parameters:
        - key : \"key\" is the variable name inside MATLAB Mat file.
    """
    def __init__(self, key):
        super().__init__()
        self.key = key

    def _load_file(self,src):
        """ Load the variable determined by key field inside MATLAB Mat file """
        mat = loadmat(src)
        return mat[self.key] if self.key in mat.keys() else None

#%%
class Tiff16ImageSource(FileDataSource):
    """
        The base class for tiff 16bits image
        Parameters:
        - src: file path of tiff image
    """
    def _load_file(self,src):
        return cv2.imread(src, cv2.IMREAD_UNCHANGED)

#%%
class MultipageTiffImageSource(FileDataSource):
    """
        The base class for multi-page tiff image
        Parameters:
        - src: file path of multi-page tiff image
    """
    def _load_file(self,src):
        return tif.imread(src)

#%%
class SfmovImageSource(FileDataSource):
    """
        Sfmov Image file handler
    """
    def __init__(self):
        super().__init__()
        self.numeric_metadata_values = ['xpixls', 'ypixls', 'numdps']
        self.width_in_pixels_key = 'xpixls'
        self.height_in_pixels_key = 'ypixls'
        self.dps_key = 'numdps'

    def _load_file(self,src):
        return self.get_data(src)
    
    def get_meta_data(self, fname):
        if not os.path.exists(fname) or not os.path.isfile(fname):
            raise FileNotFoundError('SFMOV file does not exist.')

        with open(fname, 'rt', errors='ignore') as fin:
            meta = dict()
            for line in fin:
                # Trim the header
                header = line.strip()
                # Skip the empty lines
                if len(header) < 1:
                    continue
                if ('saf_padding' in header) or header.startswith('DATA'):
                    break
                tokens = header.split(' ')
                if len(tokens) < 2:
                    continue
                key = tokens[0].lower()
                value = tokens[1]
                if not key or not value:
                    continue
                meta[key] = value if not key in self.numeric_metadata_values else int(value)
        return meta

    def get_data(self,fname):
        meta = self.get_meta_data(fname)
        with open(fname, 'rb') as fin:
            # Skip the meta data
            fin.seek(fin.read().find(b'DATA')+6)
            data = np.fromfile(fin, dtype=np.uint16).reshape(-1, meta[self.height_in_pixels_key], meta[self.width_in_pixels_key])
        return data
