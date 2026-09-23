#!/bin/bash

#pkill node_exporter; curl -s https://raw.githubusercontent.com/Archieeeeee/vpn/refs/heads/master/scripts/install-node-exporter.sh | bash


dnf copr enable ibotty/prometheus-exporters -y
dnf install node_exporter -y
#for epel 9
dnf install node-exporter -y
