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
sudo nft add rule inet filter input iifname "$INTERFACE" tcp dport 8080 accept
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
yellow_msg 'NFT is Installed. (Ports 22, 80, 443, 8080 is opened)'
echo 
sleep 0.5
}

# Install Crowdsec
crowdsec_install() {
    echo
    yellow_msg 'Installing Crowdsec...'
    echo 
    sleep 0.5
    
    curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash && sudo apt install crowdsec
    sleep 0.5
    sudo apt install crowdsec-firewall-bouncer-nftables
    
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
