(import json)

(defclass ServerMsg [object]
  (defn --init-- [self input]
    (setv self.dict (json.loads input)))

  (defn get-id [self]
    (if (self.event?)
      (raise (ValueError "events don't have ids"))
      (get self.dict "request_id")))

  (defn event? [self]
    (in "event" self.dict))

  (defn error? [self]
    (if (self.event?)
      False
      (not (= (get self.dict "error") "success")))))
