#!/sbin/ash
#This script fixes the time in TWRP for stock rom users
#stock and Lineage seem to produce ats files with different epochs and by default
#I made Lineage's time accurate

until pids=$(pidof recovery)
do
    sleep 1
done
sleep 2

export year=`date +%Y`
if [ $year -lt 2000 ]
then
export year=`expr $year + 46`
date $(date +%m%d%H%M)$year.$(date +%S)
fi
#On superv20 us996 10o I had it come up 2017 so handling this case
if [ `date +%Y` -eq 2017 ]
then
date $(date +%m%d%H%M)2018.$(date +%S)
echo "Did 2017 date nudge" >>/twrp-date.log
fi
sleep 4
# Now not sure about the next comment, so being more aggressive and checking every 6 seconds.
#date gets switched back to 1972 20 seconds after twrp starts so waiting 19 seconds + 2 seconds to fix on the next run
exec /sbin/ash /fixdate.sh

