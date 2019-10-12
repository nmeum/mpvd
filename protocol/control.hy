(import [protocol [commands]])

(with-decorator (commands.add "pause")
  (defn pause [mpv cmd]
    (mpv.set-property "pause"
      (or (not cmd) (first cmd)))
    None))

(with-decorator (commands.add "play")
  (defn play [mpv cmd]
    (if cmd
      (mpv.set-property "playlist-pos" (first cmd)))
    (mpv.set-property "pause" False)))
