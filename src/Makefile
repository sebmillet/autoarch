default:
	@echo "Run 'make NN' to install/configure element 'NN'"

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
	./cfg-05-gnome-inst.sh

06:
	./cfg-06-gnome-conf.sh

i3: 07 08

07:
	./cfg-07-i3-inst.sh

08:
	tar -zxvf cfg-08-i3-conf.tar.gz
	cd i3-conf && $(MAKE) install

clean:
	rm -rf cfg-seb
	if [ -d uefikeys ]; then \
		chmod +w uefikeys; \
		chmod +w uefikeys/*; \
	fi
	rm -rf uefikeys
	rm -rf kernsign
	rm -rf i3-conf

