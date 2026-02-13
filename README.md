## <a href="#"><img src="https://github.com/vpnhood/VpnHood/wiki/images/logo-linux.png" width="32" height="32"></a>(Debian, Ubuntu) Crowdsec-1-click
###  Crowdsec - is the best analog Fail2ban, the open-source security solution for youre server
###  Bash script installs Crowdsec and settings file, and installs nftables to block IP addresses
![image](https://github.com/Onair-santa/Crowdsec-1-click/assets/42511409/b0d187a4-89b9-4b90-8dbb-824e35fdd39f)

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
- Open ports 22, 443, 80, 8080
- Install Crowdsec
- install config Crowdsec
- Starting Crowdsec
#### Config Crowdsec :
- config /etc/crowdsec/config.yaml
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
