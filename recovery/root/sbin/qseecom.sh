#!/sbin/sh
if !  mountpoint /system; then
	mount -o ro /system
fi
cleanup ()
{
	if [ ! -z "$GSI" ]; then
		if [ -a /cleanup.lst ]; then
			for x in $(cat /cleanup.lst); do
				rm $x
			done
		fi
		if [ ! -z "$systemlib" ]; then
			rm /system/lib
		fi
		if [ ! -z "$systemlib64" ]; then
			rm /system/lib64
		fi
		if [ ! -z "$systembin" ]; then
			rm /system/bin
		fi
	fi
	if [ ! -z "$(pgrep vold)" ]; then
		stop sys_vold
	fi
	for x in "$(pgrep qseecomd)"; do kill $x; done
}
trap "cleanup; exit 255" INT TERM #cleanup /system even if interuoted
if [ -d /system/system ]; then
	mount -o rw,remount /system #needed due to symlinks and twrp needing the real root of /system mounted on /system6
	export GSI=true
	export vold_libs=$(cat /voldlibs.lst)
	if [ ! -d /system/lib64 ]; then
		ln -s /system/system/lib64 /system/lib64 && export systemlib64=1
	fi
	if [ ! -d /system/lib ]; then
		ln -s /system/system/lib /system/lib && export systemlib=1
	fi
	if [ ! -d /system/bin ]; then
		ln -s /system/system/bin /system/bin && export systembin=1
	fi
	if [ -z "$systemlib" -o -z "$systemlib64" ]; then
		if [ -z "$systemlib" ]; then #if /system/lib already exists check for required libraries and symlink missing
			for x in $vold_libs; do
				if [ -a /system/system/lib/$x ]; then
					if [ ! -a /system/lib/$x ]; then
						ln -s /system/system/lib/$x /system/lib/$x && echo /system/lib/$x >>/cleanup.lst
					fi
				fi
			done
		fi
		if [ -z "$systemlib64" ]; then # /system/lib64 that already exists
			for x in $vold_libs; do
				if [ -a /system/system/lib64/$x ]; then
					if [ ! -a /system/lib64/$x ]; then
						ln -s /system/system/lib64/$x /system/lib64/$x && echo /system/lib64/$x >>/cleanup.lst
					fi
				fi
			done
		fi
	fi
	if [ -z "$systembin" ]; then
		for x in vold vdc; do
			if [ ! -a /system/bin/$x ]; then
				ln -s /system/system/bin/$x /system/bin/$x && echo /system/bin/$x >>/cleanup.lst
			fi
		done
	fi
	if [ -d /system/system/vendor ]; then #debug
		if [ -d /vendor ]; then
			rmdir /vendir
		fi
		ln -s /system/system/vendor /vendor #debug
	fi
fi

while ! mountpoint  /data; do
        if blkid /dev/block/bootdevice/by-name/vendor | grep ext4; then
		if [ ! -d /vendor ]; then # create a /vendor directory to mount onto if not there
			if [ -L /vendor ]; then #if it exists and isnt a directory get it out of the way
				rm /vendor
			fi
			mkdir /vendor
		fi
                mount /dev/block/bootdevice/by-name/vendor /vendor -t ext4 -o ro
        else
		if [ -d /vendor ]; then
			rmdir /vendor
		fi
		if [ ! -L /vendor ]; then
        		ln -s /system/vendor /vendor #if no vendor partition symlink it

		fi
        fi
        if [ -f /system/bin/qseecomd ]; then
#                start sys_qseecomd
		if [ -z "$(pgrep qseecomd)" ]; then #make sure it isnt already running
			LD_LIBRARY_PATH='/system/lib64:/system/lib' PATH='/system/bin' /system/bin/qseecomd &
		fi
        else
#                start ven_qseecomd
		if [ -z "$(pgrep qseecomd)" ]; then
			LD_LIBRARY_PATH='/vendor/lib64:/system/lib64:/vendor/lib:/system/lib' PATH='/vendor/bin:|system/bin' /vendor/bin/qseecomd &
		fi
        fi
	if [ -z "$(pgrep vold)"]; then
		start sys_vold &
	fi
done
#data now mounted
cleanup
