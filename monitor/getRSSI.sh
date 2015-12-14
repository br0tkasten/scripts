#!/bin/sh

COMMUNITY="public"
AGENT="192.168.0.1"
MACOID=".1.3.6.1.4.1.2021.255.3.54.1.3.32.1.4"
RSSIOID=".1.3.6.1.4.1.2021.255.3.54.1.3.32.1.26"

MAC=`echo $1 | sed 's/[:\.\-]//g' | sed 's/\(..\)/\1 /g'`

ID=`snmpwalk -On -v 2c -c $COMMUNITY $AGENT $MACOID | grep -i "$MAC" | awk '{print $1}' | sed 's/.*\([0123456789]\)$/\1/'`
if [ "x$ID" != "x" ];
then
        snmpget -On -v 2c -c $COMMUNITY $AGENT "$RSSIOID.$ID" | awk '{print $4}'
else
        echo "0"
fi
