copytarget=/usr/local/etc/csdcard
devsdcard=/dev/mmcblk0p1

default:
	@echo "Run 'sudo make install' to install csdcard config elements"
	exit 1

install:
	mkdir -p "${copytarget}"
	cp $(cpopt) sdcard-keyfile "${copytarget}"
	chmod -R 400 "${copytarget}"
	chmod 500 "${copytarget}"
	if grep -c "csdcard" /etc/crypttab; then \
		echo "/etc/crypttab already has en entry for csdcard"; \
	else \
		echo "## Makefile of csdcard (install scripts)" >> /etc/crypttab; \
		echo "csdcard        ${devsdcard}                               /usr/local/etc/csdcard/sdcard-keyfile luks" >> /etc/crypttab; \
	fi
	if grep -c "csdcard" /etc/fstab; then \
		echo "/etc/fstab already has en entry for csdcard"; \
	else \
		echo "## Makefile of csdcard (install scripts)" >> /etc/fstab; \
		echo "/dev/mapper/csdcard /mnt/csdcard ext4   noauto,rw,nosuid,nodev,noatime,users   0 0" >> /etc/fstab; \
	fi
	mkdir -p /mnt/csdcard
	@echo "* ******************************************************************* *"
	@echo "* /etc/fstab entry for csdcard has been written with 'noauto' option. *"
	@echo "* Before removing this option, you may check /mnt/csdcard can be      *"
	@echo "* mounted successfully.                                               *"
	@echo "* ******************************************************************* *"

