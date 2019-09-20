(import json)
(require [hy.contrib.walk [let]])

(defclass ServerMsg [object]
  (defn --init-- [self input]
    (setv self.dict (json.loads input)))

  (defn get-id [self]
    (if (self.event?)
      (raise (ValueError "events don't have ids"))
      (if (in "request_id" self.dict)
        (get self.dict "request_id")
        None)))

  (defn event? [self]
    (in "event" self.dict))

  (defn error? [self]
    (if (self.event?)
      False
      (not (= (get self.dict "error") "success")))))

(defclass ClientMsg [object]
  (defn --init-- [self name &optional [args []] [id None]]
    (if (and id (not (isinstance id int)))
      (raise (TypeError "Request ID must be an int")))
    (setv self.name name)
    (setv self.args args)
    (setv self.reqid id))

  (defn to-json [self]
    (let [dict {"command" (+ [self.name] self.args)}]
      (json.dumps (if (is self.reqid None)
                      dict
                      (do (assoc dict "request_id" self.reqid) dict)))))

  (defn to-bytes [self]
    (.encode (+ (self.to-json) "\n"))))
