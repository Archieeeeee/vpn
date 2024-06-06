#!/bin/bash

systemctl stop kdump.service; systemctl disable kdump.service;

ckk=$(cat /etc/default/grub |grep crashkernel)
echo "grub cmd is $ckk"
if [[ "$ckk" == "" ]]; then
  echo "no crashkernel"
  exit 0
else
  echo "need to reboot"
fi

grubby --update-kernel=ALL --args="crashkernel=no"
grubby --remove-args="crashkernel=no" --update=ALL

sleep 15
reboot
