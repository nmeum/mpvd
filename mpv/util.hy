(import [contextlib [contextmanager]])
(require [hy.contrib.walk [let]])

(with-decorator contextmanager
  (defn same-property [conn property]
    (setv invoked False)
    (let [handler (fn [_] (setv invoked True))
          id      (conn.observe-property property handler)]
      (while True
        (yield)
        (if invoked
          (setv invoked False)
          (break)))
      (conn.unobserve-property id))))

(defn same-song [conn]
  (same-property conn "path"))