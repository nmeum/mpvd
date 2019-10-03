(import [threading [Lock]])
(require [hy.contrib.walk [let]])

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
    (setv self.observe-id 0)
    (setv self.observe-lock (Lock))
    (setv self.conn conn)
    (.--init-- EventHandler self)
    (EventHandler.register self "property-change" self.handle-change))

  ;; TODO overflow handling?
  (defn get-observe-id [self]
    (with (self.observe-lock)
      (let [id self.observe-id]
        (setv self.observe-id (inc self.observe-id))
        id)))

  (defn observe-property [self name callable]
    (unless (isinstance name str)
      (raise (TypeError "name must be a string")))
    (assoc self.property-handlers name callable)
    (self.conn.send-command "observe_property" (self.get-observe-id) name))

  (defn handle-change [self msg]
    (let [name (get msg.dict "name")]
      (if (in name self.property-handlers)
        ((get self.property-handlers name) (msg.get-data))))))
