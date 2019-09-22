(import mpd socketserver
  [mpd.parser [parse-command]])
(require [hy.contrib.walk [let]])

(defclass Handler [socketserver.BaseRequestHandler]
  (defn dispatch [self input]
    (try
      (let [cmd (parse-command input)]
        (self.server.callable cmd))
      (except [ValueError]
        (self.request.sendall (.encode "ACK [0@5] {} syntax error")))
      (except [e Exception]
        (self.request.sendall (.encode "ACK [0@5] {} " + str(e))))))

  (defn handle [self]
    (self.request.sendall (.encode (% "OK %s\n" mpd.VERSION)))
    (with [file (self.request.makefile)]
      (for [input (iter (mpd.util.Reader file) "")]
        (self.dispatch input)))))

(defclass Server [socketserver.ThreadingTCPServer]
  (defn --init-- [self addr callable]
    (.--init-- socketserver.ThreadingTCPServer self addr Handler)
    (setv self.daemon_threads True)
    (setv self.callable callable)))
