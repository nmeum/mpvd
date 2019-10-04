(import mpd [mpv.message [DELIMITER]]
  [mpv.util [same-song]]
  [protocol [commands]])
(require [hy.contrib.walk [let]])

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

(defn convert-metadata [metadata]
  (reduce (fn [dict key]
            (if (in key MPD-TAG-NAMES)
              (assoc dict (get MPD-TAG-NAMES key) (get metadata key)))
            dict)
          metadata {}))

(with-decorator (commands.add "currentsong")
  (defn current-song [mpv cmd]
    (with [(same-song mpv)]
      ;; See https://github.com/MusicPlayerDaemon/MPD/blob/d663f81/src/SongPrint.cxx#L82
      (let [meta (mpv.get-property "metadata")
            len  (mpv.get-property "duration")
            pos  (mpv.get-property "playlist-pos")
            file (mpv.get-property "path")]
        {#** {"file" file "Pos" pos "duration" len}
         #** (convert-metadata meta)}))))

(with-decorator (commands.add "status")
  (defn status [mpv cmd]
    (with [(same-song mpv)]
      ;; See https://github.com/MusicPlayerDaemon/MPD/blob/d663f81/src/command/PlayerCommands.cxx#L110
      (let [volume  (mpv.get-property "volume")
            shuffle (mpv.get-property "options/shuffle")]
        {"volume" volume "random" shuffle}))))
