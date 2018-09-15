#!/bin/sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

GREEN='\033[1;32m'
NC='\033[0m'

. ./funcs.sh

echo "Have you read conf file? Press Enter."
read

echo ""

source ./dump_restore.conf

datetime=`date +%Y%m%d-%H%M%S`

echo -e "${GREEN} Backup to: /dev/$backup_to dir: $datetime ${NC}"

check_partition_exist $backup_to
check_bkup_label $backup_to
check_partition_postfix_number $backup_to
check_protected $backup_to

echo ""

umount /mnt

mount "/dev/$backup_to" /mnt

cd /mnt
mkdir $datetime

for from in $backup_from_sdb
do
  check_partition_exist $from
  check_partition_postfix_number $from

  echo -e "${GREEN}Dumping /dev/$from...${NC}"

  dump -b 32 -0f "/mnt/$datetime/$from.dump" "/dev/$from" 

  echo -e "${GREEN}/dev/$from Dumping finished.${NC}"
  echo -e "${GREEN}PRESS ENTER.${NC}"
  read
done

echo -e "${GREEN}Recording UUIDs... ${NC}"

for from in $backup_from_sdb
do
  blkid -s UUID /dev/$from >> /mnt/$datetime/uuid.txt
done
