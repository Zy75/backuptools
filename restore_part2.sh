#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

source ./dump_restore.conf

umount /mnt > /dev/null 2>&1
mount /dev/$backup_to /mnt

for restore_part in $backup_from_sdb
do
  line=`cat /mnt/$restore_from_dir/uuid.txt | grep /dev/$restore_part`

# split with '"'
  IFS='"'
  set -- $line
  UUID=`echo $2`

  e2fsck -f /dev/$restore_part
  tune2fs -U $UUID /dev/$restore_part 
done
