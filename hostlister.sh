#!/bin/bash

########
load() {
  loadingbar=( Scanning sCanning scAnning scaNning scanNing scannIng scanniNg scanninG )
  while [ 1 ]
  do
    for i in "${loadingbar[@]}"
    do
      echo -ne "\r+ ${i} $router_ip (LAN) "
      sleep 0.08
    done
  done
}
#########

main() {
  if [[ "$output" == "--help" || "$output" == "-h" ]];then
    echo -e "Nmap based on tool to simply discover hosts in the LAN .
    uses:
    ./hostlister.sh -ip or ip : only show ip adrs
    ./hostlister.sh -mac or mac: only show mac adrs
    ./hostlister.sh -ip/mac , ip/mac : show both
    ./hostlister.sh -ip/hostname , ip/hostname : show ip adrs and its hostname
    ./hostlister.sh -mac/hostname , mac/hostname : show mac adrs and its hostname
    ./hostlister.sh -ip/mac/hostname , ip/mac/hostname or -all , all : show all"
    exit
  elif [[ "$output" == "-ip" || "$output" == "ip" || "$output" == "-mac" || "$output" == "mac" || "$output" == "-ip/mac" || "$output" == "ip/mac" || "$output" == "-ip/hostname" || "$output" == "ip/hostname" || "$output" == "-mac/hostname" || "$output" == "mac/hostname" || "$output" == "-ip/mac/hostname" || "$output" == "ip/mac/hostname" || "$output" == "-all" || "$output" == "all" ]];then
    sleep 0.01s
  else
    echo "unknow arguments . try --help or -h for help"
    exit
  fi
  router_ip=`ifconfig -a |grep broadcast |awk '{ print $6 }' |sed 's/255/1/g'`

  #######
  load &
  pid=$!
  ########

  scan=`nmap -sn "${router_ip}/24"`
  scan_content=$scan
  mac_adrs=`echo "$scan_content" |grep -E -w  '..:..:..:..:..:..' |sed 's/MAC Address: //g'`
  ip_adrs=`echo "$scan_content" |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
  adrs_name=`echo "$scan_content" |grep "Nmap scan report" |awk '{ print $5 } '`

  #===========================
  range=`echo "$ip_adrs" |wc -l`
  ip_adrs_array=()
  mac_adrs_array=()
  adrs_name_array=()
  for i in  `seq 1 $range` ;do
    ip_adrs_array["${i}"]=`echo "${ip_adrs}" |sed -n "${i}"p`
    mac_adrs_array["${i}"]=`echo "${mac_adrs}" |sed -n "${i}"p`
    adrs_name_array["${i}"]=`echo "${adrs_name}" |sed -n "${i}"p`
  done
  ip_adrs_array[$range]+=" (this machine)"
  mac_adrs_array["$range"]="[this machine] ([this machine])"
  #=============================

  ###########
  kill "$pid"
  echo ""
  ###############

  if [[ "$output" == "-ip" || "$output" == "ip" ]]; then
    for ip in "${ip_adrs_array[@]}";do
      echo "$ip" |uniq
    done

  elif [[ "$output" == "-mac" || "$output" == "mac" ]]; then
    for mac in "${mac_adrs_array[@]}";do
      echo "$mac" |uniq
    done

  elif [[ "$output" == "-ip/mac" || "$output" == "ip/mac" ]]; then
    for n in `seq 1 $range`;do
      echo "${ip_adrs_array["$n"]} ; ${mac_adrs_array["$n"]}" |uniq
    done

  elif [[ "$output" == "-ip/hostname" || "$output" == "ip/hostname" ]];then
    for num in `seq 1 $range`;do
      echo "${ip_adrs_array["$num"]} ; ${adrs_name_array["$num"]}" |uniq
    done

  elif [[ "$output" == "-mac/hostname" || "$output" == "mac/hostname" ]]; then
    for num2 in `seq 1 $range`;do
      echo "${mac_adrs_array["$num2"]} ; ${adrs_name_array["$num2"]}" |uniq
    done

  elif [[ "$output" == "-ip/mac/hostname" || "$output" == "ip/mac/hostname" || "$output" == "-all" || "$output" == "all" ]];then
    for num3 in `seq 1 $range`;do
      echo "${ip_adrs_array["$num3"]} ; ${mac_adrs_array["$num3"]} ; ${adrs_name_array["$num3"]}" |uniq
    done
  else
    exit
  fi
}

output=$1
user_id=`id -u`
if [[ "$user_id" != "0" ]]; then
  echo "+ super user privledges are required !"
  exit
else
  main
fi
