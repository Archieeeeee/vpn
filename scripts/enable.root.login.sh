#!/usr/bin/env bash

#curl -s https://raw.githubusercontent.com/Archieeeeee/vpn/refs/heads/master/scripts/enable.root.login.sh | bash 

#allow password
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf 2>/dev/null

#allow root user
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config.d/*.conf 2>/dev/null

sudo systemctl restart sshd
