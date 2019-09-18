(import ffi ctypes)
(require [hy.contrib.walk [let]])

(setv libmpdserver (ctypes.CDLL "libmpdserver.so"))
(setv parse libmpdserver.mpd_parse)
(setv parse.restype (ctypes.POINTER ffi.MPDCmd))

(defclass MPDCommand [object]
  (defn --init-- [self cmd]
    (setv self.name cmd.name)
    (let [args (self.argv-list cmd.argc cmd.argv)]
      (setv self.args (list (map self.convert-argument args)))))

  (defn argv-list [self argc argv]
    (lfor
      idx (range argc)
      (. (get argv idx) contents)))

  (defn convert-argument [self arg]
    (let [t arg.type v arg.v]
      (cond
        [(= t ffi.MPDVal.INT) v.ival]
        [(= t ffi.MPDVal.UINT) v.uval]
        [(= t ffi.MPDVal.BOOL) v.bval]
        [True (raise (NotImplementedError
                     (+ "unknown type " (string t))))]))))

(defn parse-command [string]
  (setv inptr (ctypes.c_char_p))
  (setv inptr.value (string.encode))
  (let [outptr (parse inptr)]
    (if (bool outptr)
      (MPDCommand outptr.contents)
      (raise (ValueError "not a valid MPD command")))))
