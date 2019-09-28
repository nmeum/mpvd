# mpvd

Control [mpv][mpv homepage] using the [MPD][mpd homepage] [protocol][mpd protocol].

## Installation

Setup [libmpdserver][libmpdserver github] using:

	$ git clone --recursive https://github.com/nmeum/libmpdserver
	$ make -C libmpdserver libmpdserver.so

Install [hy][hy homepage] and [mpv][mpv homepage], start mpv using:

	$ mpv --input-ipc-server=/tmp/mpvsock some-file.opus

Afterwards, start mpvd using:

	$ export LD_LIBRARY_PATH="<PATH TO LIBMPDSERVER REPOSITORY>"
	$ hy mpvd.hy /tmp/mpvsock

[mpv homepage]: https://mpv.io/
[mpd homepage]: https://musicpd.org/
[mpd protocol]: https://musicpd.org/doc/html/protocol.html
[libmpdserver github]: https://github.com/nmeum/libmpdserver
[hy homepage]: https://hylang.org
