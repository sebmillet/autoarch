copytarget=/usr/local/etc/uefikeys

default:
	@echo "Run 'sudo make install' to install UEFI keys"
	exit 1

install:
	mkdir -p "${copytarget}"
	cp $(cpopt) *.crt "${copytarget}"
	cp $(cpopt) *.esl "${copytarget}"
	cp $(cpopt) *.key "${copytarget}"
	cp $(cpopt) GUID.txt "${copytarget}"
	cp $(cpopt) *.auth "${copytarget}"
	chmod -R 400 "${copytarget}"
	chmod 500 "${copytarget}"

