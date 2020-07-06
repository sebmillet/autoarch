copytarget=/usr/local/etc/uefikeys

default:
	@echo "Run 'sudo make install' to install UEFI keys"
	exit 1

install:
	mkdir -p "${copytarget}"
	cp -i *.crt "${copytarget}"
	cp -i *.esl "${copytarget}"
	cp -i *.key "${copytarget}"
	cp -i GUID.txt "${copytarget}"
	cp -i *.auth "${copytarget}"
	chmod -R 400 "${copytarget}"
	chmod 500 "${copytarget}"

