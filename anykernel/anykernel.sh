# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=Myonol
do.devicecheck=1
do.initd=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=YUREKA
device.name2=YUREKA+
device.name3=tomato
device.name4=YU5510
device.name5=AO5510
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

chmod -R 750 $ramdisk/*;
chmod 644 $ramdisk/sbin/media_profiles.xml;
chmod -R root:root $ramdisk/*;
chmod -R root:root $ramdisk/*;
chmod 644 $ramdisk/init.spectrum.rc
chmod 644 $ramdisk/init.spectrum.sh

## AnyKernel install
dump_boot;

# begin ramdisk changes

# init.rc
backup_file init.rc;
replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";
append_file init.rc "run-parts" init;

# init.tuna.rc
backup_file init.tuna.rc;
insert_line init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
append_file init.tuna.rc "dvbootscript" init.tuna;

# fstab.tuna
backup_file fstab.tuna;
patch_fstab fstab.tuna /system ext4 options "noatime,barrier=1" "noatime,nodiratime,barrier=0";
patch_fstab fstab.tuna /cache ext4 options "barrier=1" "barrier=0,nomblk_io_submit";
patch_fstab fstab.tuna /data ext4 options "data=ordered" "nomblk_io_submit,data=writeback";
append_file fstab.tuna "usbdisk" fstab;

ui_print "Pushing Spectrum Profiles...";
found=$(find init.rc -type f | xargs grep -oh "import /init.spectrum.rc");
if [ "$found" != 'import /init.spectrum.rc' ]; then
               echo "" >> init.rc
echo "import /init.spectrum.rc" >> init.rc
fi
ui_print "Spectrum Profiles pushed Successfully....Enjoy!!!"

# end ramdisk changes

write_boot;

## end install

