(import [enum [Enum]])

;; From src/protocol/Ack.hxx in mpd source
(defclass ACKError [Enum]
  [NOT_LIST 1
   ARG 2
   PASSWORD 3
   PERMISSION 4
   UNKNOWN 5
   NO_EXIST 50
   PLAYLIST_MAX 51
   SYSTEM 52
   PLAYLIST_LOAD 53
   UPDATE_ALREADY 54
   PLAYER_SYNC 55
   EXIST 56])

(defclass MPDException [Exception]
  (defn --init-- [self code msg &optional [lst-num 0] [cur-cmd ""]]
    (if (not (isinstance code ACKError))
      (raise (TypeError "Exception code must be an ACKError")))
    (setv self.code code)
    (setv self.msg msg)
    (setv self.lst-num lst-num)
    (setv self.cur-cmd cur-cmd))

  ;; Format: ACK [error@command_listNum] {current_command} message_text
  (defn __str__ [self]
    (% "ACK [%d@%d] {%s} %s" (, self.code.value self.lst-num
                                self.cur-cmd self.msg))))
