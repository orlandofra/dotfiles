#!/bin/bash

domain=orgiesataniche.com
samba_dir=SatanaDelSesso

####################################################
# don't route traffic to my own sever with openvpn #
####################################################
ip_address=$( dig +short ${domain} )

sudo route add ${ip_address} gw 192.168.1.1

####################
# Connect to samba #
####################
samba_user=francesco
read -p "insert password: " -s samba_pass
echo

current_uid=$(id -u)
current_gid=$(id -g)

sudo mount -t cifs //${domain}/${samba_dir} /media/samba -o \
	username=${samba_user},password=${samba_pass},uid=${current_uid},gid=${current_gid}
