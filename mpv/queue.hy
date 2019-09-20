(import [threading [Lock]] [queue [Queue]])
(require [hy.contrib.walk [let]])

(defclass MSGQueue [object]
  [QUEUE_SIZE 1]

  (defn --init-- [self]
    (setv self.map-lock (Lock))
    (setv self.msgs {}))

  (defn get-queue [self id]
    (with (self.map-lock)
     (unless (in id self.msgs)
       (assoc self.msgs id (Queue self.QUEUE_SIZE))))
    (get self.msgs id))

  (defn wait [self id]
    (let [queue (self.get-queue id)
          msg   (queue.get)]
      (with (self.map-lock)
        (del queue))
      msg))

  (defn release [self id msg]
    (.put-nowait (self.get-queue id) msg)))
