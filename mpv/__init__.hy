(import socket json threading
  [mpv.event [PropertyHandler]]
  [mpv.queue [MSGQueue]]
  [mpv.message [ServerMsg ClientMsg]])
(require [hy.contrib.walk [let]])

(defclass MPVException [Exception])

(defclass Connection [object]
  (defn --init-- [self path]
    (setv self.socket (socket.socket socket.AF_UNIX
                                     socket.SOCK_STREAM))
    (self.socket.connect path)
    (setv self.request-id 0)
    (setv self.socket-lock (threading.Lock))
    (setv self.queue (MSGQueue))
    (setv self.thread (threading.Thread :target self.recv-thread))
    (self.thread.start)
    (setv self.event-handler (PropertyHandler self)))

  (defn shutdown [self]
    (self.socket.shutdown socket.SHUT_RD)
    (.join self.thread))

  ;; TODO overflow handling?
  (defn get-request-id [self]
    (let [id self.request-id]
      (setv self.request-id (inc self.request-id))
      id))

  (defn handle-input [self input]
    (let [msg (ServerMsg input)]
      (if (msg.event?)
        (.handle self.event-handler msg)
        (self.queue.release (msg.get-id) msg))))

  (defn recv-thread [self]
    (with [file (self.socket.makefile)]
      (for [input (iter file.readline "")]
        (self.handle-input input))))

  (defn send-command [self name &rest params]
    (unless (isinstance name str)
      (raise (TypeError "command name must be a string")))
    (with (self.socket-lock)
      (let [rid (self.get-request-id)
            req (ClientMsg name :args (list params) :id rid)]
        (self.socket.sendall (req.to-bytes))
        (let [resp (self.queue.wait rid)]
          (if (resp.error?)
            (raise (MPVException (get resp.dict "error")))
            (resp.get-data))))))

  (defn observe-property [self name callable]
    (.observe-property self.event-handler name callable)))
