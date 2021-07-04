#!/bin/bash
# Toggles ANGRYsearch, i.e. opens ANGRYsearch if it's closed and closes it if it's open.
# Tie this script to a key combination (e.g. Ctrl + Space) to access ANGRYsearch more quickly
pid=$(pgrep '^angrysearch$')
if [ -z $pid ] ; then
	nohup angrysearch > /dev/null &
else
	killall angrysearch
fi
#
