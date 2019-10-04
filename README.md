# mpvd

Control [mpv][mpv homepage] using the [MPD][mpd homepage] [protocol][mpd protocol].

## Status

A toy protect for playing around with [libmpdserver][libmpdserver github]
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

Since the `status` and `currentsong` command are not implemented
correctly at the moment most mpd clients (even `mpc`) won't do a thing.

Interacting with the server through netcat works though, for example:

	$ printf "command_list_begin\ncurrentsong\npause\ncommand_list_end\n" | \
		nc localhost 6600

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
[hy homepage]: https://hylang.org
