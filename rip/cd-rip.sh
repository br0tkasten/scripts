#!/bin/sh

. /etc/profile

ps aux | grep abcde | grep -v grep
[ $? -eq 0 ] && exit

abcde -G -b -j 1 -p -N

echo "CD ist fertig" | mailx -s "Audio CD" arne@br0tkasten.de
