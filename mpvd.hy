(import argparse socketserver mpv mpd threading signal
  [mpd.parser [parse-command]]
  [protocol [commands playback]])
(require [hy.contrib.walk [let]])

(defclass Server [socketserver.ThreadingTCPServer]
  (defn __init__ [self addr handler mpv-conn]
    (.--init-- socketserver.ThreadingTCPServer self addr handler)
    (setv self.mpv mpv-conn)))

(defclass Handler [socketserver.BaseRequestHandler]
  (defn dispatch [self input]
    (try
      (let [cmd (parse-command input)]
        (commands.call self.server.mpv cmd))
      (except [e NotImplementedError]
        (self.request.sendall (.encode "ACK [0@5] {} " + e)))
      (except [ValueError]
        (self.request.sendall (.encode "ACK [0@5] {} syntax error")))))

  (defn handle [self]
    (self.request.sendall (.encode (% "OK %s\n" mpd.VERSION)))
    (with [file (self.request.makefile)]
      (for [input (iter (mpd.util.Reader file) "")]
        (self.dispatch input)))))

(defclass CleanupThread [threading.Thread]
  (defn --init-- [self socket-server lock]
    (setv self.server socket-server)
    (setv self.lock lock)
    (.--init-- threading.Thread self))

  (defn run [self]
    (self.lock.acquire)
    (self.server.shutdown)))

(defn start-server [addr port mpv-ipc]
  (let [mpv-conn (mpv.Connection mpv-ipc)
       lock      (threading.Semaphore 0)]
    (with [server (Server (, addr port) Handler mpv-conn)]
      (.start (CleanupThread server lock))
      (signal.signal signal.SIGINT (fn [signal frame] (lock.release)))
      (server.serve-forever))))

(defmain [&rest args]
  (let [parser (argparse.ArgumentParser)]
    (parser.add-argument "PATH" :type string
      :help "path to mpv IPC server")
    (parser.add-argument "-p" :type int :metavar "PORT"
      :default 6600 :help "TCP port used by the MPD server")
    (parser.add-argument "-a" :type string :metavar "ADDR"
      :default "localhost" :help "Address the MPD server binds to")
    (let [args (parser.parse_args)]
      (start-server args.a args.p args.PATH)))
  0)
