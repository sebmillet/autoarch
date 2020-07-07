copytarget=/usr/local/etc/csdcard
devsdcard=/dev/mmcblk0p1

default:
	@echo "Run 'sudo make install' to install csdcard config elements"
	exit 1

install:
	mkdir -p "${copytarget}"
	cp -i sdcard-keyfile "${copytarget}"
	chmod -R 400 "${copytarget}"
	chmod 500 "${copytarget}"
	if [ "$(grep -c "csdcard" /etc/crypttab)" != "0" ]; then \
		echo "/etc/crypttab already has en entry for csdcard"; \
		exit 1; \
	fi
	echo >> /etc/crypttab
	echo "csdcard        ${devsdcard}                               /usr/local/etc/csdcard/sdcard-keyfile luks" >> /etc/crypttab

