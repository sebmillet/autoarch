default:
	@echo "Run 'make install' to configure i3"

install:
	cp $(cpopt) -v --preserve=all config ~/.config/i3/
	sudo cp $(cpopt) --preserve=all -v i3-autostart i3-invmousebuttons /usr/local/bin/
	sudo cp $(cpopt) --preserve=all -v expressvpn-v2.py /usr/share/bumblebee-status/bumblebee_status/modules/contrib/
	sudo cp $(cpopt) --preserve=all -v keyboard-language-v2.py /usr/share/bumblebee-status/bumblebee_status/modules/contrib/
	sudo cp $(cpopt) --preserve=all -v 30-touchpad.conf /etc/X11/xorg.conf.d/
	sudo cp $(cpopt) --preserve=all -v 00-keyboard.conf /etc/X11/xorg.conf.d/

