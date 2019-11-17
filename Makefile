# Copyright 2017 - 2019, Udi Fuchs
# SPDX-License-Identifier: MIT

ACPI_DIR=/etc/acpi/
ACPI_EVENTS_DIR=$(ACPI_DIR)events
BRIGHTNESS_UP_FILE=./dell-oled-brightness-up
BRIGHTNESS_DOWN_FILE=./dell-oled-brightness-down
BRIGHTNESS_SCRIPT_FILE=./dell-oled-brightness.sh

all: 	wifi_install oled_install suspend_install
	
uninstall: wifi_uninstall oled_uninstall suspend_uninstall 
	
oled_install: 
	install -m 644 $(BRIGHTNESS_UP_FILE) $(ACPI_EVENTS_DIR)
	install -m 644 $(BRIGHTNESS_DOWN_FILE) $(ACPI_EVENTS_DIR)
	install -m 755 $(BRIGHTNESS_SCRIPT_FILE) $(ACPI_DIR)
	acpid reload

oled_uninstall: 
	rm -f $(ACPI_DIR)$(BRIGHTNESS_SCRIPT_FILE)
	rm -f $(ACPI_EVENTS_DIR)$(BRIGHTNESS_UP_FILE)
	rm -f $(ACPI_EVENTS_DIR)$(BRIGHTNESS_DOWN_FILE)
	acpid reload

suspend_install:
	echo deep| tee /sys/power/mem_sleep
	sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mem_sleep_default=deep/' /etc/default/grub
	update-grub
suspend_uninstall:
	echo s2idle| tee /sys/power/mem_sleep
	sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)\( mem_sleep_default=deep\)\(.*[^"]\)*/\1\3/' /etc/default/grub 
	update-grub

wifi_install:
	add-apt-repository ppa:canonical-hwe-team/backport-iwlwifi
	apt-get update
	apt-get install backport-iwlwifi-dkms
	reboot

wifi_uninstall:
	apt-get remove backport-iwlwifi-dkms
	add-apt-repository -r ppa:canonical-hwe-team/backport-iwlwifi
	apt-get update
	reboot
