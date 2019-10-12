#!/usr/bin/env hy

(import sys socket [time [sleep]])
(require [hy.contrib.loop [loop]])

(when (< (len sys.argv) 2)
  (print (.format "USAGE: {} HOST PORT"
           (get sys.argv 0))
         :file sys.stderr)
  (sys.exit 1))

(setv addr (, (get sys.argv 1) (get sys.argv 2)))
(loop [[retries 50]]
  (when (<= retries 0)
    (print (.format "Couldn't connect to '{}'" addr)
           :file sys.stderr)
    (sys.exit 1))
  (try
    (.close (socket.create_connection addr))
    (except [OSError]
      (sleep .1)
      (recur (dec retries)))))
