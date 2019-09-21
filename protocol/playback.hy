(import [protocol [commands]])

(with-decorator (commands.add "pause")
  (defn pause [mpv cmd]
    (print "pause")))
