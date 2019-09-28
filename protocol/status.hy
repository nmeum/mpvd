(import [mpv.message [DELIMITER]]
  [protocol [commands]])
(require [hy.contrib.walk [let]])

(defn tag->str [tag]
  (% "%s: %s" tag))

(defclass CurrentSong [object]
  ;; Mapping of MPV tag names to MPD tag names.
  ;; See: src/tag/Names.c in MPD source.
  [tag-names {
    "title"        "Title"
    "artist"       "Artist"
    "album"        "Album"
    "genre"        "Genre"
    "track"        "Track"
    "disc"         "Disc"
    "album_artist" "AlbumArtist"
  }]

  (defn __init__ [self resp]
    (setv self.data resp))

  (defn __str__ [self]
    (setv tags [])
    (for [(, key value) (.items self.data)]
      (if (in key self.tag-names)
        (tags.append (tag->str (, (get self.tag-names key) value)))))
    (.join "\n" tags)))

(with-decorator (commands.add "currentsong")
  (defn current-song [mpv cmd]
    (let [resp (mpv.send-command "get_property" "metadata")]
      (CurrentSong resp))))
