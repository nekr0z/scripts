#!/bin/bash

sourcedir=$(pwd)
destdir=$(pwd)
overwrite=
move=
dry=

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
		* )	exit 1
	esac
	shift
done

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

for x in "$sourcedir"/*; do
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
