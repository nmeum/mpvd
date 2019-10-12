(import [threading [Semaphore]]
  [mpv.util [temp-event]]
  [protocol [commands]])
(require [hy.contrib.walk [let]])

(with-decorator (commands.add "pause")
  (defn pause [mpv cmd]
    (mpv.set-property "pause"
      (or (not cmd) (first cmd)))
    None))

(with-decorator (commands.add "play")
  (defn play [mpv cmd]
    (when cmd
      (let [lock    (Semaphore 0)
            handler (fn [_] (lock.release))]
        (with [(temp-event mpv "file-loaded" handler)]
          (mpv.set-property "playlist-pos" (first cmd))
          (lock.acquire))))
    (mpv.set-property "pause" False)))
