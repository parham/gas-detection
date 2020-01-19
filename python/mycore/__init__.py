
import os
import sys
from pathlib import Path
sys.path.insert(0,str(Path(os.path.dirname(__file__)).parent))
sys.path = list(set(sys.path))

from mycore.configurable import *
from mycore.core import *