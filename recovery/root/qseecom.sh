#!/sbin/ash
      mount /system -o ro
        if [ ! -f /dev/block/bootdevice/by-name/vendor ]; then
                rmdir /vendor
                ln -s /system/vendor /vendor
        else
                mount /dev/block/bootdevice/by-name/vendor /vendor -t ext4
        fi
        if [ -f /system/bin/qseecomd ]; then
#                start sys_qseecomd
		LD_LIBRARY_PATH='/system/lib64:/system/lib' PATH='/system/bin' /system/bin/qseecomd &
        else
#                start ven_qseecomd
		LD_LIBRARY_PATH='/vendor/lib64:/system/lib64:/vendor/lib:/system/lib' PATH='/vendor/bin:/system/bin' /vendor/bin/qseecomd &
        fi
while [ ! -d /data/media ]; do
sleep 1
done
killall qseecomd
umount /system


