default: dist

update:
	cp -av /usr/local/etc/uefikeys .
	chown -R "${SUDO_USER}": uefikeys
	cp -av src/uefikeys-Makefile uefikeys/Makefile

dist:
	@if [ ! -f uefikeys/Makefile ]; then \
		echo "Incorrect or missing uefikeys directory:" \
			 "run 'sudo make update' first"; \
		exit 1; \
	fi
	mkdir -p install
	cp src/Makefile install/
	cp src/aa.sh install/
	cp src/yaourt.sh install/cfg-01-yaourt.sh
	tar -zcvf uefikeys.tar.gz uefikeys
	mv uefikeys.tar.gz install/cfg-02-uefikeys.tar.gz
	cd ~/travail/svg/configs && $(MAKE)
	mv ~/travail/svg/configs/cfg-seb.tar.gz install/cfg-00-seb.tar.gz
	cd src && tar -zcvf kernsign.tar.gz kernsign
	mv src/kernsign.tar.gz install/cfg-03-kernsign.tar.gz
	cp src/freezpkg.sh install/cfg-04-freezpkg.sh
	cp src/gnome-inst.sh install/cfg-05-gnome-inst.sh
	cp src/gnome-conf.pseudo_sh install/cfg-06-gnome-conf.sh
	./manage-includes.sh install/cfg-06-gnome-conf.sh
	mkdir -p install/i3-conf && \
		cd install/i3-conf && \
		cp -vL --preserve=all ../../src/i3-conf/* . && \
		cd .. && \
		tar -zcvf cfg-08-i3-conf.tar.gz i3-conf && \
		rm i3-conf/* && \
		rmdir i3-conf
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

