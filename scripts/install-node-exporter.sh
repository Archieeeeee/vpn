#!/bin/bash

dnf copr enable ibotty/prometheus-exporters -y
dnf install node_exporter -y
#for epel 9
dnf install node-exporter -y
