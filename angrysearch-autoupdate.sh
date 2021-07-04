#!/bin/bash
# This script assists the user in settting up a cronjob to regularly execute the ANGRYsearch updater
updater="/usr/share/angrysearch/angrysearch_update_database.py" # path to angrysearch updater script

# Setting up privilege to edit crontab for current user
cronallowfile="/etc/cron.allow"
user=$USER
fail=false
# If there is no /etc/cron.allow file, create it and enter user to enable him to create cronjobs.
if [ ! -f "$cronallowfile" ] ; then
	echo "$cronallowfile does not exist yet, creating it and adding user \"$user\"."
	if ! sudo bash -c "printf 'root\n$user\n' > $cronallowfile" ; then
		fail=true
	fi
# Else, check if user is already in /etc/cron.allow
else
	# If user is not, add him to /etc/cron.allow
	if ! cat "$cronallowfile" | grep "$user"; then
		echo "User \"$user\" is not yet allowed to access cronjobs, adding to $cronallowfile."
		if ! sudo bash -c "echo $user >> $cronallowfile" ; then
			fail=true
		fi
	fi
fi

# If cron.allow could not be created or modified, exit with error.
if [ "$fail" == "true" ] ; then
	echo "Failed to write to $cronallowfile. This file is required for the script to run properly."
	exit 1
else
	clear
fi

function userassistant {
	while true ; do
		# Determine interval (minutes or hours)
		clear
		while true; do
			echo "Which interval do you wish to use for index updates?"
			echo "[1] minutes"
			echo "[2] hours"
			echo "[Ctrl+C] Cancel"
			read input
			case "$input" in
				1)
					i="m"
					interval="minutes"
					break
				;;
				2)
					i="h"
					interval="hours"
					break
				;;
				*)
					echo "Invalid input."
				;;
			esac
		done
		echo "You have selected $interval as your interval."
		
		# Determine frequency (update every x seconds / hours)
		clear
		while true; do
			echo "How often shall the update run? Every ... $interval."
			echo "[Ctrl+C] Cancel"
			read f
			if [ "$f" -lt 0 ] ; then 
				echo "Invalid input."
			else
				break
			fi
		done
		
		# Confirm input
		clear
		echo "ANGRYsearch will update every $f $interval. Do you wish to apply these settings? [y/n]"
		read input
		if [ "$input" == "y" ] ; then
			# Eintrag
			case "$i" in
				m)
					i="*/$f *"
				;;
				s)
					i="* */$f"
				;;
				*)
					echo "Unknown error."
					exit 1
				;;
			esac
			if echo "$i * * * $updater" | crontab - ; then
				echo "Auto-update settings applied successfully!"
			else
				echo "There was an error. Your settings could not be applied."
			fi
			exit
			break
		else
			echo "Cancelled."
			break
		fi
	done
}


echo "ANGRYsearch does not update its index automatically. This script will assist you in setting up an automatic update."

while true ; do
	echo "Choose an option by entering the number inside the square brackets."
	echo "[1] Use assistant (beginners)"
	echo "[2] Manually register new cronjob (advanced users)"
	echo "[Ctrl+C] Cancel"
	read input
	case "$input" in
		1)
			userassistant
			break
		;;
		2)
			echo "-----------"
			echo "Please copy the following path to the ANGRYsearch updater so that you can paste it into crontab:"
			echo "$updater"
			echo "Press enter when you are ready."
			read x
			crontab -e
			break
		;;
		*)
			echo "Invalid input"
		;;
	esac
done
