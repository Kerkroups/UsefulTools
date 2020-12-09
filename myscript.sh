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
    then echo -e "/etc/fstab owned by user $GREEN ROOT and ROOT GROUP $NC"
    else echo -e "/etc/fstab owned by user $RED`ls -l /etc/fstab | awk -F " " {'print $3}` and group `ls -l /etc/fstab | awk -F " " {'print $4`$NC"
    fi
    
    if [[ $(ls -l /etc/passwd | awk -F " " {'print $3,$4'}) == "root root" ]]
    then echo -e "/etc/passwd owned by user $GREEN ROOT and ROOT GROUP $NC"
    else echo -e "/etc/passwd owned by user $RED`ls -l /etc/passwd | awk -F " " {'print $3'}` and group `ls -l /etc/passwd | awk -F " " {'print $4'}`$NC"
    fi
    
    if [[ $(ls -l /etc/shadow | awk -F " " {'print $3,$4'}) == "root root" ]]
    then echo -e "/etc/shadow owned by user $GREEN ROOT and ROOT GROUP $NC"
    else echo -e "/etc/shadow owned by user $RED`ls -l /etc/shadow | awk -F " " {'print $3'}`$NC and group $RED`ls -l /etc/shadow | awk -F " " {'print $4'}`$NC"
    fi
    
    if [[ $(ls -l /etc/group | awk -F " " {'print $3,$4'}) == "root root" ]]
    then echo -e "/etc/group owned by user $GREEN ROOT and ROOT GROUP $NC"
    else echo -e "/etc/group owned by user $RED`ls -l /etc/group | awk -F " " {'print $3}` and group `ls -l /etc/group | awk -F " " {'print $4`$NC"
    fi
    
    if [[ $(ls -l /etc/passwd | awk -F " " {'print $1'}) == "rw-r--r--" ]]
    then echo -e "$GREEN Permissions of /etc/passwd is OK $NC"
    else echo -e "$RED Permissions of /etc/passwd must be rw-r--r--! NOT OK $NC"
    fi
    
    if [[ $(ls -l /etc/group | awk -F " " {'print $1'}) == "rw-r--r--" ]]
    then echo -e "$GREEN Permissions of /etc/group is OK $NC"
    else echo -e "$RED Permissions of /etc/group must be rw-r--r--! NOT OK $NC"
    fi
    
    if [[ $(ls -l /etc/shadow | awk -F " " {'print $1'}) == "r--------" ]]
    then echo -e "$GREEN Permissions of /etc/shadow is OK $NC"
    else echo -e "$RED Permissions of /etc/shadow must be r--------! NOT OK $NC"
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
    then echo "Root login is DISABLED, OK."
    else echo "Root login is ENABLED, BAD."
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
    then echo "=> Cron $GREEN ENABLED $NC"
    else echo -e "=> Cron $RED DISABLED $NC"
    fi
    
    if [[ $(ls -l /etc/crontab | awk -F " " {'print $1'}) == "-rw-------" ]]
    then echo -e "=> Crontab rights is $GREEN OK $NC"
    else echo -e "=> Crontab rights is $RED NOT OK, `ls -l /etc/crontab | awk -F " " '{print $1}'`$NC"
    fi
    
    if [[ $(stat /etc/cron.hourly | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then echo -e "=> Cron.hourly rights is $GREEN OK $NC"
    else echo -e "=> Cron.hourly rights is $RED NOT OK $NC"
    fi
    
    if [[ $(stat /etc/cron.daily | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then echo -e "=> Cron.daily rights is $GREEN OK $NC"
    else echo -e "=> Cron.daily rights is $RED NOT OK $NC"
    fi
    
    if [[ $(stat /etc/cron.weekly | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then echo -e "=> Cron.weekly rights is $GREEN OK $NC"
    else echo -e "=> Cron.weekly rights is $RED NOT OK $NC"
    fi
    
    if [[ $(stat /etc/cron.monthly | awk -F " " 'NR==4 {print $2}') == "(0700/drwx------)" ]]
    then echo -e "=> Cron.monthly rights is $GREEN OK $NC"
    else echo -e "=> Cron.monthly rights is $RED NOT OK $NC"
    fi
}

ntp_check () {
    if [[ $(grep "^restrict" /etc/ntp.conf | awk 'NR==1') == "restrict -4 default kod notrap nomodify nopeer noquery limited" ]] && [[ $(grep "^restrict" /etc/ntp.conf | awk 'NR==2') == "restrict -6 default kod notrap nomodify nopeer noquery limited" ]]
    then echo "NTP check PASSED"
    else echo "NTP ckeck FAILED"
    fi
    
    if [[ $( grep "RUNASUSER=ntp" /etc/init.d/ntp) == "RUNASUSER=ntp" ]]
    then echo "NTP user PASSED"
    else echo "NTP user FAILED"
    fi
}

xorg_check () {
    if [[ $(dpkg -l xserver-xorg* | awk 'NR > 5') != 0 ]]
    then echo -e "Xorg server FOUND"
    else echo -e "Xorg server NOT FOUND"
    fi 
}

avahi_check () {
    if [[ $(systemctl is-enabled avahi-daemon) == "disabled" ]]
    then echo -e "Avahi daemon is DISABLED"
    else echo -e "Avahi daemon is ENABLED"
    fi
}

cups_check () {
    if [[ $(systemctl is-enabled cups) == "disabled" ]]
    then echo -e "Cups daemon is DISABLED"
    else echo -e "Cups daemon is ENABLED"
    fi
}

dhcp_check () {
    if [[ $(systemctl is-enabled isc-dhcp-server | grep -wo "disabled") == *"disabled"* ]]
    then echo -e "DHCP-SERVER-4 DISABLED"
    else echo "DHCP-SERVER-4 ENABLED"
    fi 2>/dev/null
    
    if [[ $(systemctl is-enabled isc-dhcp-server6) ]]
    then echo "DHCP-SERVER-6 FOUND"
    else echo -e "DHCP-SERVER-6 NOT FOUND"
    fi 2>/dev/null
}

sldap_check () {
    if [[ $(systemctl is-enabled slapd) ]]
    then echo "LDAP SERVER FOUND"
    else echo -e "LDAP SERVER NOT FOUND"
    fi 2>/dev/null
}

nfs_check () {
    if [[ $(systemctl is-enabled nfs-server) == "enabled" ]]
    then echo "NFS ENABLED"
    elif [[ $(systemctl is-enabled nfs-server) == "disabled" ]]
    then echo -e "NFS DISABLED"
    else echo "NFS NOT FOUND"
    fi 2>/dev/null
    
    if [[ $(systemctl is-enabled rpcbind) == "enabled" ]]
    then echo -e "RPC is ENABLED"
    else echo -e "RPC is DISABLED"
    fi
}

dns_bind9_check () {
    if [[ $(systemctl is-enabled bind9) == "enabled" ]]
    then echo -e "BIND9 ENABLED"
    elif [[ $(systemctl is-enabled bind9) == "disabled" ]]
    then echo -e "BIND9 DISABLED"
    else echo "NFS NOT FOUND"
    fi 2>/dev/null
}

vsftpd_check () {
    if [[ $(systemctl is-enabled vsftpd) == "enabled" ]]
    then echo -e "vsftpd ENABLED"
    elif [[ $(systemctl is-enabled vsftpd) == "disabled" ]]
    then echo -e "vsftpd DISABLED"
    else echo "vsftpd NOT FOUND"
    fi 2>/dev/null
}

apache2_check () {
    if [[ $(systemctl is-enabled apache2) == "enabled" ]]
    then echo -e "apache2 ENABLED"
    elif [[ $(systemctl is-enabled apache2) == "disabled" ]]
    then echo -e "apache2 DISABLED"
    else echo "apache2 NOT FOUND"
    fi 2>/dev/null
}
imap_pop3_check () {
    if [[ $(dpkg -s exim4 | awk 'NR==1') == "dpkg-query: package 'exim4' is not installed and no information is available" ]]
    then echo -e "IMAP/POP3 NOT INSTALLED"
    else echo "REMOVE IMAP/POP3"
    fi 2>/dev/null
}

smbd_check () {
    if [[ $(systemctl is-enabled smbd) == "enabled" ]]
    then echo -e "smbd ENABLED"
    elif [[ $(systemctl is-enabled smbd) == "disabled" ]]
    then echo -e "smbd DISABLED"
    else echo "smbd NOT FOUND"
    fi 2>/dev/null
}

squid_check () {
    if [[ $(systemctl is-enabled squid) == "enabled" ]]
    then echo -e "squid ENABLED"
    elif [[ $(systemctl is-enabled squid) == "disabled" ]]
    then echo -e "squid DISABLED"
    else echo "squid NOT FOUND"
    fi 2>/dev/null
}

snmpd_check () {
    if [[ $(systemctl is-enabled snmpd) == "enabled" ]]
    then echo -e "snmpd ENABLED"
    elif [[ $(systemctl is-enabled snmpd) == "disabled" ]]
    then echo -e "snmpd DISABLED"
    elif [[ $(systemctl is-enabled snmpd) == "masked" ]]
    then echo -e "snmpd MASKED"
    else echo "squid NOT FOUND"
    fi 2>/dev/null
}

ssh_checks() {
echo "==================================================================================================================="
echo "SSH CONFIGURATION CHECKS"
echo "SSHD CONFIG PERMISIONS"
if [[$(ls -l /etc/ssh/sshd_config | awk -F " " '{print $1,$3,$4}') == "-rw-r--r-- root root"]]
then echo -e "$RED Permission must be -rw------- $NC"
elif [[$(ls -l /etc/ssh/sshd_config | awk -F " " '{print $1,$3,$4}') == "-rw------- root root"]]
then echo -e "$GREEN PASS $NC"
else echo -e "$RED Check owner and permissions $NC"
fi 2>/dev/null
echo "PRIVATE KEY PERMISSIONS"
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec ls -l {} \; | awk -F " " '{print $1,$3,$4}' | while read -r line 
do
    if [[ $line == "-rw------- root root" ]]
    then echo -e "$GREEN PASS $NC"
    else echo -e "$RED Check permissions and owner of SSH private key $NC"
    fi
done 2>/dev/null
echo "PUBLIC KEY PERMISSIONS"
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec ls -l {} \; | awk -F " " '{print $1,$3,$4}' | while read -r line 
do
    if [[ $line == "-rw-r--r-- root root" ]]
    then echo -e "$GREEN PASS $NC"
    else echo -e "$RED Check permissions and owner of SSH private key $NC"
    fi
done

if [[ $(service ssh status | awk -F " " 'NR==3 {print $3}') == "(running)" ]]
then
echo -e "SSH RUNNING"
    if [[ $(sshd -T | grep loglevel) == "loglevel INFO" || $(sshd -T | grep loglevel) == "loglevel VERBOSE" ]]
    then echo -e "LOGLEVEL CHECK $GREEN PASS $NC"
    else echo -e "LOGLEVEL CHECK $RED FAILED $NC"
    fi
else echo -e "SSH NOT RUNNING"
fi

if [[ $(sshd -T | grep x11forwarding | awk -F " " {'print $2'}) == "yes" ]]
then
echo -e "$RED X11 FORWARDING ENABLED $NC"
elif [[ $(sshd -T | grep x11forwarding | awk -F " " {'print $2'}) == "no" ]]
then echo -e "$GREEN X11 FORWARDING DISABLED $NC"
else echo "CHECK CONFIG"
fi

if [[ $(sshd -T | grep maxauthtries | awk -F " " {'print $2'}) == "4" ]]
then echo -e "$GREEN PASS $NC" 
else echo -e "$RED FAILED, SET MaxAuthTries to 4 $NC"
fi

if [[ $(sshd -T | grep ignorerhosts |awk -F " " {'print $2'}) == "yes" ]]
then echo -e "IgnoreRhosts is $GREEN enabled $NC"
else echo -e "IgnoreRhosts is $RED disabled $NC"
fi

if [[ $(sshd -T | grep hostbasedauthentication | awk -F " " {'print $2'}) == "no" ]]
then echo -e "SSH HostbasedAuthentication is $GREEN disabled $NC"
else echo -e "SSH HostbasedAuthentication is $RED enabled $NC"
fi

if [[ $(sshd -T | grep permitrootlogin |awk -F " " {'print $2'}) == "no" ]]
then echo -e "SSH root login is $GREEN disabled $NC"
else echo -e "$RED Check SSH root login configuration $NC"
fi

if [[ $(sshd -T | grep permitemptypasswords | awk -F " " {'print $2'}) == "no" ]]
then echo -e "SSH PermitEmptyPasswords is $GREEN disabled $NC"
else echo -e "SSH PermitEmptyPasswords is $RED enabled $NC"
fi

if [[ $(sshd -T | grep permituserenvironment | awk -F " " {'print $2'}) == "no" ]]
then echo -e "SSH permituserenvironment is $GREEN disabled $NC"
else echo -e "SSH permituserenvironment is $RED enabled $NC"
fi

if [[ $(sshd -T | grep clientaliveinterval | awk -F " " {'print $2'}) == "300" && $(sshd -T | grep clientalivecountmax | awk -F " " {'print $2'}) == "0" ]]
then echo -e "SSH Idle Timeout Interval check $GREEN PASS$NC"
else echo -e "$RED FAILED $NC"
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
ntp_check
xorg_check
avahi_check
cups_check
dhcp_check
sldap_check
nfs_check
vsftpd_check
apache2_check
imap_pop3_check
smbd_check
squid_check
snmpd_check
}

main
