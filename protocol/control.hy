(import [protocol [commands]])

(with-decorator (commands.add "pause")
  (defn pause [mpv cmd]
    (mpv.set-property "pause"
      (or (not cmd) (first cmd)))
    None))
