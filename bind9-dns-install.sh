#!/bin/bash

echo "This script is created by Kaled Aljebur to Install Bind9 DNS server."
echo "This also include enabling Netplan and brief IP and DNS setup."
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
# Create by Kaled Aljebur as a sample and tested in VMware environment.
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
          - 192.168.8.2
          # - 1.1.1.1
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
/* Comments block start
Commented by Kaled Aljebur.

To disable zone transfer:
Change "allow-transfer { any; }" into "allow-transfer { none; }",
or you can add trusted IP for allowed zone transfer request
using "allow-transfer { 192.168.8.10; }".

Notice: removing or hashing "allow-transfer..." will make it act
like "allow-transfer{any;}" because this is the default.

Use "sudo systemctl restart bind9" to apply any changes.

Comments block end*/

zone "vu23215.lab" {
type master;
file "/etc/bind/zones/db.vu23215.lab";
allow-transfer { any; };
};
EOF

#Zone file for vu23215.lab domain, \ will escape $
sudo tee /etc/bind/zones/db.vu23215.lab > /dev/null <<EOF
\$TTL 604800
@ IN SOA ns.vu23215.lab. admin.lab. (
1 ; Serial
604800 ; Refresh
86400 ; Retry
2419200 ; Expire
604800 ) ; Negative Cache TTL

@ IN NS ns.vu23215.lab.
ns IN A 192.168.8.50
linux IN A 192.168.8.30
win IN A 192.168.8.40
metasploitable IN A 192.168.8.20
EOF

#This to make sure the Mint machine will use the NAT IP as external DNS server
echo "Make sure the NAT IP is used as external DNS server..."
sudo tee /etc/bind/named.conf.options > /dev/null <<EOF
# Create by Kaled Aljebur as a sample and tested in VMware environment.
options {
    directory "/var/cache/bind";
    recursion yes;
    allow-recursion { any; };
    listen-on { any; };
    listen-on-v6 { any; };
    forwarders {
        192.168.8.2;
    };
    dnssec-validation no;
    auth-nxdomain no;
};
EOF

#Start and and auto start bind9 after reboot
sudo systemctl start bind9
sudo systemctl enable named

sleep 2
echo "***********************************"
echo "Restart bind9 to make sure it is working fine..."
echo "***********************************"

sudo systemctl restart bind9

#Test bind9 status
sudo systemctl status bind9 --no-pager