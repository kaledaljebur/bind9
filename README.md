# bind9
This script will install and quickly configure bind9 DNS server.
It is tested in LinuxMint 22.1 Xfce.
This script can be used for Lab7 as part of the topology in VU232215 unit Cert IV Cybersecurity course.

Please let me know if you have any questions.

Regards, Kaled Aljebur.
- Download [bind9-dns-install.sh](https://github.com/kaledaljebur/bind9/blob/main/bind9-dns-install.sh)
- Open the Terminal and type the following:
    - `cd Downloads`    
    - `chmode u+x bind9-dns-install.sh`
    - `sudo ./bind9-dns-install.sh`
- For testing after the installation:
    - It should be no error when you run `sudo named-checkzone 215.lab /etc/bind/zones/db.215.lab`
    - When you run `dig @192.168.8.50 215.lab` in or outside the DNS machine, the status should be `status: NOERROR`.
    - In or outside the DNS machine, the mapping IP should be listed if you run any of the following:
        - `dig @192.168.8.50 ns.215.lab` >> 192.168.8.50 which the DNS machine itself.
        - `dig @192.168.8.50 linux.215.lab` >> 192.168.8.30 which LinuxMint.
        - `dig @192.168.8.50 win.215.lab` >> 192.168.8.400 which is Windows.
        - `dig @192.168.8.50 metasploitable.215.lab` >> 192.168.8.20 for Metasploitable.
    When you test wrong subdomain, like `dig @192.168.8.50 win2.215.lab`, the status will be `status: NXDOMAIN`.

- To disbale zone transfer:
    - Change `allow-transfer { any; }` into `allow-transfer { none; }`, or you can add trusted IP for allowed zone transfer request using `allow-transfer { 192.168.8.10; }`.
    - Notice: removing or hashing `allow-transfer...` will make it act like `allow-transfer{any;}` because this is the default.
    - Use `sudo systemctl restart bind9` to apply any changes.