(import mpd)
(require [hy.contrib.walk [let]])

(defclass Commands [object]
  (defn --init-- [self]
    (setv self.handlers {}))

  (defn dict->mpdstr [self dict]
    (.rstrip (reduce (fn [rest key]
                       (+ rest
                          (% "%s: %s" (, key (get dict key)))
                          mpd.DELIMITER))
                      dict "") mpd.DELIMITER))

  (defn add [self name]
    (fn [func]
      (if (in name self.handlers)
        (raise (ValueError (% "%s already registered" name)))
        (do
          (assoc self.handlers name func)
          func))))

  (defn call [self mpv cmd]
    (if (in cmd.name self.handlers)
      (let [resp ((get self.handlers cmd.name) mpv cmd.args)]
        (if (isinstance resp dict)
          (self.dict->mpdstr resp)
          resp))
      (raise (NotImplementedError (% "%s has not ben implemented" cmd.name))))))

(setv commands (Commands))
