#!/bin/bash

sourcedir=$(pwd)
destdir=$(pwd)
overwrite=
move=
dry=
recursive=

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
			# TODO add usage
		-d )	dry=1
			;;
		-r )	recursive=1
			;;
		* )	exit 1
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
			doit $x
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

doit $sourcedir
