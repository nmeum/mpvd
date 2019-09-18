import ctypes

class MPDExpr(ctypes.Structure):
    pass

class MPDExprOP(ctypes.Union):
    pass

MPDExprOP._fields_ = [('str', ctypes.c_char_p),
                      ('expr', ctypes.POINTER(MPDExpr))]

MPDExpr._fields_ = [('name', ctypes.c_char_p),
                    ('op', ctypes.c_uint),
                    ('o1', MPDExprOP),
                    ('next', ctypes.POINTER(MPDExpr))]

class MPDRange(ctypes.Structure):
    _fields_ = [('start', ctypes.c_size_t),
                ('end', ctypes.c_ssize_t)]

class MPDCmd(ctypes.Structure):
    pass

class MPDValue(ctypes.Union):
    _fields_ = [('ival', ctypes.c_int),
                ('uval', ctypes.c_uint),
                ('sval', ctypes.c_char_p),
                ('fval', ctypes.c_float),
                ('rval', MPDRange),
                ('eval', ctypes.POINTER(MPDExpr)),
                ('cmdval', ctypes.POINTER(MPDCmd))]

class MPDArg(ctypes.Structure):
    _fields_ = [('type', ctypes.c_uint),
                ('v', MPDValue)]

MPDCmd._fields_ = [('name', ctypes.c_char_p),
                   ('argc', ctypes.c_size_t),
                   ('argv', ctypes.POINTER(ctypes.POINTER(MPDArg)))]
