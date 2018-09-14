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

echo "Disabling SELinux..."
setenforce 0

echo ""

mkdir /bkup > /dev/null 2>&1
umount /bkup > /dev/null 2>&1

mount "/dev/$backup_to" /bkup

mkdir /restore > /dev/null 2>&1
umount /restore > /dev/null 2>&1

for restore_part in $backup_from_sdb
do
  check_partition_exist $restore_part
  check_partition_postfix_number $restore_part
  check_protected $restore_part

  dev_restore="/dev/$restore_part"

  echo -e "${GREEN}Restoring $dev_restore...${NC}"

  mkfs -t ext4 $dev_restore > /dev/null 2>&1

  mount $dev_restore /restore
  
  cd /restore

  restore -r -f "/bkup/$restore_from_dir/$restore_part.dump"

  cd ~

  umount /restore

  echo -e "${GREEN}Restoring finished. $dev_restore...${NC}"
  echo -e "${GREEN}PRESS ENTER.${NC}"
  read
done

