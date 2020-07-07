default: dist

update:
	cp -av /usr/local/etc/uefikeys .
	chown -R "${SUDO_USER}": uefikeys
	cp -av src/uefikeys-Makefile uefikeys/Makefile
	cp -av /usr/local/etc/csdcard .
	chown -R "${SUDO_USER}": csdcard
	cp -av src/csdcard-Makefile csdcard/Makefile

dist:
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
	cp src/pkg-extra.txt install/cfg-20-pkg-extra.txt
	cp src/yaourt.sh install/cfg-30-yaourt.sh
	tar -zcvf uefikeys.tar.gz uefikeys
	mv uefikeys.tar.gz install/cfg-40-uefikeys.tar.gz
	tar -zcvf csdcard.tar.gz csdcard
	mv csdcard.tar.gz install/cfg-45-csdcard.tar.gz
	cd ~/travail/svg/configs && $(MAKE)
	mv ~/travail/svg/configs/cfg-seb.tar.gz install/cfg-10-seb.tar.gz
	cd src && tar -zcvf kernsign.tar.gz kernsign
	mv src/kernsign.tar.gz install/cfg-41-kernsign.tar.gz
	cp src/freezpkg.sh install/cfg-50-freezpkg.sh
	cp src/gnome-inst.txt install/cfg-60-gnome-inst.txt
	cp src/gnome-conf.pseudo_sh install/cfg-61-gnome-conf.sh
	./manage-includes.sh install/cfg-61-gnome-conf.sh
	cp src/i3-inst.txt install/cfg-70-i3-inst.txt
	mkdir -p install/i3-conf && \
		cd install/i3-conf && \
		cp -vL --preserve=all ../../src/i3-conf/* . && \
		cd .. && \
		tar -zcvf cfg-71-i3-conf.tar.gz i3-conf && \
		rm i3-conf/* && \
		rmdir i3-conf
	cp src/pkg-gui.txt install/cfg-80-pkg-gui.txt
	tar -zcvf IN$(shell date +%y%m%d).tgz install

clean:
	if [ -e install/Makefile ]; then \
		cd install && $(MAKE) clean; \
	fi
	cd ~/travail/svg/configs && $(MAKE) clean
	rm -rf install

mrproper: clean
	if [ -d uefikeys ]; then chmod u+w uefikeys; fi
	rm -rf uefikeys
	if [ -d csdcard ]; then chmod u+w csdcard; fi
	rm -rf csdcard

