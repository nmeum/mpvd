(import socket json threading
  [mpv.queue [MSGQueue]]
  [mpv.message [ServerMsg ClientMsg]])
(require [hy.contrib.walk [let]])

(defclass MPVException [Exception])

;; TODO make this resemble the mpv lua api
;; See: https://mpv.io/manual/master/#mp-functions
(defclass Connection [object]
  (defn --init-- [self path]
    (setv self.socket (socket.socket socket.AF_UNIX
                                     socket.SOCK_STREAM))
    (self.socket.connect path)
    (setv self.event-handlers {"property-change" self.handle-property})
    (setv self.property-handlers {})
    (setv self.observe-id 1)
    (setv self.observe-lock (threading.Lock))
    (setv self.request-id 0)
    (setv self.socket-lock (threading.Lock))
    (setv self.queue (MSGQueue))
    (setv self.thread (threading.Thread :target self.recv-thread))
    (self.thread.start))

  (defn shutdown [self]
    (self.socket.shutdown socket.SHUT_RD)
    (.join self.thread))

  ;; TODO overflow handling?
  (defn get-request-id [self]
    (let [id self.request-id]
      (setv self.request-id (inc self.request-id))
      id))

  (defn handle-property [self msg]
    ((get self.property-handlers (get msg.dict "id"))
                                 (msg.get-data)))

  (defn handle-event [self msg]
    (let [name (get msg.dict "event")]
      (if (in name self.event-handlers)
        ((get self.event-handlers name) msg))))

  (defn handle-input [self input]
    (let [msg (ServerMsg input)]
      (if (msg.event?)
        (self.handle-event msg)
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
    (unless (isinstance name str)
      (raise (TypeError "name must be a string")))
    (with (self.observe-lock)
        (setv id self.observe-id)
        (setv self.observe-id (inc id))
        (assoc self.property-handlers id callable))
    (self.send-command "observe_property" id name)
    id)

  (defn get-property [self name &optional default]
    (try
      (self.send-command "get_property" name)
      (except [e MPVException]
        (if (and (= (str e) "property unavailable")
                 (not (is None default)))
          default (raise e)))))

  (defn set-property [self name value]
    (self.send-command "set_property" name value))

  (defn unobserve-property [self id]
    (self.send-command "unobserve_property" id)
    (del (get self.property-handlers id))))
