#!/bin/bash
DISPLAYNAME=`xrandr --listmonitors | awk '$1 == "0:" {print $4}'`
MIN=0
MAX=1
CURRENT_OLED_BRIGHTNESS=`xrandr --verbose | grep -m 1 -i brightness | cut -f2 -d ' '`
CURRENT_INTEL_BRIGHTNESS=`cat /sys/class/backlight/intel_backlight/actual_brightness`
MAX_INTEL_BRIGHTNESS=`cat /sys/class/backlight/intel_backlight/max_brightness`
CURR_INTEL=`LC_ALL=C /usr/bin/printf "%.*f" 1 $CURRENT_INTEL_BRIGHTNESS`
MAX_INTEL=`LC_ALL=C /usr/bin/printf "%.*f" 1 $MAX_INTEL_BRIGHTNESS`	

VAL=`echo "scale=2; $CURR_INTEL/$MAX_INTEL" | bc`

if (( `echo "$VAL < $MIN" | bc -l` )); then
    VAL=$MIN
elif (( `echo "$VAL > $MAX" | bc -l` )); then
    VAL=$MAX
fi
 

#set oled brightness to the caluclated value
`xrandr --output $DISPLAYNAME --brightness $VAL` 2>&1 >/dev/null | logger -t oled-brightness
logger -t OLED_XRANDR_BRIGHTNESS "CURRENT BRIGHTNESS: $VAL" 

