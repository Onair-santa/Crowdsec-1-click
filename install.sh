#!/bin/bash

clear
yellow_msg() {
    tput setaf 3
    echo "  $1"
    tput sgr0
}

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[0;37m'
rest='\033[0m'

ext_interface () {
    for interface in /sys/class/net/*
    do
        [[ "${interface##*/}" != 'lo' ]] && \
            ping -c1 -W2 -I "${interface##*/}" 208.67.222.222 >/dev/null 2>&1 && \
                printf '%s' "${interface##*/}" && return 0
    done
}
INTERFACE=$(ext_interface)

install_nftables () {
echo
yellow_msg 'Installing Nftables...'
echo 
sleep 0.5

# Purge firewalld to install NFT.
sudo apt -y purge firewalld ufw iptables

# Install NFT if it isn't installed.
sudo apt update -q
sudo apt install -y nftables

# Start and enable nftables
sudo systemctl start nftables
sudo systemctl enable nftables
sleep 0.5

# Open default ports.
sudo nft add rule inet filter input iifname lo accept
sudo nft add rule inet filter input ct state established,related accept
sudo nft add rule inet filter input iifname "$INTERFACE" tcp dport 22 accept
sudo nft add rule inet filter input iifname "$INTERFACE" tcp dport 80 accept
sudo nft add rule inet filter input iifname "$INTERFACE" tcp dport 443 accept
sudo nft add chain inet filter input '{ policy drop; }'
sleep 0.5
echo '#!/usr/sbin/nft -f' > /etc/nftables.conf
sleep 0.5
echo 'flush ruleset' >> /etc/nftables.conf
sleep 0.5
sudo nft list ruleset | sudo tee -a /etc/nftables.conf
sleep 0.5

# Enable & Reload
sudo systemctl restart nftables
echo 
yellow_msg 'NFT is Installed. (Ports 22, 80, 443 is opened)'
echo 
sleep 0.5
}

# Install Crowdsec
crowdsec_install() {
    echo
    yellow_msg 'Installing & Optimizing Crowdsec...'
    echo 
    sleep 0.5
    
    curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash && sudo apt install crowdsec
    sleep 0.5
    sudo apt install crowdsec-firewall-bouncer-nftables
    cat >/etc/crowdsec/config.yaml <<-\EOF
common:
  daemonize: true
  log_media: file
  log_level: info
  log_dir: /var/log/
  log_max_size: 20
  compress_logs: true
  log_max_files: 10
  working_dir: .
config_paths:
  config_dir: /etc/crowdsec/
  data_dir: /var/lib/crowdsec/data/
  simulation_path: /etc/crowdsec/simulation.yaml
  hub_dir: /etc/crowdsec/hub/
  index_path: /etc/crowdsec/hub/.index.json
  notification_dir: /etc/crowdsec/notifications/
  plugin_dir: /usr/lib/crowdsec/plugins/
crowdsec_service:
  acquisition_path: /etc/crowdsec/acquis.yaml
  acquisition_dir: /etc/crowdsec/acquis.d
  parser_routines: 1
cscli:
  output: human
  color: auto
db_config:
  log_level: info
  type: sqlite
  db_path: /var/lib/crowdsec/data/crowdsec.db
  flush:
    max_items: 5000
    max_age: 7d
plugin_config:
  user: nobody # plugin process would be ran on behalf of this user
  group: nogroup # plugin process would be ran on behalf of this group
api:
  client:
    insecure_skip_verify: false
    credentials_path: /etc/crowdsec/local_api_credentials.yaml
  server:
    log_level: info
    listen_uri: 127.0.0.1:8080
    profiles_path: /etc/crowdsec/profiles.yaml
    console_path: /etc/crowdsec/console.yaml
    #online_client: # Central API credentials (to push signals and receive bad IPs)
      #credentials_path: /etc/crowdsec/online_api_credentials.yaml
    trusted_ips: # IP ranges, or IPs which can have admin API access
      - 127.0.0.1
      - ::1
prometheus:
  enabled: true
  level: full
  listen_addr: 127.0.0.1
  listen_port: 6060
EOF
    cscli collections install crowdsecurity/iptables
    # Reload
    sudo systemctl reload crowdsec
    echo 
    yellow_msg 'Crowdsec Installed & Optimized.'
    echo 
    sleep 0.5
}

# Menu
clear
echo -e "${cyan}********************************${rest}"
echo -e "${green}  1-click Crowdsec + Nftables      ${rest}"
echo -e "${cyan}********************************${rest}" 
echo ""
echo -e "       ${green}Select an option${rest}: ${rest}"
echo -e "${green}1. - ${green}Install Crowdsec + Nftables${rest}"
echo -e "${cyan}2. - ${cyan}Install Nftables only${rest}"
echo -e "${cyan}3. - ${cyan}Install Crowdsec only${rest}"
echo -e "${red}0. - ${red}Exit${rest}"
echo ""
read -p "Enter your choice: " choice
case "$choice" in
    1)
        install_nftables
        crowdsec_install
        ;;
    2)
        install_nftables
        ;;
    3)
        crowdsec_install
        ;;
    0)
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
