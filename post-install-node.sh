#!/bin/bash

systemctl stop kdump.service; systemctl disable kdump.service;

ckk=$(cat /etc/default/grub |grep crashkernel)
if [ "$(echo "$ckk" | wc -l)" -lt 1 ]; then
  echo "no crashkernel"
  exit 0
else
  echo "grub cmd is $ckk"
fi

grubby --update-kernel=ALL --args="crashkernel=no"
grubby --remove-args="crashkernel=no" --update=ALL

sleep 15
reboot
