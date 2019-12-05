# Ubuntu on Dell XPS 15 7590 OLED 2019
How to install Ubuntu on a Dell XPS 15 OLED 7590 model from 2019?

This page will explain how to fix a number of issues with **Ubuntu 18.04** and **Ubuntu 19.10**.
  
**Note:** the power management for the latest CPU generation works better on **Ubuntu 19.10**, leading to very high power consumption and a CPU permanently at the thermal limit on older Ubuntu versions, but can be controlled with **CPU Power Management** solution below.
  
Problems addressed are:

- Killer Wifi driver
- CPU power management
- Changing brightness of OLED screen with brightness keys
- Suspend Draining battery fast

## Installing Ubuntu (assuming only Ubuntu not dual boot)

1. Download [Ubuntu 18.04](https://ubuntu.com/download/desktop/thank-you?country=AE&version=18.04.3&architecture=amd64) or [Ubuntu 19.10](https://ubuntu.com/download/desktop/thank-you?country=AE&version=19.10&architecture=amd64).
2. Create Bootable usb stick using `Rufus` on Windows or `Startup Disk Creator` on Ubuntu 
3. Change `SATA Mode` inside `BIOS(UEFI)` from `RAID on` to `AHCI`, this is done by: `Power up` your machine then click `f12`, choice `BOIS Configurations`.  
4. Restart your machine then click `f12` again, then choice to boot from the usb stick.
5. Follow Ubuntu installation window.

	**Note 1:** It is recommended to also install 3rd party software for which your laptop needs to be connected to the internet. Wifi will not be available, Just use your phone tethering for now. will fix this issue later.

	**Note 2:** After installation, in case of you didn't disable [secure boot](https://wiki.ubuntu.com/UEFI/SecureBoot), the first restart you will see a blue window for `MOK Management` just choice `enroll`

6. After the installation is complete, run
	```
	sudo apt update
	sudo apt dist-upgrade -y
	```
	to update the system to the latest versions.

## Fixing all issues:
**Note:** laptop will reboot at the end. so save your important work
1. Open a terminal
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make`

#### Commands Available:
- `sudo make` + one of the below
	1. all (default). **Note:** laptop will reboot at the end. so save your important work
	2. uninstall **Note:** laptop will reboot at the end. so save your important work
	3. oled_xrandr_install
	4. oled_xrandr_uninstall
	5. oled_icc_install **Note:** require manual reboot or login again
	6. oled_icc_uninstall
	7. wifi_install **Note:** laptop will reboot at the end. so save your important work
	8. wifi_uninstall **Note:** laptop will reboot at the end. so save your important work
	9. power_management_install
	10. power_management_uninstall
	11. suspend_install
	12. suspend_uninstall   


## Killer Wifi driver
You can't live with out wifi. but the diver repo is missing so we are going to fix this now.  
**Note:** When useing option `install third party` on the installation process this solution won't be neccessery. but if you still don't have wifi then continue


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
Without further configuration the CPU will run quite hot and will quickly drain the battery. 
We are going to Install:
1.  [powertop](https://01.org/powertop/overview)
2.  [thermald](https://01.org/linux-thermal-daemon)
3. [TLP](https://linrunner.de/en/tlp/docs/tlp-linux-advanced-power-management.html#installation)

#### Automatic Fix:
1. Open a terminal
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make power_management_install`

 
 #### Behind the scene:
 1. Open a terminal
 2. Run `sudo apt install -y powertop thermald tlp`
 3. Run `sudo powertop` 
 4. Click `Shift+TAB` to navigate to Tunables
 5. Click `Enter` on the `Bad` to change to `Good`
 
	Probably not all of them have a big effect, I have not tried, but the processor related points are absolutely required. However, these changes are not permanent and will be reset at reboot. Instead let us create a service that will change these settings at boot time.
The script and setup are taken from [here](https://blog.sleeplessbeastie.eu/2015/08/10/how-to-set-all-tunable-powertop-options-at-system-boot/).

6. Run below command to create a service file called `powertop.service` at `/etc/systemd/system/`
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
7. Run below command to enable the service at boot time
	```
	sudo systemctl daemon-reload
	sudo systemctl enable powertop.service
	```
8. Run `sudo tlp start`

#### Commands available: 
- `sudo make power_management_install`
- `sudo make power_management_uninstall`


## Screen Brightness (OLED)
When pressing the function keys to change the screen brightness, you will see the Ubuntu brightness icon and its brightness bar changing. However, the brightness of the screen will not change. Apparently, Ubuntu tries to change the background brightness of the screen. Since OLED screens do not have a background illumination, nothing happens.
This is undesirable. Not only will the screen often be too bright, it will also age the display faster.  

**Note:** That OLED displays only consume energy and age when the individual pixels are emitting light. Hence, it is advisable to choose dark background colors and install a dark scheme in your browser.

### 1. FIX USING XRANDR:

#### Automatic Fix:
1. Open a terminal
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make oled_xrandr_install` 


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
    2. Run below command to create a file (brightness up listener) called `dell-oled-brightness-up` inside `/etc/acpi/events/` 
		  ```
	    cat << EOF | sudo tee /etc/acpi/events/dell-oled-brightness-up
	    event=video/brightnessup BRTUP 00000086 00000000
	    action=/etc/acpi/dell-oled-brightness.sh up
	    EOF
		```   
    3. Run below command to create a file  (brightness down listener) called `dell-oled-brightness-down` inside `/etc/acpi/events/`. 
	    ```
	    cat << EOF | sudo tee /etc/acpi/events/dell-oled-brightness-down
	    event=video/brightnessdown BRTDN 00000087 00000000
	    action=/etc/acpi/dell-oled-brightness.sh down
	    EOF
	    ```

2. We are going to create an event handler.
    1. Open a terminal window
    2. Run below command to create a file called `dell-oled-brightness.sh` inside `/etc/acpi/`.
	    ```
	    cat << EOF | sudo tee /etc/acpi/dell-oled-brightness.sh
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

	    EOF
	    ```
	  3. Give the file `excute` permission via.
	`sudo chmod u+x /etc/acpi/dell-oled-brightness.sh`


#### Commands available: 
- `sudo make oled_xrandr_install`
- `sudo make oled_xrandr_uninstall`


### 2. FIX USING ICC color profiles:
script is taking from a different [project](https://github.com/udifuchs/icc-brightness) just merged his code to this project to make it easy to use either ways

#### Automatic Fix:
1. Open a terminal
2. Run `cd /path/to/repo/dir/`
3. Run `sudo make oled_icc_install`
4. Reboot your machine or Login again  

#### Commands available: 
- `sudo make oled_icc_install`
- `sudo make oled_icc_uninstall`

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



## Useful Packages:
1. [system-monitor](https://extensions.gnome.org/extension/120/system-monitor/) (gnome extention)
2. [CPU Power Manager](https://extensions.gnome.org/extension/945/cpu-power-manager/) (gnome extention)

