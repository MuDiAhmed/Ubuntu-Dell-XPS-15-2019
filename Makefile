ACPI_DIR=/etc/acpi/
ACPI_EVENTS_DIR=$(ACPI_DIR)events
BRIGHTNESS_UP_FILE=./dell-oled-brightness-up
BRIGHTNESS_DOWN_FILE=./dell-oled-brightness-down
BRIGHTNESS_SCRIPT_FILE=./dell-oled-brightness.sh
POWER_TOP_SERVICE_FILE=./powertop.service
SYS_SERVICE_DIR=/etc/systemd/system/

all: 	 power_management_install oled_install suspend_install wifi_install
	
uninstall: power_management_uninstall oled_uninstall suspend_uninstall wifi_uninstall 
	
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

power_management_install:
	apt install -y powertop thermald
	cp $(POWER_TOP_SERVICE_FILE) $(SYS_SERVICE_DIR)$(POWER_TOP_SERVICE_FILE)
	systemctl daemon-reload
	systemctl enable powertop.service
	systemctl start powertop.service

power_management_uninstall:
	systemctl disable powertop.service
	systemctl daemon-reload
	rm -f $(SYS_SERVICE_DIR)$(POWER_TOP_SERVICE_FILE)
	apt-get remove -y powertop thermald
