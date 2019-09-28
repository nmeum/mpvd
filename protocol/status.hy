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

  (defn __init__ [self resp &optional [tags {}]]
    (setv self.data resp)
    (setv self.base-tags [])
    (for [tag (.items tags)]
      (self.base-tags.append (tag->str tag))))

  (defn __str__ [self]
    (setv tags self.base-tags)
    (for [(, key value) (.items self.data)]
      (if (in key self.tag-names)
        (tags.append (tag->str (, (get self.tag-names key) value)))))
    (.join "\n" tags)))

(with-decorator (commands.add "currentsong")
  (defn current-song [mpv cmd]
    (let [resp (mpv.send-command "get_property" "metadata")
          pos  (mpv.send-command "get_property" "playlist-pos")]
      (CurrentSong resp {"Pos" pos}))))
