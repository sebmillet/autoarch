default:
	@echo "Run 'make NN' to install/configure element 'NN'"

aa:
	./aa.sh

cfg-seb: 00

00:
	tar -zxvf cfg-00-seb.tar.gz && \
		cd cfg-seb && \
		$(MAKE) install

yaourt: 01

01:
	./cfg-01-yaourt.sh

kernconf: 02 03 04

02:
	tar -zxvf cfg-02-uefikeys.tar.gz
	cd uefikeys && sudo $(MAKE) install

03:
	tar -zxvf cfg-03-kernsign.tar.gz
	cd kernsign && sudo $(MAKE) install

04:
	sudo ./cfg-04-freezpkg.sh

gnome: 05 06

05:
	sudo ./cfg-05-gnome-inst.sh

06:
	./cfg-06-gnome-conf.sh

i3: 07 08

07:
	sudo pacman --noconfirm -S i3-wm hsetroot i3lock xautolock numlockx otf-font-awesome dmenu
	yaourt -a alttab-git
	yaourt -a bumblebee-status
	gpg --recv-key 9B8450B91D1362C1
	yaourt -a j4-dmenu-desktop

i3-conf: 08

08:
	tar -zxvf cfg-08-i3-conf.tar.gz
	cd i3-conf && $(MAKE) install

gui-apps: 09

09:
	sudo pacman -S thunderbird thunderbird-i18n-fr
	sudo pacman -S firefox firefox-i18n-fr
	sudo pacman -S alacritty

clean:
	rm -rf cfg-seb
	if [ -d uefikeys ]; then \
		chmod +w uefikeys; \
		chmod +w uefikeys/*; \
	fi
	rm -rf uefikeys
	rm -rf kernsign
	rm -rf i3-conf

