# Makefile
# Copyright 2020 Sébastien Millet, milletseb@laposte.net

has_private_content=yes
qualifier=PRIVATE
ifeq ($(wildcard .private),)
	has_private_content=no
	qualifier=PUBLIC
endif

ifeq ($(noconfirm), 1)
	optnoconfirm=--noconfirm
endif

cli=10 15 20 30
ifeq ($(has_private_content), yes)
	cli+=40 41 45
endif
cli+=50 55 56 57 58

all: cli gui

gui=60 61 70 71 80

aa:
	./aa.sh

cli: $(cli)

gui: $(gui)

cfg-seb: 10

10:
	tar -zxvf cfg-10-seb-$(qualifier).tar.gz && \
		cd cfg-seb-$(qualifier) && \
		$(MAKE) install
	touch "$@"

15:
	sudo netctl start main
	sudo netctl enable main
	sleep 15
	touch "$@"

pkg-extra: 20

20:
	sudo pacman $(optnoconfirm) -S openssh inetutils git sbsigntools base-devel pacman-contrib unzip
	sudo pacman $(optnoconfirm) -S fzf tree pydf htop nethogs lsd
	sudo pacman $(optnoconfirm) -S mlocate
	sudo pacman $(optnoconfirm) -S shellcheck efitools the_silver_searcher gnu-efi \
		cpanminus pandoc tldr
	tldr -u
	LANG='' tldr -u
	touch "$@"

yaourt: 30

30:
	./cfg-30-yaourt.sh
	touch "$@"

kernconf: 40 41 50

40:
	tar -zxvf cfg-40-uefikeys-PRIVATE.tar.gz
	cd uefikeys && sudo $(MAKE) install
	touch "$@"

41:
	tar -zxvf cfg-41-kernsign.tar.gz
	cd kernsign && sudo $(MAKE) install
	touch "$@"

50:
	sudo ./cfg-50-freezpkg.sh
	touch "$@"

52:
	gpg --keyserver hkp://keys.gnupg.net:80 --recv-key 6AD860EED4598027
	yaourt -a zfs-utils
	yaourt -a zfs-linux-lts
	touch "$@"

csdcard: 45

45:
	tar -zxvf cfg-45-csdcard-PRIVATE.tar.gz
	cd csdcard && sudo $(MAKE) install
	touch "$@"

postfix: 55 56

55:
	sudo pacman $(optnoconfirm) -S s-nail postfix
	touch "$@"

56:
	if [ -e cfg-56-postfix-PRIVATE.tar.gz ]; then \
		sudo tar -zxvf cfg-56-postfix-PRIVATE.tar.gz; \
	else \
		sudo tar -zxvf cfg-56-postfix-PUBLIC.tar.gz; \
	fi
	cd postfix && sudo $(MAKE) configure
	touch "$@"

cpanm: 57

57:
	sudo pacman $(optnoconfirm) -S unzip graphviz
	cpanm List::MoreUtils
	cpanm Imager
	cpanm --force Imager::Screenshot
	cpanm URI::file
	cpanm DBM::Deep
	cpanm Proc::ProcessTable
	cpanm MP3::Tag
	cpanm GraphViz
	cpanm Readonly
	cpanm XML::LibXML
	cpanm File::Touch
	cpanm DateTime
	cpanm Regexp::Common
	touch "$@"

58:
	tar -zxvf cfg-58-autosvg.tar.gz
	cd autosvg && sudo $(MAKE) configure
	touch "$@"

gnome: 60 61

60:
	sudo pacman $(optnoconfirm) -S mesa xf86-video-intel xorg-server xorg-apps
	@echo "Selection recommendations:"
	@echo "  libjack.so provider, select 2 (jack2)"
	@echo "  xdg-desktop-portal-impl, select 1 (xdg-desktop-portal-gtk)"
	@echo "  ttf-font, select 5 (ttf-dejavu)"
	@echo "Press [Enter] key to continue"
	@if [ "$(noconfirm)" != "1" ]; then \
		read -r resp; \
	fi
	sudo pacman $(optnoconfirm) -S gnome gnome-extra
	touch "$@"

61:
	./cfg-61-gnome-conf.sh
	touch "$@"

i3: 70 71

70:
	sudo pacman $(optnoconfirm) -S i3-wm hsetroot i3lock xautolock numlockx otf-font-awesome dmenu
#     altab-git installation with yaourt produces an error. The commit is:
#         45816dc7777b63284bd82c49683e7dd6d9955571
#         of 2020-04-21
#     This comment was written 2020-07-11
#     yaourt -a alttab-git
	yaourt -a bumblebee-status
	gpg --keyserver hkp://keys.gnupg.net:80 --recv-key 9B8450B91D1362C1
	yaourt -a j4-dmenu-desktop
	touch "$@"

i3-conf: 71

71:
	tar -zxvf cfg-71-i3-conf.tar.gz
	cd i3-conf && $(MAKE) install
	touch "$@"

pkg-gui: 80

80:
	sudo pacman $(optnoconfirm) -S alacritty
	@if [ "$(noconfirm)" == "1" ]; then \
		sudo pacman $(optnoconfirm) -R vim; \
	fi
	sudo pacman $(optnoconfirm) -S gvim
	sudo pacman $(optnoconfirm) -S veracrypt
	sudo pacman $(optnoconfirm) -S vlc mplayer
	sudo pacman $(optnoconfirm) -S thunderbird thunderbird-i18n-fr
	sudo pacman $(optnoconfirm) -S firefox firefox-i18n-fr
	sudo pacman $(optnoconfirm) -S gwenview
	sudo pacman $(optnoconfirm) -S qbittorrent
	balooctl disable
	touch "$@"

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
	rm -f [0-9][0-9]

# vim: ts=4:sw=4:tw=80:
