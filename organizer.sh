#!/bin/bash

# Copyright (C) 2019 Evgeny Kuznetsov (evgeny@kuznetsov.md)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along tihe this program. If not, see <https://www.gnu.org/licenses/>.

sourcedir=$(pwd)
destdir=$(pwd)
overwrite=
move=
dry=
recursive=

usage() {
	echo "File organizer"
	echo "usage: organizer.sh [[-c|-m] [-o|-n] [-d] [-r] [-f source] [-t destination] | [-h]]"
	echo "	Copies (-c) or moves (-m) files from source to destination, creating /year/month/ folder structure at destination and overwriting (-o) or keeping (-n) files that exist there."
	echo "	Can work recursively (-r) or in dry run mode (-d)."
	echo "	Defaults are:"
	echo "		-c -n -f ./ -t ./"
	echo "	i.e. copying and not overwriting to current directory".
	echo "	-h gives this information."
	echo "	If mutually exclusive options (-n and -o or -c and -m) are given, the last one takes precedence."
}

while [ "$1" != "" ]; do
	case $1 in
		-c )	move=
			;;
		-m )	move=1
			;;
		-o )	overwrite=1
			;;
		-n )	overwrite=
			;;
		-f )	shift
			sourcedir=$1
			;;
		-t )	shift
			destdir=$1
			;;
		-h )	usage
			exit
			;;
		-d )	dry=1
			;;
		-r )	recursive=1
			;;
		* )	usage
			exit 1
	esac
	shift
done

if [ "$recursive" = "1" ] && [ "$sourcedir" -ef "$destdir" ]; then
	echo "You don't want recursion when source and destination are the same!"
	exit 1
fi
if [ "$move" = "1" ]; then
	cmd="mv"
	if [ "$overwrite" = "1" ]; then
		arg="-f"
	else
		arg="-n"
	fi
else
	cmd="cp"
	if [ "$overwrite" = "1" ]; then
		arg="-pf"
	else
		arg="-pn"
	fi
fi

if [ ! -d "$destdir" ]; then
	echo "Destination does not exist"
	exit 1
fi

if [ ! -d "$sourcedir" ]; then
	echo "$sourcedir is not a directory"
	exit 1
fi

doit() {
	for x in "$1"/*; do
		if [ -d "$x" ] && [ "$recursive" = "1" ]; then
			doit "$x"
		fi
		if [ -f "$x" ]; then
			d=$(date -r "$x" +%Y/%m)
			if [ "$dry" = "1" ]; then
				echo "mkdir -p $destdir/$d"
				echo "$cmd $arg -- $x $destdir/$d/"
			else
				mkdir -p "$destdir"/"$d"
				"$cmd" "$arg" -- "$x" "$destdir"/"$d"/
			fi
		fi
	done
}

doit "$sourcedir"
