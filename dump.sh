#!/bin/sh

# run as sudo or root

GREEN='\033[1;32m'
NC='\033[0m'

. ./funcs.sh

echo ""

source ./dump_restore.conf

check_partition_exist $backup_to
check_bkup_label $backup_to
check_partition_postfix_number $backup_to

echo ""

umount /mnt

mount "/dev/$backup_to" /mnt

datetime=`date +%Y%m%d-%H%M%S`

cd /mnt
sudo mkdir $datetime

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

echo ""
echo -e "${GREEN}Recording UUIDs... ${NC}"

for from in $backup_from_sdb
do
  blkid -s UUID /dev/$from >> /mnt/$datetime/uuid.txt
done
