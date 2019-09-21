(import [protocol [commands]])

(with-decorator (commands.add "pause")
  (defn pause [mpv cmd]
    (mpv.send-command "set_property" "pause" True)))
