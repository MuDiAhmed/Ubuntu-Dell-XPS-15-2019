#!/bin/bash
export XAUTHORITY=/run/user/1000/gdm/Xauthority
export DISPLAY=:0.0
DISPLAYNAME=`xrandr --listmonitors | awk '$1 == "0:" {print $4}'`
MIN=0.0625
MAX=1
#convert range from 0.0:1.0 to 0:16
INCREASE_DECREASE_VALUE=$MIN 
#get brightness bar level, range from 0 to 15
CURRENT_INTEL_BRIGHTNESS=`/usr/lib/gnome-settings-daemon/gsd-backlight-helper --get-brightness`
CURR=`LC_ALL=C /usr/bin/printf "%.*f" 1 $CURRENT_INTEL_BRIGHTNESS`

if [ "$1" == "up" ]; then
        CURR=$CURR+1
else
        CURR=$CURR-1
fi
 
VAL=`echo "scale=3; ($CURR+1)*$INCREASE_DECREASE_VALUE" | bc`
 
if (( `echo "$VAL < $MIN" | bc -l` )); then
    VAL=$MIN
elif (( `echo "$VAL > $MAX" | bc -l` )); then
    VAL=$MAX
fi
 
#set oled brightness to the caluclated value
`xrandr --output $DISPLAYNAME --brightness $VAL` 2>&1 >/dev/null | logger -t oled-brightness
 
# Set Intel backlight to fake value
# to sync OSD brightness indicator to actual brightness
INTEL_PANEL="/sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/"
if [ -d "$INTEL_PANEL" ]; then
     PERCENT=`echo "scale=4; $VAL/$MAX" | bc -l`
     INTEL_MAX=$(cat "$INTEL_PANEL/max_brightness")
     INTEL_BRIGHTNESS=`echo "scale=4; $PERCENT*$INTEL_MAX" | bc -l`
     INTEL_BRIGHTNESS=`LC_ALL=C /usr/bin/printf "%.*f" 0 $INTEL_BRIGHTNESS`
     echo $INTEL_BRIGHTNESS > "$INTEL_PANEL/brightness"
fi

