# Ubuntu-Dell-XPS-15-2019
How to install Ubuntu on a Dell XPS 15 OLED 7590 model from 2019?

This page will explain how to fix a number of issues with the **Ubuntu 18.04**.
  
`Note (Not tested yet): the power management for the latest CPU generation works only on **Ubuntu 19.04** leading to very high power consumption and a CPU permanently at the thermal limit on older Ubuntu versions.`
  
Problems addressed are:

- Killer Wifi driver
- CPU power management
- Changing brightness of OLED screen with brightness keys
- Suspend Draining battery fast

## Installing Ubuntu (assuming only Ubuntu not dual boot)

1. Download `Ubuntu 18.04` from [Ubuntu Website](https://ubuntu.com/download/desktop/thank-you?country=AE&version=18.04.3&architecture=amd64)
2. Create Bootable usb stick using `Rufus` on Windows or `Startup Disk Creator` on Ubuntu 
3. Change `SATA Operation` inside `BIOS(UEFI)` from `RAID on` to `AHCI`, this is done by: `Power up` your machine then click `f12`, choice `BOIS Configurations`.  
4. Restart your machine then click `f12` again, then choice to boot from the usb stick.
5. Follow Ubuntu installation window.

##### Note 1:
`It is recommended to also install 3rd party software for which your laptop needs to be connected to the internet. Wifi will not be available, Just use your phone tethering for now. will fix this issue later`  

##### Note 2: 
`After installation, in case of you didn't disable secure boot, the first restart you will see a blue window for` **MOK Management** `just choice` **enroll**

6. After the installation is complete, run
```
sudo apt update
sudo apt dist-upgrade -y
```
to update the system to the latest versions.




## Killer Wifi driver
You can't live with out wifi. but the diver repo is missing so we are going to fix this now.


#### Automatic fix:
Just run this commands and the issue will be fixed for you.  
**Note:** laptop will reboot at the end. so save your important work
1. Open a terminal
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make wifi_install`


#### Behind the scene:
we are going to add the right repo, so we are able to install the wifi driver. this is based on [Killer Wifi Website](https://support.killernetworking.com/knowledge-base/killer-ax1650-in-debian-ubuntu-16-04/). again just use your phone tethering for now until we install the driver.
1. Open a terminal
2. Run `sudo add-apt-repository ppa:canonical-hwe-team/backport-iwlwifi`
3. Run `sudo apt-get update`
4. Run `sudo apt-get install backport-iwlwifi-dkms`
5. Run `reboot`


#### Commands available: 
- `sudo make wifi_install`
- `sudo make wifi_uninstall`




## CPU power management
Without further configuration the CPU will run quite hot and will quickly drain the battery. Install `powertop` and `thermald` to fix this.
```
sudo apt install -y powertop thermald
```
You can start powertop with `sudo powertop`, navigate to the _Tunables_ section and switch all _Bad_ points to _Good_. Probably not all of them have a big effect, I have not tried, but the processor related points are absolutely required. However, these changes are not permanent and will be reset at reboot. Instead let us create a service that will change these settings at boot time.

The script and setup are taken from [here](https://blog.sleeplessbeastie.eu/2015/08/10/how-to-set-all-tunable-powertop-options-at-system-boot/).

First, create a service with
```
cat << EOF | sudo tee /etc/systemd/system/powertop.service
[Unit]
Description=PowerTOP auto tune

[Service]
Type=idle
Environment="TERM=dumb"
ExecStart=/usr/sbin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF
```
and then enable this service to run at boot time with
```
sudo systemctl daemon-reload
sudo systemctl enable powertop.service
```


## Screen Brightness (OLED)
When pressing the function keys to change the screen brightness, you will see the Ubuntu brightness icon and its brightness bar changing. However, the brightness of the screen will not change. Apparently, Ubuntu tries to change the background brightness of the screen. Since OLED screens do not have a background illumination, nothing happens.
This is undesirable. Not only will the screen often be too bright, it will also age the display faster.  

**Note:** That OLED displays only consume energy and age when the individual pixels are emitting light. Hence, it is advisable to choose dark background colors and install a dark scheme in your browser.


#### Automatic Fix:
1. Open a terminal
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make oled_install` 


#### One time fix
It is possible to change the brightness of the screen from the command line via.
```
xrandr --output $(xrandr --listmonitors | awk '$1 == "0:" {print $4}') --brightness 0.6
```
But you will need to change it from the command line every time.  
**Note:** brightness range is between 0 and 1.  
**Careful:** `0 is black and black on OLED displays is really all black.`


#### Behind the scene:
The function keys can be used to change brightness. ([Idea Taking from Lenovo Thinkpad](https://askubuntu.com/questions/824949/lenovo-thinkpad-x1-yoga-oled-brightness)), then the script is tweaked a little bit.

1. We are going to create 2 listeners for function keys brightness up and down.  
    1. Open a terminal window
    2. Create a file (brightness up listiner) called `dell-oled-brightness-up` inside `/etc/acpi/events/` via.  
     `sudo vi /etc/acpi/events/dell-oled-brightness-up`
    3. Add bellow content to it.  
    ```
    event=video/brightnessup BRTUP 00000086 00000000
    action=/etc/acpi/dell-oled-brightness.sh up
    ```   
    4. Create a file (brightness down listiner) called `dell-oled-brightness-down` inside `/etc/acpi/events/` via.  
     `sudo vi /etc/acpi/events/dell-oled-brightness-down`
    5. Add bellow content to it.  
    ```
    event=video/brightnessdown BRTDN 00000087 00000000
    action=/etc/acpi/dell-oled-brightness.sh down
    ```

2. We are going to create an event handler.
    1. Open a terminal window
    2. Create a file called `dell-oled-brightness.sh` inside `/etc/acpi/` via.
      `sudo vi /etc/acpi/dell-oled-brightness.sh`
    3. Add bellow content to it.  
    ```
    #!/bin/bash
    export XAUTHORITY=/run/user/1000/gdm/Xauthority
    export DISPLAY=:0.0
    DISPLAYNAME=`xrandr --listmonitors | awk '$1 == "0:" {print $4}'`
    MIN=0.0625
    MAX=1
    #convert range from 0.0:1.0 to 0:16
    INCREASE_DECREASE_VALUE=$MIN 
    #get brightness bar level, range from 0 to 15
    CURRENT_INTEL_BRIGHTNESS=`/usr/lib/gnome-settings-daemon/gsd-backlight-helper --get-    brightness`
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

    ```


#### Commands available: 
- `sudo make oled_install`
- `sudo make oled_uninstall`



## Suspend Draining battery fast
By default, the very inefficient `s2idle` suspend variant is incorrectly selected. This is probably due to the BIOS. The much more efficient `deep` variant should be selected instead.


#### Automatic Fix:
1. Open a terminal window
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make suspend_install` 


#### One time fix
It is possible to change the suspend mode from the command line via.
```
echo deep| tee /sys/power/mem_sleep
```

#### Behind the scene:
1. Open a terminal window
2. Run `sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mem_sleep_default=deep/' /etc/default/grub`
3. Run `update-grub`


#### Commands available: 
- `sudo make suspend_install`
- `sudo make suspend_uninstall`


