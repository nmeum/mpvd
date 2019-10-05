# mpvd

Control [mpv][mpv homepage] using the [MPD][mpd homepage] [protocol][mpd protocol].

## Status

A toy project for playing around with [libmpdserver][libmpdserver github]
and the [hy][hy homepage] programming language. Buggy and totally
incomplete at the moment.

## Installation

Setup [libmpdserver][libmpdserver github] using:

	$ git clone --recursive https://github.com/nmeum/libmpdserver
	$ make -C libmpdserver libmpdserver.so

Install [hy][hy homepage] and [mpv][mpv homepage], start mpv using:

	$ mpv --input-ipc-server=/tmp/mpvsock some-file.opus

Afterwards, start mpvd using:

	$ export LD_LIBRARY_PATH="<PATH TO LIBMPDSERVER REPOSITORY>"
	$ hy mpvd.hy /tmp/mpvsock

## Usage

Very simple interactions with `mpc` are possible, for example:

	$ mpc --host localhost --port 6600
	OpenBSD - Trial of the BSD Knights
	[paused]  #1/1   0:03/3:04 (1%)
	volume: 84%   repeat: off   random: off   single: off   consume: off

## License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

[mpv homepage]: https://mpv.io/
[mpd homepage]: https://musicpd.org/
[mpd protocol]: https://musicpd.org/doc/html/protocol.html
[libmpdserver github]: https://github.com/nmeum/libmpdserver
[hy homepage]: https://docs.hylang.org
