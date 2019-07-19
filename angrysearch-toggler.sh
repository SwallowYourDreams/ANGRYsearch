#!/bin/bash
pid=$(pgrep '^angrysearch$')
if [ -z $pid ] ; then
	nohup angrysearch > /dev/null &
else
	killall angrysearch
fi
#
