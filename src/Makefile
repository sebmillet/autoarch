# Makefile
# Copyright 2020 Sébastien Millet, milletseb@laposte.net

default:
	@echo "Run 'make NN' to install/configure element 'NN'"

aa:
	./aa.sh

cfg-seb: 10

10:
	tar -zxvf cfg-10-seb-PRIVATE.tar.gz && \
		cd cfg-seb-PRIVATE && \
		$(MAKE) install

pkg-extra: 20

20:
	sudo pacman -S openssh inetutils git sbsigntools base-devel
	sudo pacman -S fzf tree pydf htop nethogs lsd

yaourt: 30

30:
	./cfg-30-yaourt.sh

kernconf: 40 41 50

40:
	tar -zxvf cfg-40-uefikeys.tar.gz
	cd uefikeys && sudo $(MAKE) install

41:
	tar -zxvf cfg-41-kernsign.tar.gz
	cd kernsign && sudo $(MAKE) install

50:
	sudo ./cfg-50-freezpkg.sh

csdcard: 45

45:
	tar -zxvf cfg-45-csdcard.tar.gz
	cd csdcard && sudo $(MAKE) install

gnome: 60 61

60:
	sudo pacman -S mesa xf86-video-intel xorg-server xorg-apps
	@echo "Selection recommendations:"
	@echo "  libjack.so provider, select 2 (jack2)"
	@echo "  xdg-desktop-portal-impl, select 1 (xdg-desktop-portal-gtk)"
	@echo "  ttf-font, select 5 (ttf-dejavu)"
	@echo "Press [Enter] key to continue"
	@read -r resp
	sudo pacman -S gnome gnome-extra

61:
	./cfg-61-gnome-conf.sh

i3: 70 71

70:
	sudo pacman -S i3-wm hsetroot i3lock xautolock numlockx otf-font-awesome dmenu
#     altab-git installation with yaourt produces an error. The commit is:
#         45816dc7777b63284bd82c49683e7dd6d9955571
#         of 2020-04-21
#     This comment was written 2020-07-11
#     yaourt -a alttab-git
	yaourt -a bumblebee-status
	gpg --recv-key 9B8450B91D1362C1
	yaourt -a j4-dmenu-desktop

i3-conf: 71

71:
	tar -zxvf cfg-71-i3-conf.tar.gz
	cd i3-conf && $(MAKE) install

pkg-gui: 80

80:
	sudo pacman -S alacritty
	sudo pacman -S gvim
	sudo pacman -S thunderbird thunderbird-i18n-fr
	sudo pacman -S firefox firefox-i18n-fr

clean:
	rm -rf cfg-seb
	if [ -d uefikeys ]; then \
		chmod +w uefikeys; \
		chmod +w uefikeys/*; \
	fi
	rm -rf uefikeys
	rm -rf csdcard
	rm -rf kernsign
	rm -rf i3-conf

# vim: ts=4:sw=4:tw=80:
