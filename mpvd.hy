(import argparse mpv mpd threading signal
  [mpd.server [Server]]
  [protocol [commands playback]])
(require [hy.contrib.walk [let]])

;; The socketserver needs to be closed from a different. This thread
;; blocks until a signal is received and closes both the mpv connection
;; and the socket server.
(defclass CleanupThread [threading.Thread]
  (defn --init-- [self socket-server mpv]
    (setv self.server socket-server)
    (setv self.mpv mpv)
    (setv self.lock (threading.Semaphore 0))
    (signal.signal signal.SIGINT
      (fn [signal frame] (self.lock.release)))
    (.--init-- threading.Thread self))

  (defn run [self]
    (self.lock.acquire)
    (self.server.shutdown)
    (self.mpv.shutdown)))

(defn start-server [addr port path]
  (let [mpv-conn (mpv.Connection path)
        handler  (fn [cmd] (commands.call mpv-conn cmd))]
    (with [server (Server (, addr port) handler)]
      (.start (CleanupThread server mpv-conn))
      (server.serve-forever))))

(defmain [&rest args]
  (let [parser (argparse.ArgumentParser)]
    (parser.add-argument "PATH" :type string
      :help "path to mpv IPC server")
    (parser.add-argument "-p" :type int :metavar "PORT"
      :default 6600 :help "TCP port used by the MPD server")
    (parser.add-argument "-a" :type string :metavar "ADDR"
      :default "localhost" :help "Address the MPD server binds to")
    (let [args (parser.parse-args)]
      (start-server args.a args.p args.PATH)))
  0)
