(defclass Commands [object]
  (defn --init-- [self]
    (setv self.handlers {}))

  (defn add [self name]
    (fn [func]
      (if (in name self.handlers)
        (raise (ValueError (% "%s already registered" name)))
        (do
          (assoc self.handlers name func)
          func))))

  (defn call [self mpv cmd]
    (if (in cmd.name self.handlers)
      ((get self.handlers cmd.name) mpv cmd.args)
      (raise (NotImplementedError (% "%s has not ben implemented" cmd.name))))))

(setv commands (Commands))
