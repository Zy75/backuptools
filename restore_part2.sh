#!/bin/sh

function extract_UUID_from() {

  line=`cat /mnt/$restore_from_dir/uuid.txt | grep /dev/$1`

  IFS='"'
  set -- $line

  echo $2
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

GREEN='\033[1;32m'
NC='\033[0m'

source ./dump_restore.conf

umount /mnt > /dev/null 2>&1
mount /dev/$backup_to /mnt

for restore_part in $backup_from_sdb
do
  
  UUID=`extract_UUID_from $restore_part`


  echo -e "${GREEN}e2fsck $restore_part ${NC}" 
  e2fsck -f /dev/$restore_part
  echo -e "${GREEN}tune2fs $restore_part ${NC}" 
  tune2fs -U $UUID /dev/$restore_part 
done
