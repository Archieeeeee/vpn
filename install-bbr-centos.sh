#Install TCP BBR on CentOS 6 or 7

check_centos_version() {
        local ver=`rpm -q --queryformat '%{VERSION}' centos-release`
        return $ver
}

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
        check_centos_version
        if [ "$?" == "6" ]; then
          rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm
        else
          rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
        fi 
        yum --enablerepo=elrepo-kernel install kernel-ml -y
        
        #confirm kernel installed
        rpm -qa | grep kernel

        echo "Updated kernel is " `rpm -qa | grep kernel |grep kernel-ml`
}

select_grub() {
        #show grub menus
        echo "Current default boot is " `grubby  --default-kernel`
        echo "============================="
        check_centos_version
        if [ "$?" == "6" ]; then
          grep title /etc/grub.conf | nl -v 0
        else
          egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \' | nl -v 0
        fi
        echo "============================="

        echo "Please enter preferred grub boot index"
        read bootidx

        if [[ $bootidx = *[[:digit:]]* ]]; then
                check_centos_version
                if [ "$?" == "6" ]; then
                  sed -c -i "s/default=.*/default=$bootidx/" /etc/grub.conf
                else 
                  #grub2-set-default $bootidx
                  grubby --set-default-index=$bootidx
                fi
          echo "Current default boot is " `grubby  --default-kernel`
        else
         echo "Wrong choice, exit now!"
         exit
        fi

        echo "Grub set, please reboot"
}


select_grub_auto_reboot() {
        #show grub menus
        echo "Current default boot is " `grubby  --default-kernel`
        echo "============================="
        check_centos_version
        if [ "$?" == "6" ]; then
          grep title /etc/grub.conf | nl -v 0
        else
          egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \' | nl -v 0
        fi
        echo "============================="
        
        for ((i=0; i<15; i++)); do
        	local bootKnel=`grubby --info=$i | egrep '^kernel' | sed -r "s/.*vmlinuz-(.*)/\1/" | cut -d '-' -f 1`
        	echo "bootKnel is $bootKnel"
        	local kkk=$(grubby --info=$i | egrep '^kernel')
        	echo "kkk is $kkk"
        	# stop loop if boot menu overflow: grubby: kernel not found
        	if [[ $bootKnel == grubby* ]]; then
        		break
    		fi
    		
    		# check version
    		if version_gt $bootKnel "4.9.0"; then
    		
    			# set grub index
    			echo "Set grub index now"
    			local bootidx=$i
    			check_centos_version
                if [ "$?" == "6" ]; then
                  sed -c -i "s/default=.*/default=$bootidx/" /etc/grub.conf
                else 
                  #grub2-set-default $bootidx
                  grubby --set-default-index=$bootidx
                fi
                
                echo "Current default boot is " `grubby  --default-kernel`
                
                # index found, no further go
                echo "Reboot now"
                # reboot
                break
    		fi
    		
        done

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
        #select_grub
        select_grub_auto_reboot
    else
        echo "Please reboot and run the script again"
    fi



    exit
    
