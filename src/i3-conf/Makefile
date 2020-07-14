default:
	@echo "Run 'make install' to configure i3"

install:
	cp -iv --preserve=all config ~/.config/i3/
	sudo cp --preserve=all -iv i3-autostart i3-invmousebuttons /usr/local/bin/
	sudo cp --preserve=all -iv expressvpn-v2.py /usr/share/bumblebee-status/bumblebee_status/modules/contrib/
	sudo cp --preserve=all -iv keyboard-language-v2.py /usr/share/bumblebee-status/bumblebee_status/modules/contrib/
	sudo cp --preserve=all -iv 30-touchpad.conf /etc/X11/xorg.conf.d/
	sudo cp --preserve=all -iv 00-keyboard.conf /etc/X11/xorg.conf.d/

