# Wifi Notes

## My Lenovo X1 Carbon

Intel Corporation Wireless 7265 (rev 59)

## Debugging

    dmesg -T | grep wl

## Identification

    lspci

## Potential Fix

    sudo iw reg set US

Other fix: https://www.reddit.com/r/thinkpad/comments/34ln2h/t450s_ubuntu_1504_unstable_wifi/

## NMCLI

Listing available Wi-Fi APs

    nmcli device wifi list

## Restarting the network manager if wifi fails after hibernate

    sudo systemctl restart network-manager
