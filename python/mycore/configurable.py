
from abc import ABC, abstractmethod
import yaml
import json
import os.path

_global_config_file_ = 'global.yml'

class Configurable(ABC):
    """Abstract Configurable class providing required methods for object configuration based on given source"""

    def configure(self, obj, srcpath):
        """General method to configure the object based on given configuration file"""
        # Load the global configuration
        cfg_global = self._load_global_configs(obj)
        for k in cfg_global.keys():
            if hasattr(obj,k): setattr(obj,k,cfg_global[k])
        # Load the configuration 
        cfg = self.load_config(srcpath)
        for k in cfg.keys():
            if hasattr(obj,k): setattr(obj,k,cfg[k])

    def _load_global_configs(self, obj):
        """Load the global configurations"""
        if not os.path.exists(_global_config_file_):
            raise ValueError('Global configuration does not exist')
        with open(_global_config_file_, 'r') as yf:
            cfg = yaml.load(yf)
        return cfg

    @abstractmethod
    def load_config(self,file):
        """Load the configuration file"""
        pass

class YamlConfigurable(Configurable):
    """YAML-based configurable class providing the object configuration based on given YAML file"""
    def load_config(self, file):
        """Load the YAML configuration file"""
        with open(file, 'r') as yf:
            cfg = yaml.load(yf)
        return cfg