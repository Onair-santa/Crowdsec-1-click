## <a href="#"><img src="https://github.com/vpnhood/VpnHood/wiki/images/logo-linux.png" width="32" height="32"></a>(Debian, Ubuntu) Crowdsec-1-click
###  Bash script installs Crowdsec and settings file, and installs nftables to block IP addresses
![image](https://github.com/Onair-santa/Fail2ban-1-click/assets/42511409/0d8d0f7e-4e6f-4d31-8d59-81049d15137a)
#### 💠  Ensure that the `sudo` and `wget` packages are installed on your system:

```
apt install -y sudo wget
```

#### 💠 Root Access is Required. If the user is not root, first run:

```
sudo -i
```

#### 💠 Then:

```
wget "https://raw.githubusercontent.com/Onair-santa/Crowdsec-1-click/main/install.sh" -O install.sh && chmod +x install.sh && bash install.sh
```
#### It performs the following tasks:
- Remove firewalld, ufw or iptables
- Install nftables
- Open ports 22, 443, 80
- Install Crowdsec
- install config Crowdsec
- Starting Crowdsec
#### Config Crowdsec :
- config /etc/crowdsec/config.yaml (online community (blocked IP) base is disabled)
- bounsers list: firewall-bouncer
- Bucket list: ssh-bf, ssh-slow-bf
- Status command:
  
  ```
  cscli metrics
  cscli decisions list
  cscli alerts list
  cscli bouncers list
  ```

#### 💠 Thanks and more info
https://github.com/crowdsecurity/crowdsec
