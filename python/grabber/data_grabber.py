
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
import numpy as np
import grabber.data_loader as dl

from os.path import isfile, join
from importlib import reload
from abc import ABC, abstractmethod

#%%
class DataGrabber(ABC) :
    """Abstract class for all frame grabbers"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        # frame grabber name is used to address the gradder
        if name is not None:
            self.name = "@fg" + str(time.time_ns())

    @abstractmethod
    def frame_rate(self):
        pass

    @abstractmethod
    def create_generator(self):
        pass

#%%
class BatchGrabber(DataGrabber):
    """BatchGrabber is the abstract class for all grabbers working with data series"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        # Frame rate is the maximum number of frames to be fetched in second
        self._frameRate = 25
        # doesEnded becomes true when all files has been processed
        self.doesEneded = False

    @property
    def frame_rate(self):
        return self._frameRate

    @frame_rate.setter
    def frame_rate(self, fr):
        if (fr <= 0) :
            raise ValueError("Frame Rate must be bigger than zero.")
        self._frameRate = fr

    @abstractmethod
    def _size(self):
        pass

    @abstractmethod
    def get_item(self, index):
        pass

    def preprocess(self):
        pass

    def postprocess(self):
        pass

    def create_generator(self):
        if self.doesEneded:
            raise StopIteration('The list has already been processed.')
        self.preprocess()
        index = 0
        frame_seg = (1.0 / self.frame_rate) * 1000
        ptime = time.time()
        for index in range(0,self._size()):
            ctime = time.time()
            diftime = ctime - ptime
            if diftime < frame_seg:
                time.sleep((float(frame_seg - diftime)) / 1000.0)
            ptime = time.time()
            yield self.get_item(index), index
            index += 1
        self.doesEneded = True
        self.postprocess()

#%%
class FolderGraber(BatchGrabber):
    """Folder grabber loads a folder of images and creates an image stream"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        self._directory = None
        self._loader = None

    @property
    def data_loader(self):
        return self._loader

    @data_loader.setter
    def data_loader(self, ld):
        self._loader = ld

    @property
    def directory(self):
        return self._directory
    
    @directory.setter
    def directory(self,dir):
        if dir is None:
            raise ValueError("Directory cannot be null.")
        self._directory = dir

    @abstractmethod
    def _list_files(self):
        pass

    def _size(self):
        if not hasattr(self,'_flist'):
            raise ValueError('file list has not been initialized.')
        return len(self._flist)

    def get_item(self, index):
        if not hasattr(self,'_flist'):
            raise ValueError('file list has not been initialized.')
        f = self._flist[index]
        fpath = os.path.join(self.directory,f)
        #Load data from the file
        return self.data_loader.load(fpath)

    def preprocess(self):
        self._flist = self._list_files()

#%%
class FilteredListGraber(FolderGraber):
    """Load image frames from directory based on defined filter"""

    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        self._filter = "*"

    @property
    def filter(self):
        return self._filter

    @filter.setter
    def filter(self,fltr):
        if fltr is None:
            raise ValueError("Filter cannot be null.")
        self._filter = fltr

    def _list_files(self):
        if self._directory is None:
            raise ValueError("Directory must be initialized.")
        if not os.path.exists(self._directory) or not os.path.isdir(self._directory):
            raise FileNotFoundError("Directory does not exist.")
        try:
            ls = [f for f in os.listdir(self.directory) if re.match(self.filter, f)]
            ls.sort()
            return ls
        except:
            return list()

#%%
class ListGraber(FolderGraber):
    """Load image frame based on defined list"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        self._frameList = ''

    @property
    def frame_list(self):
        return self._frameList
    
    @frame_list.setter
    def frame_list(self, flist):
        self._frameList = flist

    def list(self):
        if self._directory is None:
            raise ValueError("Directory must be initialized.")
        if not os.path.exists(self._directory) or not os.path.isdir(self._directory):
            raise FileNotFoundError("Directory does not exist.")
        fexist = list()
        for f in self.frame_list:
            fp = os.path.join(self.directory,f)
            if os.path.isfile(fp):
                fexist.append(fp)
        return fexist

#%%
class FileBatchGrabber(BatchGrabber):
    """FileBatchGrabber is the abstract class for all batch-like grabbers working with a file containing multiple data frames"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        self._file = None
        self._loader = None
        self._batch = list()

    @property
    def filename(self):
        return self._file

    @filename.setter
    def filename(self, fname):
        if fname is None:
            raise ValueError('file address cannot be null.')
        self._file = fname

    def get_batch(self):
        return self._batch

    def get_loader(self):
        return self._loader

    def _size(self):
        if not hasattr(self,'_batch') or len(self._batch) < 1:
            raise ValueError('Batch has not been initialized or is empty.')
        return len(self._batch)

    def get_item(self, index):
        if not hasattr(self,'_batch') or len(self._batch) < 1:
            raise ValueError('Batch has not been initialized or is empty.')
        return self._batch[index]

    def preprocess(self):
        batch = self._loader.load(self._file)
        if (batch is None):
            raise ValueError('The load of batch file has been failed.')
        self._batch = self._batch2list(batch)

    @abstractmethod
    def _batch2list(self, btch):
        pass

#%%
class MultipageTiffGrabber(FileBatchGrabber):
    """Multipage TIFF file data grabber can read the multipage tiff files and stream the frames by defined frame rate"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        self._loader = dl.MultipageTiffImageSource()

    def _batch2list(self, btch):
        ls = list()
        for index in range(0,btch.shape[0]):
            img = btch[index,:,:]
            ls.append(img)
        return ls

#%%
class SfmovFileGrabber(FileBatchGrabber):
    """Sfmov data grabber can read sfmov files and stream the frames by defined frame rate"""
    def __init__(self, name = None, config_obj = mycore.YamlConfigurable()):
        super().__init__(name,config_obj)
        self._loader = dl.SfmovImageSource()

    def _batch2list(self, btch):
        ls = list()
        for index in range(0,btch.shape[0]):
            img = btch[index,:,:]
            ls.append(img)
        return ls