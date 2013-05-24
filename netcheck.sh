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
#TIME="date +%R:%S"

if [ -f "$ROOT$LOCK" ]; then
	#echo "`date "$DATE"` Not running locked netcheck." | tee -a "$ROOT$LOG"
	#echo "`date "$DATE"` Not running locked netcheck." >> "$ROOT$LOG"
	exit
else
	touch $ROOT$LOCK
	#echo "`date "$DATE"` Locking netcheck." | tee -a "$ROOT$LOG"
	echo "`date "$DATE"` Locking netcheck." >> "$ROOT$LOG"
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
DOWNTIME=""
UPTIME=""
while $LOOP; do
	#echo "LOOP: $LOOP"
	#echo "NODATE: $NODATE"
	if [ -n `cat $WEBFILE` ]; then
		WEBSITE=`cat $WEBFILE`
	fi
	ping -c1 $WEBSITE > /dev/null 2>&1
	RESULT=$?
	#echo "RESULT: $RESULT"
	if [ "$RESULT" -ne 0 ] && $NODATE; then
		export DOWNTIME=`date "$DATE"`
		#echo "$DOWNTIME Network went down." | tee -a "$ROOT$LOG"
		echo "$DOWNTIME Network went down." >> "$ROOT$LOG"
		NODATE=false
	elif [ "$RESULT" -eq 0 ] && ! $NODATE; then
		export UPTIME=`date "$DATE"`
		#echo "$UPTIME Network came up." | tee -a "$ROOT$LOG"
		echo "$UPTIME Network came up." >> "$ROOT$LOG"
		if [ ! -f "$FILE" ]; then
			touch $FILE
			#echo "`date "$DATE"` Created $FILE." | tee -a "$ROOT$LOG"
			echo "`date "$DATE"` Created $FILE." >> "$ROOT$LOG"
		fi
		#echo "$DOWNTIME--$UPTIME" | tee -a $FILE
		echo "$DOWNTIME--$UPTIME" >> $FILE
		#echo "Added downtime $DOWNTIME--$UPTIME to $FILE." | tee -a "$ROOT$LOG"
		#echo "Added downtime $DOWNTIME--$UPTIME to $FILE." >> "$ROOT/$LOG"
		LOOP=false
	elif [ "$RESULT" -eq 0 ]; then
		#echo "`date "$DATE"` Network up." | tee -a "$ROOT/$LOG"
		#echo "`date "$DATE"` Network up." >> "$ROOT/$LOG"
		LOOP=false
	fi
	read -t 1 PAUSE
	#echo -e "\n"
done

rm -f $ROOT$LOCK