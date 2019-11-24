#!/bin/bash
# Listen at ports 
function start_prog()
{
  ports_TCP='53 123 80 443'
  tunLocalIP=1
  for port in $ports_TCP;do
   echo "[+] Checking TCP Port: $port"
   if [[ `checkPort tcp $port; echo $?` == 0 ]];then
     echo "[-] Starting listener at $port using TCP, tun IP: 192.168.255.$tunLocalIP"
     socat -d -d -s TCP-LISTEN:$port,fork,reuseaddr TUN:192.168.255.$tunLocalIP/24,up &>/dev/null &
     tunLocalIP=`expr $tunLocalIP + 1`
   else
	echo "[-] Port $port is already in use"
   fi
  done

  ports_UDP='53 123'
  for port in $ports_UDP;do
   echo "[+] Checking UDP Port: $port"
   if [[ `checkPort udp $port; echo $?` == 0 ]];then
     echo "[-] Starting listener at $port using UDP, tun IP: 192.168.255.$tunLocalIP"
     socat -d -d -s UDP-LISTEN:$port,fork,reuseaddr TUN:192.168.255.$tunLocalIP/24,up &>/dev/null &
     tunLocalIP=`expr $tunLocalIP + 1`
   else
	echo "[-] Port $port is already in use"
   fi
  done
}

function stop_prog(){
 echo "[-] Its stop time, die handler"
 for pid in $(getPID | tail -n +1 | cut -d ' ' -f 2);
 do  
   echo "[-] Killing Process: $pid"
   kill -s SIGTERM $pid
 done
}

function getPID(){
  ps -C socat| grep -v PID
}

function checkPort(){
	case $1 in 
		'tcp')
  if [ $(lsof -i tcp:$2 | wc -l ) -ge 1 ];then
	return 1
  fi ;;

		'udp')
  if [ $(lsof -i udp:$2 | wc -l ) -ge 1 ];then
	return 1
  fi ;;
	esac 
}

function status_prog(){
echo "[+] Process:"
 getPID
echo "[+] Ports:"
 netstat -nlp | grep -i socat
}


case $1 in 
	"start") start_prog ;;
	"stop") stop_prog ;;
	"status") status_prog ;;
	*) usage ;;
esac 
