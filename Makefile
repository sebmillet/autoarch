default:
	@echo "Run 'make dist' to prepare files in install directory"

dist:
	tar -zcvf uefikeys.tar.gz uefikeys
	mv uefikeys.tar.gz install/cfg-02-uefikeys.tar.gz
	cd ~/travail/svg/configs && $(MAKE)
	mv ~/travail/svg/configs/cfg-seb.tar.gz install/cfg-00-seb.tar.gz
	tar -zcvf kernsign.tar.gz kernsign
	mv kernsign.tar.gz install/cfg-03-kernsign.tar.gz

clean:
	rm -f install/cfg-02-uefikeys.tar.gz
	rm -f install/cfg-00-seb.tar.gz
	rm -f install/cfg-03-kernsign.tar.gz

