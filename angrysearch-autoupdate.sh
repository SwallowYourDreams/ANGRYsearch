#!/bin/bash
updater="/usr/share/angrysearch/angrysearch_update_database.py" # path to angrysearch updater script
if [ ! -f "/etc/cron.allow" ] && [ ! -f "/etc/cron.deny" ] ; then
	sudo bash -c "echo $USER > /etc/cron.allow"
fi

function assistent {
	while true ; do
		# Intervall (Minuten / Stunden)
		clear
		while true; do
			echo "In welchen Intervall soll aktualisiert werden?"
			echo "[1] alle x Minuten"
			echo "[2] alle x Stunden"
			echo "[Strg+C] Abbruch"
			read input
			case "$input" in
				1)
					i="m"
					interval="Minuten"
					break
				;;
				2)
					i="h"
					interval="Stunden"
					break
				;;
				*)
					echo "Fehlerhafte Eingabe"
				;;
			esac
		done
		echo "Als Intervall wurden $interval ausgewählt."
		
		# Frequenz (Alle x Minuten)
		clear
		while true; do
			echo "Wie oft soll aktualisiert werden? Alle ... $interval."
			echo "[Strg+C] Abbruch"
			read f
			if [ "$f" -lt 0 ] ; then 
				echo "Fehlerhafte Eingabe."
			else
				break
			fi
		done
		
		# Bestätigung
		clear
		echo "Angrysearch soll alle $f $interval aktualisiert werden. Einstellungen übernehmen? [j/n]"
		read input
		if [ "$input" == "j" ] ; then
			# Eintrag
			case "$i" in
				m)
					i="*/$f *"
				;;
				s)
					i="* */$f"
				;;
				*)
					echo "Es ist ein unbekannter Fehler aufgetreten."
					exit 1
				;;
			esac
			echo "$i * * * $updater" | crontab -
			if [ "$?" == "0" ] ; then
				echo "Einstellungen erfolgreich übernommen!"
			else
				echo "Es ist ein Fehler aufgetreten. Einstellungen konnten nicht übernommen werden."
			fi
			break
		fi
	done
}


echo "Angrysearch aktualisiert seine Indizes nicht automatisch. Dieses Skript hilft dir dabei, eine automatische Aktualisierung einzurichten."

while true ; do
	echo "Wähle eine Option aus, indem du die Zahl in eckigen Klammern eingibst."
	echo "[1] Assistenten zur Einrichtung verwenden (Anfänger)"
	echo "[2] /etc/crontab manuell editieren (Fortgeschrittene)"
	echo "[Strg+C] Abbruch"
	read input
	case "$input" in
		1)
			assistent
			break
		;;
		2)
			echo "-----------"
			echo "Kopiere dir den folgenden Pfad zum angrysearch updater, um ihn in crontab einzutragen:"
			echo "$updater"
			echo "Bestätige mit Enter, wenn du bereit bist."
			read x
			crontab -e
			break
		;;
		*)
			echo "Fehlerhafte Eingabe"
		;;
	esac
done
