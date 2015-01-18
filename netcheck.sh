#!/bin/bash
# Created by Patrick Seiter
#
# Created on 2013/04/13 at 06:15 AM

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

ROOT=~/netcheck/
LOG=netcheck.log
LOCK=netcheck.lck
DATE="+%Y-%m-%d %H:%M:%S"
FLUX=1
DEBUG=false

if [[ `uname` = "Darwin" ]]; then
	OSX=true
else
	OSX=false
fi

if [[ -f "$ROOT$LOCK" ]]; then
	$DEBUG && echo "netcheck is locked, exiting..."
	exit
else
	$DEBUG && echo "Locking netcheck..."
	touch $ROOT$LOCK
fi

WEBFILE=${ROOT}website.txt
if [[ -e $WEBFILE && -n `cat $WEBFILE` ]]; then
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
	if [[ -e $WEBFILE && -n `cat $WEBFILE` ]]; then
		WEBSITE=`cat $WEBFILE`
	fi
	$DEBUG && echo "Pinging..."
	ping -c1 $WEBSITE > /dev/null 2>&1
	RESULT=$?
	if [ "$RESULT" -ne 0 ] && $NODATE; then
		if $OSX; then
			DOWNTIME=`date -j "$DATE"`
		else
			DOWNTIME=`date "$DATE"`
		fi
		echo "$DOWNTIME Network went down." >> "$ROOT$LOG"
		
		NODATE=false
	elif [ "$RESULT" -eq 0 ] && ! $NODATE; then
		if $OSX; then
			UPTIME=`date -j "$DATE"`
		else
			UPTIME=`date "$DATE"`
		fi
		echo "$UPTIME Network came up." >> "$ROOT$LOG"
		
		if [ ! -f "$FILE" ]; then
			touch $FILE
			echo "$UPTIME Created $FILE." >> "$ROOT$LOG"
		fi
		
		if $OSX; then
			D=`date -j -f "%Y-%m-%d %H:%M:%S" "$DOWNTIME" "+%s"`
			U=`date -j -f "%Y-%m-%d %H:%M:%S" "$UPTIME" "+%s"`
		else
			D=`date -d "$DOWNTIME" "+%s"`
			U=`date -d "$UPTIME" "+%s"`
		fi
		DIFF=$((U - D))
		if [ $DIFF -gt $FLUX ]; then
			echo "$DOWNTIME--$UPTIME" >> $FILE
		else
			echo "$UPTIME Downtime of $DIFF seconds skipped for being <= $FLUX." >> $ROOT$LOG
		fi
		LOOP=false
	elif [ "$RESULT" -eq 0 ]; then
		$DEBUG && echo "Ending loop..."
		LOOP=false
	fi
	read -t 1 PAUSE
done

rm -f $ROOT$LOCK
