# bind9
This script will install and quickly configure bind9 DNS server.
It is tested in LinuxMint 22.1 Xfce.
This script can be used for Lab7 as part of the topology in VU232215 unit Cert IV Cybersecurity course.

Please let me know if you have any questions.

Regards, Kaled Aljebur.
- Download [bind9-dns-install.sh](https://github.com/kaledaljebur/bind9/blob/main/bind9-dns-install.sh).
- Open the Terminal and type the following:
    - `cd Downloads`.
    - `chmode u+x bind9-dns-install.sh`.
    - `sudo ./bind9-dns-install.sh`.
- For testing after the installation:
    - It should be no error when you run `sudo named-checkzone vu23215.lab /etc/bind/zones/db.vu23215.lab`.
    - When you run `dig @192.168.8.50 vu23215.lab` in or outside the DNS machine, the status should be `status: NOERROR`.
    - In or outside the DNS machine, the mapping IP should be listed if you run any of the following:
        - `dig @192.168.8.50 ns.vu23215.lab` >> 192.168.8.50 which the DNS machine itself.
        - `dig @192.168.8.50 linux.vu23215.lab` >> 192.168.8.30 which LinuxMint.
        - `dig @192.168.8.50 win.vu23215.lab` >> 192.168.8.400 which is Windows.
        - `dig @192.168.8.50 metasploitable.vu23215.lab` >> 192.168.8.20 for Metasploitable.
    - When you test wrong subdomain, like `dig @192.168.8.50 win2.vu23215.lab`, the status will be `status: NXDOMAIN`.
- To transfer the Zone:
    - In Kali, `dig axfr @192.168.8.50 vu23215.lab`.
- To disable zone transfer:
    - In the DNS server, `sudo nano /etc/bind/named.conf.local`.
    - change `allow-transfer { any; }` into `allow-transfer { none; }`, or you can add trusted IP for allowed zone transfer request using `allow-transfer { 192.168.8.x; }`.
    - Notice: removing or hashing `allow-transfer...` will make it act like `allow-transfer{any;}` because this is the default.
    - Use `sudo systemctl restart bind9` to apply any changes.
    - Check errors using `sudo named-checkzone vu23215.lab /etc/bind/zones/db.vu23215.lab`.

- Dictionary-based retrieve disabled zone transfer:
    - Try transfer the Zone after disabling:
        - `dig axfr @192.168.8.50 vu23215.lab`.
    - Download the [subdomains dictionary](https://github.com/danielmiessler/SecLists/blob/master/Discovery/DNS/fierce-hostlist.txt).
    - `sudo fierce --domain vu23215.lab --subdomain-file ~/Downloads/fierce-hostlist.txt --dns-server 192.168.8.50`.
