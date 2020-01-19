
import os
import sys
from pathlib import Path
sys.path.insert(0,str(Path(os.path.dirname(__file__)).parent))
sys.path = list(set(sys.path))

from grabber.data_grabber import *
from grabber.data_loader import *
# from grabber.folder_grabber import *