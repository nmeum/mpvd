(import socketserver mpd
  [mpd.parser [parse-command]]
  [protocol [commands playback]])
(require [hy.contrib.walk [let]])

(defclass Handler [socketserver.BaseRequestHandler]
  (defn dispatch [self input]
    (try
      (let [cmd (parse-command input)]
        (commands.call cmd))
      (except [e NotImplementedError]
        (self.request.sendall (.encode "ACK [0@5] {} " + e)))
      (except [ValueError]
        (self.request.sendall (.encode "ACK [0@5] {} syntax error")))))

  (defn handle [self]
    (self.request.sendall (.encode (% "OK %s\n" mpd.VERSION)))
    (with [file (self.request.makefile)]
      (for [input (iter (mpd.util.Reader file) "")]
        (self.dispatch input)))))

(with [server (socketserver.TCPServer (, "localhost" 6600) Handler)]
      (server.serve-forever))
