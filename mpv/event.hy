(import [threading [Lock]] [collections [defaultdict]])
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

;; TODO make unobserving properties possible
(defclass PropertyHandler [EventHandler]
  (defn --init-- [self conn]
    (setv self.property-handlers (defaultdict list))
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
    (.append (get self.property-handlers name) callable)
    (self.conn.send-command "observe_property" (self.get-observe-id) name))

  (defn handle-change [self msg]
    (let [name (get msg.dict "name")]
      (for [h (get self.property-handlers name)]
        (h (msg.get-data))))))
