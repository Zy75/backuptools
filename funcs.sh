
function check_bkup_label() {

  info_bkup_part=`lsblk -f | grep $1 | grep bkup`

  length=`echo ${#info_bkup_part}`

  if [ $length -eq 0 ] ; then
    echo "ERROR: No 'bkup' label set on backup_to partition."
    exit 1
  else
    echo -e "${GREEN}OK bkup LABEL${NC}: /dev/$1 "
  fi
}

function check_partition_exist() {

  if [ ! -e "/dev/$1" ] ; then
    echo "ERROR: /dev/$1 does not exist."
    exit 1
  else
    echo -e "${GREEN}OK${NC} ( check_partition_exist /dev/$1 )"
  fi
}

# GOOD: sda1 sdb3
# BAD: sdc sda ( Entire disk is dangerous. )
function check_partition_postfix_number(){
  re='^[0-9]$'
  if ! [[ ${1: -1} =~ $re ]] ; then
    echo "ERROR: $1 must be postfixed by numbers."
    exit 1
  else
    echo -e "${GREEN}OK${NC} ( check_partition_postfix_number /dev/$1 )"
  fi
}

function check_protected() {
  for protected in $protected_part
  do
    if [ $protected = $1 ] ; then
      echo "ERROR: /dev/$1 is protected in conf file."
      exit 1
    fi
  done
}
