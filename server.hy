(import socketserver)
(import libmpdserver [protocol [commands playback]])

(require [hy.contrib.loop [loop]])
(require [hy.contrib.walk [let]])

(setv MPD_VERSION "0.21.11")

(defclass MPDReader [object]
  (defn --init-- [self file]
    (setv self.file file))

  (defn is-list-start [self line]
    (or (= line "command_list_begin\n")
        (= line "command_list_ok_begin\n")))

  (defn is-list-end [self line]
    (= line "command_list_end\n"))

  (defn --call-- [self]
    (loop [[str ""] [list False]]
      (let [line (self.file.readline)]
        (cond
          [(self.is-list-start line)
           (recur (+ str line) True)]
          [list
           (if (self.is-list-end line)
             (+ str line)
             (recur (+ str line) list))]
          [True line])))))

(defclass MPDHandler [socketserver.BaseRequestHandler]
  (defn dispatch [self input]
    (try
      (let [cmd (libmpdserver.parse-command input)]
        (commands.call cmd))
      (except [e NotImplementedError]
        (self.request.sendall (.encode "ACK [0@5] {} " + e)))
      (except [ValueError]
        (self.request.sendall (.encode "ACK [0@5] {} syntax error")))))

  (defn handle [self]
    (self.request.sendall (.encode (% "OK %s\n" MPD_VERSION)))
    (with [file (self.request.makefile)]
      (for [input (iter (MPDReader file) "")]
        (self.dispatch input)))))

(with [server (socketserver.TCPServer (, "localhost" 6600) MPDHandler)]
      (server.serve-forever))
