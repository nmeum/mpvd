(import socket json threading
  [mpv.queue [MSGQueue]]
  [mpv.response [ServerMsg ClientMsg]])
(require [hy.contrib.walk [let]])

(defclass Connection [object]
  ;; TODO pass socket instead of path
  ;; TODO stop thread somehow
  (defn --init-- [self path]
    (setv self.socket (socket.socket socket.AF_UNIX
                                     socket.SOCK_STREAM))
    (self.socket.connect path)
    (setv self.request_id 0)
    (setv self.queue (MSGQueue))
    (setv self.thread (threading.Thread :target self.recv-thread))
    (self.thread.start))

  ;; TODO critical section
  ;; TODO overflow handling?
  (defn get-request-id [self]
    (let [id self.request_id]
      (setv self.request_id (inc self.request_id))
      id))

  (defn handle-input [self input]
    (let [msg (ServerMsg input)]
      (unless (msg.event?)
        (self.queue.release (msg.get-id) msg))))

  (defn recv-thread [self]
    (with [file (self.socket.makefile)]
      (for [input (iter file.readline "")]
        (self.handle-input input))))

  (defn send-command [self name &rest params]
    (let [rid (self.get-request-id)
          req (ClientMsg name :args (list params) :id rid)]
      (self.socket.sendall (req.to-bytes))
      (self.queue.wait rid))))
