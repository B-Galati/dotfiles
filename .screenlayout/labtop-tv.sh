#!/bin/bash

# Generate with command "cvt 1280 720 60"
# 1280x720 59.86 Hz (CVT 0.92M9) hsync: 44.77 kHz; pclk: 74.50 MHz
# source : http://askubuntu.com/questions/377937/how-to-set-a-custom-resolution

if [[ ! $(xrandr | grep -i "1280x720_60.00") ]]; then
    xrandr --newmode "1280x720_60.00"   74.50  1280 1344 1472 1664  720 723 728 748 -hsync +vsync
    xrandr --addmode HDMI1 1280x720_60.00
fi

xrandr --output LVDS1 --primary --mode 1366x768 --pos 0x0 --rotate normal \
       --output HDMI1 --mode 1280x720_60.00 --pos 1366x0 --rotate normal \
       --output DP1 --off \
       --output VGA1 --off
