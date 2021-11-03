#!/bin/bash

echo "Run system optimization "
#limits
sed -i "/\b\(soft nofile\)\b/d" /etc/security/limits.conf;  echo '* soft nofile 76800' | tee -a /etc/security/limits.conf
sed -i "/\b\(hard nofile\)\b/d" /etc/security/limits.conf;  echo '* hard nofile 76800' | tee -a /etc/security/limits.conf
sed -i "/\b\(ulimit -n\)\b/d" /etc/profile; echo 'ulimit -n 76800' | tee -a /etc/profile
source /etc/profile
ulimit -a

sed -i "/\b\(net.core.rmem_max\)\b/d"  /etc/sysctl.conf
sed -i "/\b\(net.core.wmem_max\)\b/d"  /etc/sysctl.conf
sed -i "/\b\(net.core.rmem_default\)\b/d"  /etc/sysctl.conf
sed -i "/\b\(net.core.wmem_default\)\b/d"  /etc/sysctl.conf
echo 'net.core.rmem_max=256000000' | tee -a /etc/sysctl.conf
echo 'net.core.wmem_max=256000000' | tee -a /etc/sysctl.conf
echo 'net.core.rmem_default=256000000' | tee -a /etc/sysctl.conf
echo 'net.core.wmem_default=256000000' | tee -a /etc/sysctl.conf
sysctl -p;
