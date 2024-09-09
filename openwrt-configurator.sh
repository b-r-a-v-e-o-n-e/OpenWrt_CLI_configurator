#!/bin/bash

# Terminal colors for better UI experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m' # No color

# Function to configure network settings
configure_network() {
    echo -e "${BLUE}--- Network Configuration ---${NC}"
    echo -e "${YELLOW}1) Set LAN IP Address"
    echo -e "2) Set LAN Netmask"
    echo -e "3) Set LAN Gateway"
    echo -e "4) Set LAN DNS Server"
    echo -e "5) Back to Main Menu${NC}"
    read -p "Select an option: " network_option

    case $network_option in
        1)
            read -p "Enter new LAN IP Address (e.g., 192.168.1.1): " lan_ip
            uci set network.lan.ipaddr="$lan_ip"
            uci commit network
            /etc/init.d/network reload
            echo -e "${GREEN}LAN IP Address updated to $lan_ip${NC}"
            ;;
        2)
            read -p "Enter new LAN Netmask (e.g., 255.255.255.0): " lan_netmask
            uci set network.lan.netmask="$lan_netmask"
            uci commit network
            /etc/init.d/network reload
            echo -e "${GREEN}LAN Netmask updated to $lan_netmask${NC}"
            ;;
        3)
            read -p "Enter new LAN Gateway: " lan_gateway
            uci set network.lan.gateway="$lan_gateway"
            uci commit network
            /etc/init.d/network reload
            echo -e "${GREEN}LAN Gateway updated to $lan_gateway${NC}"
            ;;
        4)
            read -p "Enter new DNS Server IP: " dns_server
            uci add_list network.lan.dns="$dns_server"
            uci commit network
            /etc/init.d/network reload
            echo -e "${GREEN}DNS Server set to $dns_server${NC}"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Function to configure Wi-Fi
configure_wifi() {
    echo -e "${BLUE}--- Wi-Fi Configuration ---${NC}"
    echo -e "${YELLOW}1) Enable/Disable Wi-Fi"
    echo -e "2) Set SSID"
    echo -e "3) Set Wi-Fi Password"
    echo -e "4) Set Wi-Fi Channel"
    echo -e "5) Back to Main Menu${NC}"
    read -p "Select an option: " wifi_option

    case $wifi_option in
        1)
            read -p "Enable Wi-Fi (1 to enable, 0 to disable): " wifi_status
            uci set wireless.@wifi-iface[0].disabled="$wifi_status"
            uci commit wireless
            /etc/init.d/network reload
            echo -e "${GREEN}Wi-Fi status updated.${NC}"
            ;;
        2)
            read -p "Enter new SSID: " wifi_ssid
            uci set wireless.@wifi-iface[0].ssid="$wifi_ssid"
            uci commit wireless
            /etc/init.d/network reload
            echo -e "${GREEN}SSID updated to $wifi_ssid${NC}"
            ;;
        3)
            read -p "Enter new Wi-Fi Password: " wifi_password
            uci set wireless.@wifi-iface[0].key="$wifi_password"
            uci commit wireless
            /etc/init.d/network reload
            echo -e "${GREEN}Wi-Fi password updated.${NC}"
            ;;
        4)
            read -p "Enter Wi-Fi Channel (e.g., 1-11): " wifi_channel
            uci set wireless.@wifi-device[0].channel="$wifi_channel"
            uci commit wireless
            /etc/init.d/network reload
            echo -e "${GREEN}Wi-Fi channel updated to $wifi_channel${NC}"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Function to configure firewall
configure_firewall() {
    echo -e "${BLUE}--- Firewall Configuration ---${NC}"
    echo -e "${YELLOW}1) Allow Traffic to LAN"
    echo -e "2) Block Traffic to WAN"
    echo -e "3) Set Custom Port Forward"
    echo -e "4) Back to Main Menu${NC}"
    read -p "Select an option: " firewall_option

    case $firewall_option in
        1)
            uci set firewall.@zone[0].input='ACCEPT'
            uci commit firewall
            /etc/init.d/firewall reload
            echo -e "${GREEN}LAN traffic allowed.${NC}"
            ;;
        2)
            uci set firewall.@zone[1].input='REJECT'
            uci commit firewall
            /etc/init.d/firewall reload
            echo -e "${GREEN}WAN traffic blocked.${NC}"
            ;;
        3)
            read -p "Enter external port to forward: " ext_port
            read -p "Enter internal IP: " int_ip
            read -p "Enter internal port: " int_port
            uci add firewall redirect
            uci set firewall.@redirect[-1].src='wan'
            uci set firewall.@redirect[-1].src_dport="$ext_port"
            uci set firewall.@redirect[-1].dest='lan'
            uci set firewall.@redirect[-1].dest_ip="$int_ip"
            uci set firewall.@redirect[-1].dest_port="$int_port"
            uci commit firewall
            /etc/init.d/firewall reload
            echo -e "${GREEN}Port forward set: External port $ext_port to $int_ip:$int_port${NC}"
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Function to configure DHCP
configure_dhcp() {
    echo -e "${BLUE}--- DHCP Configuration ---${NC}"
    echo -e "${YELLOW}1) Set DHCP Start Range"
    echo -e "2) Set DHCP Limit"
    echo -e "3) Set Lease Time"
    echo -e "4) Back to Main Menu${NC}"
    read -p "Select an option: " dhcp_option

    case $dhcp_option in
        1)
            read -p "Enter DHCP Start IP (e.g., 100): " dhcp_start
            uci set dhcp.lan.start="$dhcp_start"
            uci commit dhcp
            /etc/init.d/dnsmasq reload
            echo -e "${GREEN}DHCP start range updated to $dhcp_start${NC}"
            ;;
        2)
            read -p "Enter DHCP limit: " dhcp_limit
            uci set dhcp.lan.limit="$dhcp_limit"
            uci commit dhcp
            /etc/init.d/dnsmasq reload
            echo -e "${GREEN}DHCP limit updated to $dhcp_limit${NC}"
            ;;
        3)
            read -p "Enter DHCP lease time (e.g., 12h, 1d): " lease_time
            uci set dhcp.lan.leasetime="$lease_time"
            uci commit dhcp
            /etc/init.d/dnsmasq reload
            echo -e "${GREEN}DHCP lease time set to $lease_time${NC}"
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
}

# Main menu
while true; do
    echo -e "${YELLOW}--- OpenWrt CLI Configuration Menu ---${NC}"
    echo "1) Configure Network"
    echo "2) Configure Wi-Fi"
    echo "3) Configure Firewall"
    echo "4) Configure DHCP"
    echo "5) Exit"
    read -p "Select an option: " main_option

    case $main_option in
        1)
            configure_network
            ;;
        2)
            configure_wifi
            ;;
        3)
            configure_firewall
            ;;
        4)
            configure_dhcp
            ;;
        5)
            echo -e "${GRAY}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac
done
