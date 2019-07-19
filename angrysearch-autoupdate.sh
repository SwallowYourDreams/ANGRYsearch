#!/bin/bash
# Assists the user in settting up a cronjob to regularly execute the ANGRYsearch updater
updater="/usr/share/angrysearch/angrysearch_update_database.py" # path to angrysearch updater script
# If there is no /etc/cron.allow/deny files, create a cron.allow file and enter user to enable him to create cronjobs.
if [ ! -f "/etc/cron.allow" ] && [ ! -f "/etc/cron.deny" ] ; then
	sudo bash -c "echo $USER > /etc/cron.allow"
fi

function userassistant {
	while true ; do
		# Intervall (Minuten / Stunden)
		clear
		while true; do
			echo "What intervall shall be used to update?"
			echo "[1] Every x minutes"
			echo "[2] Every x hours"
			echo "[Strg+C] Cancel"
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
		
		# Frequenz (Alle x Minuten)
		clear
		while true; do
			echo "How often shall the update run? Every ... $interval."
			echo "[Strg+C] Cancel"
			read f
			if [ "$f" -lt 0 ] ; then 
				echo "Invalid input."
			else
				break
			fi
		done
		
		# Bestätigung
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
			echo "$i * * * $updater" | crontab -
			if [ "$?" == "0" ] ; then
				echo "Auto-update settings applied successfully!"
			else
				echo "There was an error. Your settings could not be applied."
			fi
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
	echo "[1]Use assistant (beginners)"
	echo "[2] manually register new cronjob (advanced users)"
	echo "[Strg+C] Cancel"
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
