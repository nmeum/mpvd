(import [threading [Lock]])
(require [hy.contrib.walk [let]])

;; TODO inherit from Connection class
;; TODO allow multiple handlers for same event
;; TODO allow removnig handlers
(defclass EventHandler [object]
  (defn --init-- [self]
    (setv self.handlers {}))

  (defn register [self event callable]
    (unless (isinstance event str)
      (raise (TypeError "event must be a string")))
    (assoc self.handlers event callable))

  (defn handle [self msg]
    (if (not (msg.event?))
      (raise (TypeError "message must be an event")))
    (let [name (get msg.dict "event")]
      (if (in name self.handlers)
        ((get self.handlers name) msg)))))

(defclass PropertyHandler [EventHandler]
  (defn --init-- [self conn]
    (setv self.property-handlers {})
    (setv self.observe-id 1)
    (setv self.observe-lock (Lock))
    (setv self.conn conn)
    (.--init-- EventHandler self)
    (EventHandler.register self "property-change" self.handle-change))

  (defn observe-property [self name callable]
    (unless (isinstance name str)
      (raise (TypeError "name must be a string")))
    (with (self.observe-lock)
        (setv id self.observe-id)
        (setv self.observe-id (inc id))
        (assoc self.property-handlers id callable))
    (self.conn.send-command "observe_property" id name)
    id)

  (defn unobserve-property [self id]
    (self.conn.send-command "unobserve_property" id)
    (del (get self.property-handlers id)))

  (defn handle-change [self msg]
    ((get self.property-handlers (get msg.dict "id"))
                                 (msg.get-data))))
