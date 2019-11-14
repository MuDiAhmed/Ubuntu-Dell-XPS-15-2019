# Ubuntu-Dell-XPS-15-2019
How to install Ubuntu on a Dell XPS 15 OLED 7590 model from 2019?

This page will explain how to fix a number of issues with the **Ubuntu 18.04**.
  
`Note (Not tested yet): the power management for the latest CPU generation works only on **Ubuntu 19.04** leading to very high power consumption and a CPU permanently at the thermal limit on older Ubuntu versions.`
  
Problems addressed are:

- CPU power management
- Changing brightness of OLED screen with brightness keys

## Installation (assuming only Ubuntu not dual boot)

1. Download `Ubuntu 18.04` from [Ubuntu Website](https://ubuntu.com/download/desktop/thank-you?country=AE&version=18.04.3&architecture=amd64)
2. Create Bootable usb stick using `Rufus` on Windows or `Startup Disk Creator` on Ubuntu 
3. Change `SATA Operation` inside `BIOS(UEFI)` from `RAID on` to `AHCI`, this is done by: `Power up` your machine then click `f12`, choice `BOIS Configurations`.  
4. Restart your machine then click `f12` again, then choice to boot from the usb stick.
5. Follow Ubuntu installation window.

##### Note 1:
`It is recommended to also install 3rd party software for which one needs to connect the laptop to the internet.`  
##### Note 2:
`The internal wifi card does not work during the installation process. Just use your phone tethering for now. after successful installation go to` [Killer Wifi Website](https://support.killernetworking.com/knowledge-base/killer-ax1650-in-debian-ubuntu-16-04/) `and install there wifi driver`
##### Note 3: 
`After installation, in case of you didn't disable secure boot, the first restart you will see a blue window for` **MOK Management** `just choice` **enroll**

6. After the installation is complete, run
```
sudo apt update
sudo apt dist-upgrade -y
```
to update the system to the latest versions.

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

This is undesirable. Not only will the screen often be too bright, it will also age the display faster. It is possible to change the brightness of the screen from the command line via
```
xrandr --output $(xrandr --listmonitors | awk '$1 == "0:" {print $4}') --brightness 0.6
```
#### Careful:
`0 is black and black on OLED displays is really all black.`


## Mapping function keys to change brightness:
The function keys can be mapped to use this command to change the brightness. ([Idea Taking from Lenovo Thinkpad](https://askubuntu.com/questions/824949/lenovo-thinkpad-x1-yoga-oled-brightness)), then the script is tweaked a little bit.

1. Download the repo
2. Open a terminal window that point to the downloaded repo directory
3. Run `sudo make install` 

#### Commands available: 
- `sudo make install`
- `sudo make uninstall`
#### Note: 
`That OLED displays only consume energy and age when the individual pixels are emitting light. Hence, it is advisable to choose dark background colors and install a dark scheme in your browser.`
