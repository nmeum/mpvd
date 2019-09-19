(import [protocol [commands]])

(with-decorator (commands.add "pause")
  (defn pause [cmd]
    (print "pause")))
