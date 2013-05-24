#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# Created by Patrick Seiter
#
# Created on 2013/04/13 at 06:15 AM

#echo "`date "+%Y-%m-%d %R:%S"` Starting netcheck." | tee -a ~/netcheck/log.txt

ROOT=~/netcheck/
LOG=netcheck.log
LOCK=netcheck.lock
DATE="+%Y-%m-%d %R:%S"
FLUX=30
#TIME="date +%R:%S"

if [ -f "$ROOT$LOCK" ]; then
	#echo "`date "$DATE"` Not running locked netcheck." >> "$ROOT$LOG"
	exit
else
	touch $ROOT$LOCK
	#echo "`date "$DATE"` Locking netcheck." | tee -a "$ROOT$LOG"
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
			echo "$DOWNTIME Downtime of $DIFF seconds skipped for being <= $FLUX." >> $ROOT$LOG
		fi
		#echo "Added downtime $DOWNTIME--$UPTIME to $FILE." >> "$ROOT/$LOG"
		LOOP=false
	elif [ "$RESULT" -eq 0 ]; then
		#echo "`date "$DATE"` Network up." >> "$ROOT/$LOG"
		LOOP=false
	fi
	read -t 1 PAUSE
	#echo -e "\n"
done

rm -f $ROOT$LOCK