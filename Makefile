ACPI_DIR=/etc/acpi/
ACPI_EVENTS_DIR=$(ACPI_DIR)events
XRANDR_BRIGHTNESS_UP_FILE=dell-oled-brightness-up
XRANDR_BRIGHTNESS_DOWN_FILE=dell-oled-brightness-down
XRANDR_BRIGHTNESS_SCRIPT_FILE=dell-oled-brightness.sh
POWER_TOP_SERVICE_FILE=powertop.service
SYS_SERVICE_DIR=/etc/systemd/system/
BIN_PATH=/usr/local/bin/
AUTO_START_PATH=/usr/share/gnome/autostart/
ICC_BRIGHTNESS_GEN=icc-brightness-gen
ICC_BRIGHTNESS=icc-brightness
ICC_BRIGHTNESS_DESKTOP=icc-brightness.desktop

all: 	 power_management_install oled_xrandr_install suspend_install wifi_install
	
uninstall: power_management_uninstall oled_xrandr_uninstall suspend_uninstall wifi_uninstall 
	
oled_xrandr_install: 
	install -m 644 $(XRANDR_BRIGHTNESS_UP_FILE) $(ACPI_EVENTS_DIR)
	install -m 644 $(XRANDR_BRIGHTNESS_DOWN_FILE) $(ACPI_EVENTS_DIR)
	install -m 755 $(XRANDR_BRIGHTNESS_SCRIPT_FILE) $(ACPI_DIR)
	acpid reload

oled_xrandr_uninstall: 
	rm -f $(ACPI_DIR)$(XRANDR_BRIGHTNESS_SCRIPT_FILE)
	rm -f $(ACPI_EVENTS_DIR)$(XRANDR_BRIGHTNESS_UP_FILE)
	rm -f $(ACPI_EVENTS_DIR)$(XRANDR_BRIGHTNESS_DOWN_FILE)
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
	apt-get install -y powertop thermald
	cp $(POWER_TOP_SERVICE_FILE) $(SYS_SERVICE_DIR)$(POWER_TOP_SERVICE_FILE)
	systemctl daemon-reload
	systemctl enable powertop.service
	systemctl start powertop.service

power_management_uninstall:
	systemctl disable powertop.service
	systemctl daemon-reload
	rm -f $(SYS_SERVICE_DIR)$(POWER_TOP_SERVICE_FILE)
	apt-get remove -y powertop thermald

oled_icc_install: icc-brightness-gen
	apt-get install -y liblcms2-dev
	mkdir -p $(DESTDIR)$(BIN_PATH)
	install -m 755 $(ICC_BRIGHTNESS_GEN) $(DESTDIR)$(BIN_PATH)
	install -m 755 $(ICC_BRIGHTNESS) $(DESTDIR)$(BIN_PATH)
	mkdir -p $(DESTDIR)$(AUTO_START_PATH)
	install -m 644 $(ICC_BRIGHTNESS_DESKTOP) $(DESTDIR)$(AUTO_START_PATH)

oled_icc_uninstall: 
	rm -f $(DESTDIR)$(BIN_PATH)$(ICC_BRIGHTNESS_GEN)
	rm -f $(DESTDIR)$(BIN_PATH)$(ICC_BRIGHTNESS)
	rm -f $(DESTDIR)$(AUTO_START_PATH)$(ICC_BRIGHTNESS_DESKTOP)
	rm -f $(ICC_BRIGHTNESS_GEN)

icc-brightness-gen: icc-brightness-gen.c
	$(CC) -W -Wall $(CFLAGS) $^ -l lcms2 $(LDFLAGS) -o $@

