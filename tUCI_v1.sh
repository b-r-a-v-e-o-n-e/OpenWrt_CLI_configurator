#!/bin/bash

# Път до конфигурационните файлове
NETWORK_CONF="/etc/config/network"
WIRELESS_CONF="/etc/config/wireless"
FIREWALL_CONF="/etc/config/firewall"

# Функция за показване на LAN конфигурацията
show_lan_configuration() {
  LAN_CONFIG=$(uci show network.lan)  # Извличане на LAN конфигурацията с uci
  whiptail --scrolltext --title "LAN Configuration" --msgbox "$LAN_CONFIG" 20 60
}

# Функция за показване на Wi-Fi конфигурацията
show_wifi_configuration() {
  WIFI_CONFIG=$(uci show wireless)  # Извличане на Wi-Fi конфигурацията с uci
  whiptail --scrolltext --title "Wi-Fi Configuration" --msgbox "$WIFI_CONFIG" 20 60
}

# Функция за показване на firewall конфигурацията
show_firewall_configuration() {
  FIREWALL_CONFIG=$(uci show firewall)  # Извличане на firewall конфигурацията с uci
  whiptail --scrolltext --title "Firewall Configuration" --msgbox "$FIREWALL_CONFIG" 20 60
}

# Функция за конфигурация на мрежата
configure_network() {
  INTERFACE=$(whiptail --inputbox "Enter the network interface to configure (e.g., eth0, br-lan)" 8 60 3>&1 1>&2 2>&3)
  IP=$(whiptail --inputbox "Enter the IP address for $INTERFACE (e.g., 192.168.1.1)" 8 60 3>&1 1>&2 2>&3)
  NETMASK=$(whiptail --inputbox "Enter the subnet mask (e.g., 255.255.255.0)" 8 60 3>&1 1>&2 2>&3)
  GATEWAY=$(whiptail --inputbox "Enter the gateway IP (e.g., 192.168.1.1)" 8 60 3>&1 1>&2 2>&3)

  # Записваме промените в конфигурацията
  uci set network.$INTERFACE.ipaddr=$IP
  uci set network.$INTERFACE.netmask=$NETMASK
  uci set network.$INTERFACE.gateway=$GATEWAY
  uci commit network
  /etc/init.d/network restart

  whiptail --msgbox "Network configuration updated!" 8 45
}

# Функция за конфигурация на Wi-Fi
configure_wifi() {
  SSID=$(whiptail --inputbox "Enter SSID for the Wi-Fi network" 8 60 3>&1 1>&2 2>&3)
  PASSPHRASE=$(whiptail --passwordbox "Enter WPA passphrase for the Wi-Fi network" 8 60 3>&1 1>&2 2>&3)

  # Записваме промените в конфигурацията
  uci set wireless.@wifi-iface[0].ssid=$SSID
  uci set wireless.@wifi-iface[0].encryption='psk2'
  uci set wireless.@wifi-iface[0].key=$PASSPHRASE
  uci commit wireless
  /etc/init.d/network restart

  whiptail --msgbox "Wi-Fi configuration updated!" 8 45
}

# Функция за конфигурация на firewall
configure_firewall() {
  PORT=$(whiptail --inputbox "Enter the port to allow or block (e.g., 80)" 8 60 3>&1 1>&2 2>&3)
  ACTION=$(whiptail --menu "Choose action for port $PORT" 15 60 4 \
  "1" "Allow" \
  "2" "Block" 3>&1 1>&2 2>&3)

  if [ "$ACTION" -eq 1 ]; then
    uci add firewall rule
    uci set firewall.@rule[-1].target='ACCEPT'
    uci set firewall.@rule[-1].src='wan'
    uci set firewall.@rule[-1].proto='tcp'
    uci set firewall.@rule[-1].dest_port=$PORT
  else
    uci add firewall rule
    uci set firewall.@rule[-1].target='REJECT'
    uci set firewall.@rule[-1].src='wan'
    uci set firewall.@rule[-1].proto='tcp'
    uci set firewall.@rule[-1].dest_port=$PORT
  fi
  uci commit firewall
  /etc/init.d/firewall restart

  whiptail --msgbox "Firewall rule for port $PORT updated!" 8 45
}

# Функция за запис и изход
save_and_exit() {
  whiptail --msgbox "Configuration saved and applied!" 8 45
  exit 0
}

# Основно меню
while true; do
  CHOICE=$(whiptail --title "OpenWrt Configuration" --menu "Choose an option" 20 60 10 \
  "1" "Configure Network" \
  "2" "Configure Wi-Fi" \
  "3" "Configure Firewall" \
  "4" "Show LAN Configuration" \
  "5" "Show Wi-Fi Configuration" \
  "6" "Show Firewall Configuration" \
  "7" "Save and Exit" \
  "8" "Exit without Saving" 3>&1 1>&2 2>&3)

  case $CHOICE in
    1) configure_network ;;
    2) configure_wifi ;;
    3) configure_firewall ;;
    4) show_lan_configuration ;;
    5) show_wifi_configuration ;;
    6) show_firewall_configuration ;;
    7) save_and_exit ;;
    8) exit 0 ;;
    *) whiptail --msgbox "Invalid option!" 8 45 ;;
  esac
done
