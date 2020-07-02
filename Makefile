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
	cp src/aa.sh install/
	cp src/yaourt.sh install/cfg-01-yaourt.sh
	cp src/freezpkg.sh install/cfg-04-freezpkg.sh
	tar -zcvf uefikeys.tar.gz uefikeys
	mv uefikeys.tar.gz install/cfg-02-uefikeys.tar.gz
	cd ~/travail/svg/configs && $(MAKE)
	mv ~/travail/svg/configs/cfg-seb.tar.gz install/cfg-00-seb.tar.gz
	cd src && tar -zcvf kernsign.tar.gz kernsign
	mv src/kernsign.tar.gz install/cfg-03-kernsign.tar.gz

clean:
	rm -rf install

mrproper: clean
	if [ -d uefikeys ]; then chmod u+w uefikeys; fi
	rm -rf uefikeys

