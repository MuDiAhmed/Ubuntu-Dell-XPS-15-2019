# Copyright 2017 - 2019, Udi Fuchs
# SPDX-License-Identifier: MIT

ACPI_DIR=/etc/acpi/
ACPI_EVENTS_DIR=$(ACPI_DIR)events
BRIGHTNESS_UP_FILE=./dell-oled-brightness-up
BRIGHTNESS_DOWN_FILE=./dell-oled-brightness-down
BRIGHTNESS_SCRIPT_FILE=./dell-oled-brightness.sh

install: 
	install -m 644 $(BRIGHTNESS_UP_FILE) $(ACPI_EVENTS_DIR)
	install -m 644 $(BRIGHTNESS_DOWN_FILE) $(ACPI_EVENTS_DIR)
	install -m 755 $(BRIGHTNESS_SCRIPT_FILE) $(ACPI_DIR)
	acpid reload

uninstall: 
	rm -f $(ACPI_DIR)$(BRIGHTNESS_SCRIPT_FILE)
	rm -f $(ACPI_EVENTS_DIR)$(BRIGHTNESS_UP_FILE)
	rm -f $(ACPI_EVENTS_DIR)$(BRIGHTNESS_DOWN_FILE)
	acpid reload
