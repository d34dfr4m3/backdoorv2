#!/bin/bash
function package(){
  echo "[+] Installing packages"
  apt install socat
}

if [[ $(id -u) != 0 ]]
then
  echo "[+] Needs root to run"
  exit 1
fi
package

