#!/bin/bash
# Created by Patrick Seiter
#
# Created on 2013/04/13 at 06:15 AM

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

ROOT=~/netcheck/
LOG=netcheck.log
LOCK=netcheck.lck
DATE="+%Y-%m-%d %R:%S"
FLUX=30

if [ -f "$ROOT$LOCK" ]; then
	exit
else
	touch $ROOT$LOCK
fi

WEBFILE=${ROOT}website.txt
if [ -n `cat $WEBFILE` ]; then
	WEBSITE=`cat $WEBFILE`
else
	WEBSITE="www.google.com"
fi

FILE=${ROOT}netcheck.txt

LOOP=true
NODATE=true
export DOWNTIME="0"
export UPTIME="0"

while $LOOP; do
	if [ -n `cat $WEBFILE` ]; then
		WEBSITE=`cat $WEBFILE`
	fi
	ping -c1 $WEBSITE > /dev/null 2>&1
	RESULT=$?
	if [ "$RESULT" -ne 0 ] && $NODATE; then
		DOWNTIME=`date "$DATE"`
		echo "$DOWNTIME Network went down." >> "$ROOT$LOG"
		
		NODATE=false
	elif [ "$RESULT" -eq 0 ] && ! $NODATE; then
		UPTIME=`date "$DATE"`
		echo "$UPTIME Network came up." >> "$ROOT$LOG"
		
		if [ ! -f "$FILE" ]; then
			touch $FILE
			echo "$UPTIME Created $FILE." >> "$ROOT$LOG"
		fi
		
		D=`date -d "$DOWNTIME" "+%s"`
		U=`date -d "$UPTIME" "+%s"`
		DIFF=$((U - D))
		if [ $DIFF -gt $FLUX ]; then
			echo "$DOWNTIME--$UPTIME" >> $FILE
		else
			echo "$UPTIME Downtime of $DIFF seconds skipped for being <= $FLUX." >> $ROOT$LOG
		fi
		LOOP=false
	elif [ "$RESULT" -eq 0 ]; then
		LOOP=false
	fi
	read -t 1 PAUSE
done

rm -f $ROOT$LOCK