#!/sbin/ash
until pids=$(pidof recovery)
do
    sleep 1
done
export datelog='/twrp-date.log'
echo '0' `date` >$datelog
chmod 0666 $datelog
sleep 1
for x in `seq 1 30`
do
echo $x `date` >>$datelog
mkdir /sdcard/TWRP
cp $datelog /sdcard/TWRP/
chmod a+rw /sdcard/TWRP$datelog
sleep 1
done
