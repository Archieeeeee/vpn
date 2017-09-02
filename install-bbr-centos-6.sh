#Install TCP BBR on CentOS 6
check_bbr() {
	local res=`lsmod | grep bbr -c`
	if [ $res -gt 0 ]; then
	    return 1
        else
	   return 0
	fi
}

version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

check_current_kernel() {
	local ker=`uname -r|cut -d '-' -f 1`
	if version_gt $ker "4.9.0"; then
	     return 1
	else 
	     return 0
	fi	
}

check_installed_kernel() {
	local ker=`rpm -qa |grep kernel-ml | sed -r "s/kernel-ml-(.*)/\1/" | cut -d '-' -f 1`
	if version_gt $ker "4.9.0"; then
	     return 1
	else 
	     return 0
	fi	
}

check_boot_kernel() {
	local ker=`grubby --default-kernel | sed -r "s/.*vmlinuz-(.*)/\1/" | cut -d '-' -f 1`
	if version_gt $ker "4.9.0"; then
	     return 1
	else 
	     return 0
	fi	
}

enable_bbr() {
	#enable bbr
	sed -i "/\b\(net.core.default_qdisc\)\b/d"  /etc/sysctl.conf
	sed -i "/\b\(net.ipv4.tcp_congestion_control\)\b/d"  /etc/sysctl.conf
	echo 'net.core.default_qdisc=fq' | tee -a /etc/sysctl.conf
	echo 'net.ipv4.tcp_congestion_control=bbr' | tee -a /etc/sysctl.conf
	sysctl -p

	#check bbr installation 
	sysctl net.ipv4.tcp_available_congestion_control
	sysctl -n net.ipv4.tcp_congestion_control
	lsmod | grep bbr	
}

install_kernel() {
	#enable ELRepo
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm
	yum --enablerepo=elrepo-kernel install kernel-ml -y

	#confirm kernel installed
	rpm -qa | grep kernel

	echo "Updated kernel is " `rpm -qa | grep kernel |grep kernel-ml`
}

select_grub() {
	#show grub menus
	echo "Current default boot is " `grubby  --default-kernel`
	echo "============================="
	grep title /etc/grub.conf | nl -v 0
	echo "============================="

	echo "Please enter preferred grub boot index"
	read bootidx

	if [[ $bootidx = *[[:digit:]]* ]]; then
	  sed -c -i "s/default=.*/default=$bootidx/" /etc/grub.conf 
	  echo "Current default boot is " `grubby  --default-kernel`
	else
	 echo "Wrong choice, exit now!"
	 exit
	fi

	echo "Grub set, please reboot"
}


    check_bbr
    if [ $? -eq 1 ]; then
        echo "BBR already installed, quit now."
        exit
    fi

    check_current_kernel
    if [ $? -eq 1 ]; then
        echo "Kernel ok, enable BBR now"
	enable_bbr
	exit
    fi

    check_installed_kernel
    if [ $? -eq 0 ]; then
        echo "Install kernel now"
	install_kernel
    fi

    check_boot_kernel
    if [ $? -eq 0 ]; then
	select_grub
    else
	echo "Please reboot and run the script again"
    fi



    exit
    







