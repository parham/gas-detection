
import time
import functools
import threading
from collections import deque
from enum import Enum

class AtomicContainer:
    """Atomic container keeps thread-safe list of values"""
    def __init__(self):
        self._locks = dict()

    def set_variable(self, varb, value):
        """Set value of a variable"""
        if not varb in self._locks.keys():
            self._locks[varb] = threading.RLock()
        self._locks[varb].acquire()
        try:
            setattr(self, varb, value)
        finally:
            self._locks[varb].release()

    def get_variable(self, varb):
        """Get value of a variable"""
        if not varb in self._locks.keys():
            return None
        self._locks[varb].acquire()
        try:
            value = getattr(self, varb, None)
        finally:
            self._locks[varb].release()
        return value

    def delete_variable(self, varb):
        """Delete value of a variable"""
        if varb in self._locks.keys():
            self._locks[varb].acquire()
            try:
                delattr(self, varb)
            finally:
                self._locks[varb].release()
            del self._locks[varb]

    def __len__(self):
        len(self.__dict__)

    def __getitem__(self,varb):
        return self.get_variable(varb)
    
    def __setitem__(self,varb,value):
        self.set_variable(varb,value)
    
    def __delitem__(self,varb):
        self.delete_variable(varb)

    def __contains__(self,varb):
        return hasattr(self, varb)

class ComputingTimeUnit(Enum):
    """Computing Time Unit"""
    Millisecs = 1
    Seconds = 2
    Minutes = 3

def _convert_ctime(tvalue, unit):
    """Convert computing time based on given unit"""
    return {
        ComputingTimeUnit.Millisecs: lambda t : t,
        ComputingTimeUnit.Seconds: lambda t : t / 1000,
        ComputingTimeUnit.Minutes: lambda t : t / 60000
    }[unit](tvalue)

def get_computing_time(obj, func_name, unit = ComputingTimeUnit.Millisecs):
    """Get computing time and convert it to given unit"""
    if not func_name in dir(obj):
        raise LookupError(f"{func_name} does not exist!")
    if hasattr(obj.time_table, func_name):
        return _convert_ctime(obj.time_table[func_name], unit)
    return None

_timeq_maxlength_field_ = "tqueue_maxlen"
_default_timeq_maxlength_ = 20

def computing_time(func):
    """computing_time is a decorator calculating computation time of called function.
        After the first call, it creates an atomic container named time_table where all the measured computation will be kept. 
        The computation time of each fucntion in the decorated class can be retrieved by simply retrieving value associated with the name of function in the time_table dictionary. """
    @functools.wraps(func)
    def calc_computing_time(*args, **kwargs):
        str_time = time.time()
        value = func(*args, **kwargs)
        end_time = time.time()
        cmp_time = (end_time - str_time) * 1000
        obj_self = args[0]
        # Update time table with recent computation result
        if not hasattr(obj_self, 'time_table'):
            obj_self.time_table = AtomicContainer()
        
        # initialize the maxlength property if exist, otherwise the default value will be set.
        maxlength = getattr(obj_self, _timeq_maxlength_field_, _default_timeq_maxlength_)

        if not func.__name__ in obj_self.time_table:
            obj_self.time_table[func.__name__] = deque(maxlen = maxlength)

        obj_self.time_table[func.__name__].append(cmp_time)
        return value
    return calc_computing_time
