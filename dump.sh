#!/bin/sh

# run as sudo or root

function check_bkup_to_label() {

  info_bkup_part=`lsblk -f | grep $backup_to | grep bkup`

  length=`echo ${#info_bkup_part}` 

  if [ $length -eq 0 ] ; then
    echo "ERROR: No bkup label set on bkup partition."
    exit 1
  else
    echo -e "${GREEN}OK bkup LABEL${NC}: /dev/$backup_to "	  
  fi

} 

function check_partition_exist() {

  if [ ! -e "/dev/$1" ] ; then
    echo "ERROR: /dev/$1 does not exist." 
    exit 1
  else
    echo -e "${GREEN}OK${NC} ( check_partition_exist )"
  fi  
}

# GOOD: sda1 sdb3
# BAD: sdc sda ( Disk name is dangerous. )
function check_partition_postfix_number(){
  re='^[0-9]$'
  if ! [[ ${1: -1} =~ $re ]] ; then
    echo "ERROR: $1 must be prefixed by numbers."
  else 
    echo -e "${GREEN}OK${NC} ( check_partition_postfix_number )"
  fi
}

GREEN='\033[1;32m'
NC='\033[0m'

echo ""

source ./dump_restore.conf

check_bkup_to_label

echo ""

mount "/dev/$backup_to" /mnt > /dev/null 2>&1

datetime=`date +%Y%m%d-%H%M%S`

cd /mnt
sudo mkdir $datetime

for from in $backup_from_sdb
do
  check_partition_exist $from
  check_partition_postfix_number $from

  echo -e "${GREEN}dumping /dev/$from...${NC}"

  dump -b 32 -0f "/mnt/$datetime/$from.dump" "/dev/$from" 

  echo -e "${GREEN}/dev/$from dump finished.${NC}"
  echo -e "${GREEN}PRESS ENTER.${NC}"
  read
done
