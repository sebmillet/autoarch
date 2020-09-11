default: install

.PHONY: update dist clean distclean mrproper

uefikeys/Makefile: src/uefikeys-Makefile
	@read -r -p "$@ needs be updated. Run 'sudo make update'? (y/N) " resp; \
	if [ "$$resp" != "y" ]; then \
		echo "Aborted."; \
		exit 10; \
	fi
	sudo $(MAKE) update

csdcard/Makefile: src/csdcard-Makefile
	@read -r -p "$@ needs be updated. Run 'sudo make update'? (y/N) " resp; \
	if [ "$$resp" != "y" ]; then \
		echo "Aborted."; \
		exit 10; \
	fi
	sudo $(MAKE) update

update:
	@if [ "${EUID}" != "0" ]; then \
		echo "WARNING: target 'update' run as a regular user."; \
		echo "         Should be launched as root ('sudo make update')"; \
	fi
	cp -av /usr/local/etc/uefikeys .
	chown -R "${SUDO_USER}": uefikeys
	cp -av src/uefikeys-Makefile uefikeys/Makefile
	cp -av /usr/local/etc/csdcard .
	chown -R "${SUDO_USER}": csdcard
	cp -av src/csdcard-Makefile csdcard/Makefile

install/.autoarch-install-directory: install

install: uefikeys/Makefile csdcard/Makefile
	@if [ ! -f uefikeys/Makefile ]; then \
		echo "Incorrect or missing uefikeys directory:" \
			 "run 'sudo make update' first"; \
		exit 1; \
	fi
	@if [ ! -f csdcard/Makefile ]; then \
		echo "Incorrect or missing csdcard directory:" \
			 "run 'sudo make update' first"; \
		exit 1; \
	fi
	mkdir -p install
	cp src/Makefile install/
	cp src/aa.sh install/
	cp src/6AD860EED4598027.gpg src/9B8450B91D1362C1.gpg install/
	cp src/nopwdsudo.txt install/cfg-05-nopwdsudo.txt
	cp src/network.txt install/cfg-15-network.txt
	cp src/pkg-extra.txt install/cfg-20-pkg-extra.txt
	cp src/yaourt.sh install/cfg-30-yaourt.sh
	cd src && tar -h -zcvf systemd.tar.gz systemd
	mv src/systemd.tar.gz install/cfg-35-systemd.tar.gz
	tar -zcvf uefikeys.tar.gz uefikeys
	mv uefikeys.tar.gz install/cfg-40-uefikeys-PRIVATE.tar.gz
	tar -zcvf csdcard.tar.gz csdcard
	mv csdcard.tar.gz install/cfg-45-csdcard-PRIVATE.tar.gz
	cd configs && $(MAKE)
	mv configs/cfg-seb-PRIVATE.tar.gz install/cfg-10-seb-PRIVATE.tar.gz
	mv configs/cfg-seb-PUBLIC.tar.gz install/cfg-10-seb-PUBLIC.tar.gz
	cd src && tar -h -zcvf kernsign.tar.gz kernsign
	mv src/kernsign.tar.gz install/cfg-41-kernsign.tar.gz
	cp src/freezpkg.sh install/cfg-50-freezpkg.sh
	cp src/zfs.txt install/cfg-52-zfs-NOT-PART-OF-DEFAULT-INSTALL.txt
	cp src/milletseb.publickey install/
	cp src/postfix-inst.txt install/cfg-55-postfix-inst.txt
	cd src && tar -h -zcvf postfix-PRIVATE.tar.gz --exclude=passwd-fake postfix
	mv src/postfix-PRIVATE.tar.gz install/cfg-56-postfix-PRIVATE.tar.gz
	mv -i src/postfix/Makefile src/postfix-PRIVATE-Makefile
	cp -i src/postfix-PUBLIC-Makefile src/postfix/Makefile
	mv -i src/postfix/passwd src/postfix/passwd-prod
	cp -i src/postfix/passwd-fake src/postfix/passwd
	cd src && tar -h -zcvf postfix-PUBLIC.tar.gz --exclude=passwd-prod --exclude=passwd-fake postfix
	mv src/postfix-PUBLIC.tar.gz install/cfg-56-postfix-PUBLIC.tar.gz
	rm src/postfix/passwd
	mv -i src/postfix/passwd-prod src/postfix/passwd
	rm src/postfix/Makefile
	mv -i src/postfix-PRIVATE-Makefile src/postfix/Makefile
	cp src/cpanm.txt install/cfg-57-cpanm.txt
	cd src && tar -h -zcvf autosvg.tar.gz autosvg
	cp src/gpgkeys.txt install/cfg-58-gpgkeys.txt
	mv src/autosvg.tar.gz install/cfg-59-autosvg.tar.gz
	cp src/gnome-inst.txt install/cfg-70-gnome-inst.txt
	cp src/gnome-conf.pseudo_sh install/cfg-71-gnome-conf.sh
	./manage-includes.sh install/cfg-71-gnome-conf.sh
	cp src/i3-inst.txt install/cfg-75-i3-inst.txt
	mkdir -p install/i3-conf && \
		cd install/i3-conf && \
		cp -vL --preserve=all ../../src/i3-conf/* . && \
		cd .. && \
		tar -zcvf cfg-76-i3-conf.tar.gz i3-conf && \
		rm i3-conf/* && \
		rmdir i3-conf
	cp src/pkg-gui.txt install/cfg-80-pkg-gui.txt
	cp src/update-conkyrc-netdev.sh install/cfg-91-update-conkyrc-netdev.sh
	echo $(shell date --iso-8601=seconds) > install/_timestamp
	cp README.md install/
	cp .version install/
	touch install/.autoarch-install-directory

dist: INSTPUB.tgz INSTPRIV.tgz

INSTPRIV.tgz: install/.autoarch-install-directory
	touch install/.private
	tar -zcvf INSTPRIV.tgz --exclude="*-PUBLIC*" install

INSTPUB.tgz: install/.autoarch-install-directory
	rm -f install/.private
	echo "not part of public archive" > install/cfg-40-uefikeys.txt
	echo "not part of public archive" > install/cfg-45-csdcard.txt
	tar -zcvf INSTPUB.tgz --exclude="*-PRIVATE*" install
	rm install/cfg-40-uefikeys.txt install/cfg-45-csdcard.txt

checkversion:
	@verfile=$(shell cat .version); \
		veraa=$(shell grep "^VERSION=" src/aa.sh | sed 's/.*=//'); \
		vergit=$(shell git tag | tail -1); \
		echo "Current version according to file .version = $$verfile"; \
		echo "Current version according to src/aa.sh     = $$veraa"; \
		echo "Current version according to git tags      = $$vergit"; \
		if [ "$$verfile" == "$$veraa" ] && [ "$$verfile" == "$$vergit" ]; then \
			echo "OK"; \
		else \
			echo "** ERROR **"; \
			exit 1; \
		fi

clean:
	if [ -e install/Makefile ]; then \
		cd install && $(MAKE) clean; \
	fi
	cd configs && $(MAKE) clean
	rm -rf install

distclean: clean
	rm -f INSTPRIV.tgz
	rm -f INSTPRIV-????-??-??.tgz
	rm -f INSTPUB.tgz
	rm -f INSTPUB-????-??-??.tgz

mrproper: clean distclean
	if [ -d uefikeys ]; then chmod u+w uefikeys; fi
	rm -rf uefikeys
	if [ -d csdcard ]; then chmod u+w csdcard; fi
	rm -rf csdcard

