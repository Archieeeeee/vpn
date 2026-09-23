#!/usr/bin/env bash

#curl -s https://raw.githubusercontent.com/Archieeeeee/vpn/refs/heads/master/scripts/enable.root.login.sh | bash 

#allow password
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

#allow root user
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config

sudo systemctl restart sshd
