(import mpd [mpv.message [DELIMITER]]
  [mpv.util [same-song]]
  [protocol [commands]])

;; Mapping of MPV tag names to MPD tag names.
;; See: src/tag/Names.c in MPD source.
(setv MPD-TAG-NAMES {
    "title"        "Title"
    "artist"       "Artist"
    "album"        "Album"
    "genre"        "Genre"
    "track"        "Track"
    "disc"         "Disc"
    "album_artist" "AlbumArtist"
  })

(defn lowercase-metadata [metadata]
  (dict (map (fn [tag]
               (, (.lower (first tag)) (last tag)))
             (.items metadata))))

(defn convert-metadata [metadata]
  (reduce (fn [dict pair]
            (if (in (first pair) MPD-TAG-NAMES)
              (assoc dict (get MPD-TAG-NAMES (first pair)) (last pair)))
            dict)
          (.items (lowercase-metadata metadata)) {}))

;; See https://github.com/MusicPlayerDaemon/MPD/blob/d663f81/src/command/PlayerCommands.cxx#L119-L129
(defn current-state [mpv]
  ;; TODO: Support "stop" state
  (if (mpv.get-property "pause") "pause" "play"))

(with-decorator (commands.add "currentsong")
  (defn current-song [mpv cmd]
    (with [(same-song mpv)]
      ;; See https://github.com/MusicPlayerDaemon/MPD/blob/d663f81/src/SongPrint.cxx#L82
      {#** {
             "file"     (mpv.get-property "path")
             "Pos"      (mpv.get-property "playlist-pos")
             "duration" (mpv.get-property "duration")
           }
       #** (convert-metadata (mpv.get-property "metadata"))})))

(with-decorator (commands.add "status")
  (defn status [mpv cmd]
    (with [(same-song mpv)]
      (setv [curtime maxtime] (,
        (mpv.get-property "time-pos")
        (mpv.get-property "duration")))

      ;; See https://github.com/MusicPlayerDaemon/MPD/blob/d663f81/src/command/PlayerCommands.cxx#L110
      {
        "volume"         (mpv.get-property "volume")
        "repeat"         (mpv.get-property "options/loop")
        "random"         (mpv.get-property "options/shuffle")
        "playlistlength" (mpv.get-property "playlist-count")
        "state"          (current-state mpv)
        "song"           (mpv.get-property "playlist-pos")
        "time"           (.format "{}:{}"
                           (round curtime)
                           (round maxtime))
        "elapsed"        curtime
        "duration"       maxtime
        "bitrate"        (/ (mpv.get-property "audio-bitrate" 0) 1000)
      })))
