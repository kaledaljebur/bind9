#!/bin/bash

echo "This script is created by Kaled Aljebur to enable Netplan"
echo "network managment in LinuxMint for teaching in my classes."
#Disable NetworkManager
echo "Disable NetworkManager..."
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

#Enable systemd-networkd to manage networking
echo "Enabling systemd-networkd for network management..."
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd

#Rename the available profile, unlike NetworManager, Netplan only working with .yaml, not .yml
sudo mv /etc/netplan/01-network-manager-all.yml /etc/netplan/01-network-manager-all.yaml

#Edit the Netplan YAML profile
echo "Create Netplan YAML progfile..."
sudo tee /etc/netplan/01-network-manager-all.yaml > /dev/null <<EOF
# Create by Kaled Aljebur as a sample and tested in VMware enviroment.
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 192.168.8.50/24
      gateway4: 192.168.8.2
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF

#Apply the Netplan profile
echo "Apply the Netplan profile..."
sudo netplan apply

#Pause to get the changes applied
echo "Waiting the changes to be applied..."
sleep 3

#List the new IP settings
echo "List the new IP settings..."
ip a sh ens33

sleep 2
echo "***********************************"
echo "Installing bind9 will start soon..."
echo "***********************************"

#Install bind9
sudo apt install -y netplan.io bind9

#bind9 setup 
sudo mkdir -p /etc/bind/zones

sudo tee /etc/bind/named.conf.local > /dev/null <<EOF
zone "215.lab" {
    type master;
    file "/etc/bind/zones/db.215.lab";
};
EOF

#Zone file for 215.lab domain
sudo tee /etc/bind/zones/db.215.lab > /dev/null <<EOF
\$TTL 604800
@ IN SOA 215.lab. admin.lab. (
1 ; Serial
604800 ; Refresh
86400 ; Retry
2419200 ; Expire
604800 ) ; Negative Cache TTL

@ IN NS 215.lab.
215 IN A 192.168.8.50
linux IN A 192.168.8.30
win IN A 192.168.8.40
metasploitable IN A 192.168.8.20
EOF

#Start and and auto start bind9 after reboot
sudo systemctl start bind9
sudo systemctl enable named

#Test bind9 status
sudo systemctl status bind9 --no-pager