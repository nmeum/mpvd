(import socketserver)

(require [hy.contrib.loop [loop]])
(require [hy.contrib.walk [let]])

(defclass MPDHandler [socketserver.BaseRequestHandler]
  (defn is-list-start [self line]
    (or (= line "command_list_begin\n")
        (= line "command_list_ok_begin\n")))

  (defn is-list-end [self line]
    (= line "command_list_end\n"))

  (defn recv-command [self]
    (loop [[str ""] [list False]]
      (let [line (self.file.readline)]
        (cond
          [(self.is-list-start line)
           (recur (+ str line) True)]
          [list
           (if (self.is-list-end line)
             (+ str line)
             (recur (+ str line) list))]
          [True line]))))

  (defn handle [self]
    (setv self.file (self.request.makefile))
    (for [cmd (iter self.recv-command "")]
      (print cmd))))

(with [server (socketserver.TCPServer (, "localhost" 6600) MPDHandler)]
      (server.serve-forever))
