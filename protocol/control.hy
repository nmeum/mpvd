(import [protocol [commands]])

(with-decorator (commands.add "pause")
  (defn pause [mpv cmd]
    (mpv.set-property "pause" True)
    None))
