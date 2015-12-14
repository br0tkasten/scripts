#!/bin/sh

. /etc/profile

ps aux | grep dvdbackup | grep -v grep
[ $? -eq 0 ] && exit

logger "Started ripping DVD"

dvdbackup -i /dev/cdrom -o /net/media/Videos -F
echo "DVD fertig" | mailx -s "DVD ripping" arne@br0tkasten.de

logger "Completed ripping DVD"
