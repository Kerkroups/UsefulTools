#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[43m'
NC='\033[0m'

check_system () {
    echo "Print certain system information"
    echo "Certain system information: `uname -a`"
    echo "Distro: `cat /etc/issue`"
    echo "Current user: `whoami`"
}

user_processes () {
    echo ""
    echo "List of process runned by user `whoami`"
    ps -a -u `whoami`
    echo "List of jobs: "
    jobs
}

open_ports () {
    echo ""
    echo "List of open tcp/udp ports, connections status"
    netstat -tuplvn
}

key_file_owner_check () {
    echo ""
    echo "Check for Security on Key Files. Files: /etc/fstab, /etc/passwd, /etc/shadow, /etc/group"
    if [[ $(ls -l /etc/fstab | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo -e "/etc/fstab owned by user $GREEN ROOT and ROOT GROUP $NC"
    else
    echo -e "/etc/fstab owned by user $RED`ls -l /etc/fstab | awk -F " " {'print $3}` and group `ls -l /etc/fstab | awk -F " " {'print $4`$NC"
    fi
    
    if [[ $(ls -l /etc/passwd | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo -e "/etc/passwd owned by user $GREEN ROOT and ROOT GROUP $NC"
    else
    echo -e "/etc/passwd owned by user $RED`ls -l /etc/passwd | awk -F " " {'print $3'}` and group `ls -l /etc/passwd | awk -F " " {'print $4'}`$NC"
    fi
    
    if [[ $(ls -l /etc/shadow | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo -e "/etc/shadow owned by user $GREEN ROOT and ROOT GROUP $NC"
    else
    echo -e "/etc/shadow owned by user $RED`ls -l /etc/shadow | awk -F " " {'print $3'}`$NC and group $RED`ls -l /etc/shadow | awk -F " " {'print $4'}`$NC"
    fi
    
    if [[ $(ls -l /etc/group | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo -e "/etc/group owned by user $GREEN ROOT and ROOT GROUP $NC"
    else
    echo -e "/etc/group owned by user $RED`ls -l /etc/group | awk -F " " {'print $3}` and group `ls -l /etc/group | awk -F " " {'print $4`$NC"
    fi
    
    if [[ $(ls -l /etc/passwd | awk -F " " {'print $1'}) == "rw-r--r--" ]]
    then
    echo -e "$GREEN Permissions of /etc/passwd is OK $NC"
    else
    echo -e "$RED Permissions of /etc/passwd must be rw-r--r--! NOT OK $NC"
    fi
    
    if [[ $(ls -l /etc/group | awk -F " " {'print $1'}) == "rw-r--r--" ]]
    then
    echo -e "$GREEN Permissions of /etc/group is OK $NC"
    else
    echo -e "$RED Permissions of /etc/group must be rw-r--r--! NOT OK $NC"
    fi
    
    if [[ $(ls -l /etc/shadow | awk -F " " {'print $1'}) == "r--------" ]]
    then
    echo -e "$GREEN Permissions of /etc/shadow is OK $NC"
    else
    echo -e "$RED Permissions of /etc/shadow must be r--------! NOT OK $NC"
    fi
}

pass_policy_1 () {
    echo ""
    echo "Check password policy"
    cat /etc/login.defs | awk -e /^PASS_MAX_DAYS/
    cat /etc/login.defs | awk -e /^PASS_MIN_DAYS/
    cat /etc/login.defs | awk -e /^PASS_WARN_AGE/
    cat /etc/login.defs | awk -e /^PASS_MIN_LEN/
    cat /etc/login.defs | awk -e /^LOGIN_RETRIES/
    cat /etc/login.defs | awk -e /^LOGIN_TIMEOUT/
}
non_root_uid () {
    echo ""
    echo "Check for No Non-Root Accounts Have UID Set To 0"
    awk -F: '($3 == "0") {print}' /etc/passwd
}
disableb_root_login () {
    echo ""
    if [[$(awk -F ":" 'NR==1{print $7}' /etc/passwd) == "/sbin/nologin" || $(awk -F ":" 'NR==1{print $7}' /etc/passwd) == "/bin/false" ]]
    then
    echo "Root login is DISABLED, OK."
    else
    echo "Root login is ENABLED, BAD."
    fi 2>/dev/null 
}
kernel_hardering_info () {
    echo ""
    echo "Linux Kernel /etc/sysctl.conf info"
    echo "Check execshield: `cat /etc/sysctl.conf | grep 'kernel.exec-shield\|kernel.randomize_va_space'`"
    echo "Check IP spoofing protection: `cat /etc/sysctl.conf | grep 'net.ipv4.conf.all.rp_filter'`"
    echo "Disable IP source routing: `cat /etc/sysctl.conf | grep 'net.ipv4.conf.all.accept_source_route'`"
    echo "Ignoring broadcasts request: `cat /etc/sysctl.conf | grep 'net.ipv4.icmp_echo_ignore_broadcasts\|net.ipv4.icmp_ignore_bogus_error_messages'`"
    echo "Make sure spoofed packets get logged: `cat /etc/sysctl.conf | grep 'net.ipv4.conf.all.log_martians'`"
}
SUID_list () {
    echo ""
    echo "SUID files: "
    find / -perm 4000 2>/dev/null
}
SGID_list () {
    echo ""
    echo "SGID files: "
    find / -perm 2000 2>/dev/null
}
sudo_version () {
    echo ""
    echo "Check sudo version: `sudo --version | grep "Sudo version"`"
}
ssh_checks () {
    echo ""
    echo "SSH check: "
    echo "Port: `cat /etc/ssh/ssh_config | awk -F " " 'NR==40 {print $0}'` "
    echo "PasswordAuthentication: `cat /etc/ssh/ssh_config | awk -F " " 'NR==25 {print $0}'`"
}
currently_mounted_fs () {
    echo ""
    echo "Currently mounted filesystem: "
    mount | column -t
}
network_service_activity_rt () {
    echo ""
    echo "Network services activity in real-time: "
    lsof -i
}
mysql_checks () {
    mysqlver=`mysql --version 2>/dev/null`
if [ "$mysqlver" ]; then
  echo -e "\e[00;31m[-] MYSQL version:\e[00m\n$mysqlver" 
  echo -e "\n"
fi

#checks to see if root/root will get us a connection
mysqlconnect=`mysqladmin -uroot -proot version 2>/dev/null`
if [ "$mysqlconnect" ]; then
  echo -e "\e[00;33m[+] We can connect to the local MYSQL service with default root/root credentials!\e[00m\n$mysqlconnect" 
  echo -e "\n"
fi

#checks to see if root/nopass will get us a connection
mysqlconnect=`mysqladmin -uroot version 2>/dev/null`
if [ "$mysqlconnect" ]; then
  echo -e "\e[00;33m[+] We can connect to the local MYSQL service with default root/root credentials!\e[00m\n$mysqlconnect" 
  echo -e "\n"
fi

#mysql version details
mysqlconnectnopass=`mysqladmin -uroot version 2>/dev/null`
if [ "$mysqlconnectnopass" ]; then
  echo -e "\e[00;33m[+] We can connect to the local MYSQL service as 'root' and without a password!\e[00m\n$mysqlconnectnopass" 
  echo -e "\n"
fi
}
selinux_check () {
    echo ""
    echo "Selinux Enforcing (OK), Permissive, Disabled (NOT OK): `/usr/sbin/getenforce`"
    echo "SELinux status: "
    /usr/sbin/sestatus
    
}
#Ensure mounting of freevxfs filesystems is disabled (Scored)
check_freevxfs () { if [[ $(lsmod | grep freevsx) == true ]];then echo -e "=> freevxfs is $RED ENABLED $NC";else echo -e "=> freevxfs is $GREEN DISABLED $NC";fi }

#Ensure mounting of jffs2 filesystems is disabled (Scored)
check_jffs2 () { if [[ $(lsmod | grep jffs2) == true ]];then echo -e "=> jffs2 is $RED ENABLED $NC";else echo -e "=> jffs2 is $GREEN DISABLED $NC";fi }

#Ensure mounting of hfs filesystems is disabled (Scored)
check_hfs () { if [[ $(lsmod | grep hfs) == true ]];then echo -e "=> hfs is $RED ENABLED $NC";else echo -e "=> hfs is $GREEN DISABLED $NC";fi }

#Ensure mounting of hfsplus filesystems is disabled (Scored)
check_hfsplus () { if [[ $(lsmod | grep hfsplus) == true ]];then echo -e "=> hfsplus is $RED ENABLED $NC";else echo -e "=> hfsplus is $GREEN DISABLED $NC";fi }

#Ensure mounting of udf filesystems is disabled (Scored)
check_udf () { if [[ $(lsmod | grep udf) == true ]];then echo -e "=> udf is $RED ENABLED $NC";else echo -e "=> udf is $GREEN DISABLED $NC";fi }
#Cron check
cron_1 () {
    if [[ $(systemctl is-enabled cron) == "Enabled" ]]
    then
    echo "=> Cron $GREEN ENABLED $NC"
    else echo -e "=> Cron $RED DISABLED $NC"
    fi
    
    if [[ $(ls -l /etc/crontab | awk -F " " {'print $1'}) == "-rw-------" ]]
    then
    echo -e "=> Crontab rights is $GREEN OK $NC"
    else
    echo -e "=> Crontab rights is $RED NOT OK, `ls -l /etc/crontab | awk -F " " '{print $1}'`$NC"
    fi
    
    if [[ $(stat /etc/cron.hourly | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then
    echo -e "=> Cron.hourly rights is $GREEN OK $NC"
    else 
    echo -e "=> Cron.hourly rights is $RED NOT OK $NC"
    fi
    
    if [[ $(stat /etc/cron.daily | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then
    echo -e "=> Cron.daily rights is $GREEN OK $NC"
    else 
    echo -e "=> Cron.daily rights is $RED NOT OK $NC"
    fi
    
    if [[ $(stat /etc/cron.weekly | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then
    echo -e "=> Cron.weekly rights is $GREEN OK $NC"
    else 
    echo -e "=> Cron.weekly rights is $RED NOT OK $NC"
    fi
    
    if [[ $(stat /etc/cron.monthly | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then
    echo -e "=> Cron.monthly rights is $GREEN OK $NC"
    else 
    echo -e "=> Cron.monthly rights is $RED NOT OK $NC"
    fi
}

main() {
check_system
user_processes
open_ports
key_file_owner_check
pass_policy_1
non_root_uid
disableb_root_login
kernel_hardering_info
SUID_list
SGID_list
sudo_version
ssh_checks
network_service_activity_rt
currently_mounted_fs
mysql_checks
selinux_check
check_freevxfs
check_jffs2
check_hfs
check_hfsplus
check_udf
cron_1
}

main
