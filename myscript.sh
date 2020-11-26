#!/bin/bash

check_system () {
    echo "Print certain system information"
    uname -a
}

user_processes () {
    echo ""
    echo "List of process runned by user `whoami`"
    ps -a -u `whoami`
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
    echo "/etc/fstab owned by user ROOT and ROOT GROUP"
    else
    echo "/etc/fstab owned by user `ls -l /etc/fstab | awk -F " " {'print $3}` and group `ls -l /etc/fstab | awk -F " " {'print $4`"
    fi
    
    if [[ $(ls -l /etc/passwd | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo "/etc/passwd owned by user ROOT and ROOT GROUP"
    else
    echo "/etc/passwd owned by user `ls -l /etc/passwd | awk -F " " {'print $3'}` and group `ls -l /etc/passwd | awk -F " " {'print $4'}`"
    fi
    
    if [[ $(ls -l /etc/shadow | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo "/etc/shadow owned by user ROOT and ROOT GROUP"
    else
    echo "/etc/shadow owned by user `ls -l /etc/shadow | awk -F " " {'print $3'}` and group `ls -l /etc/shadow | awk -F " " {'print $4'}`"
    fi
    
    if [[ $(ls -l /etc/group | awk -F " " {'print $3,$4'}) == "root root" ]]
    then
    echo "/etc/group owned by user ROOT and ROOT GROUP"
    else
    echo "/etc/group owned by user `ls -l /etc/group | awk -F " " {'print $3}` and group `ls -l /etc/group | awk -F " " {'print $4`"
    fi
    
    if [[ $(ls -l /etc/passwd | awk -F " " {'print $1'}) == "rw-r--r--" ]]
    then
    echo "Permissions of /etc/passwd is OK"
    else
    echo "Permissions of /etc/passwd must be rw-r--r--! NOT OK"
    fi
    
    if [[ $(ls -l /etc/group | awk -F " " {'print $1'}) == "rw-r--r--" ]]
    then
    echo "Permissions of /etc/group is OK"
    else
    echo "Permissions of /etc/group must be rw-r--r--! NOT OK"
    fi
    
    if [[ $(ls -l /etc/shadow | awk -F " " {'print $1'}) == "r--------" ]]
    then
    echo "Permissions of /etc/shadow is OK"
    else
    echo "Permissions of /etc/shadow must be r--------! NOT OK"
    fi
}

pass_policy_1 () {
    echo ""
    echo "Check password policy"
    cat /etc/login.defs | grep "PASS_MAX_DAYS\|PASS_MIN_DAYS\|PASS_WARN_AGE\|PASS_MIN_LEN\|LOGIN_RETRIES\|LOGIN_TIMEOUT"
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

