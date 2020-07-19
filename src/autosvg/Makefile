default:
	@echo "Run 'sudo make configure' to configure autosvg"

configure:
	pacman -S cronie rsnapshot
	mkdir -p /test-rsnapshot-backup
	cp -i rsync.exclude /etc/
	if [ -e /etc/rsnapshot.conf ]; then \
		mv /etc/rsnapshot.conf /etc/rsnapshot.conf.prev; \
	fi
	cp -i rsnapshot.conf /etc/
	cp -i recfilestats /etc/cron.weekly/
	if grep -c "TAGSEBMILLETANACRONTAB" /etc/anacrontab; then \
		echo "/etc/anacrontab already updated, skipping this step."; \
	else \
		echo '' >> /etc/anacrontab; \
		echo '# TAGSEBMILLETANACRONTAB' >> /etc/anacrontab; \
		echo '# Sébastien Millet, August 2015, July 2020' >> /etc/anacrontab; \
		echo '@daily	5	svgdaily	/home/sebastien/travail/scripts/svg-admin-c.sh daily > /dev/null' >> /etc/anacrontab; \
		echo '@weekly	15	svgweekly	/home/sebastien/travail/scripts/svg-admin-c.sh weekly' >> /etc/anacrontab; \
		echo '@monthly	35	svgmonthly	/home/sebastien/travail/scripts/svg-admin-c.sh monthly' >> /etc/anacrontab; \
		echo '@daily	10	sebdaily	/home/sebastien/travail/scripts/svg-cseb.sh daily > /dev/null' >> /etc/anacrontab; \
		echo '@weekly	25	sebweekly	/home/sebastien/travail/scripts/svg-cseb.sh weekly' >> /etc/anacrontab; \
		echo '@monthly	50	sebmonthly	/home/sebastien/travail/scripts/svg-cseb.sh monthly' >> /etc/anacrontab; \
		echo '' >> /etc/anacrontab; \
		echo '# Sébastien Millet, February 2020, July 2020' >> /etc/anacrontab; \
		echo '@daily	5	rsnapshot-daily	rsnapshot daily' >> /etc/anacrontab; \
		echo '@weekly	20	rsnapshot-weekly	rsnapshot weekly' >> /etc/anacrontab; \
		echo '@monthly	45	rsnapshot-monthly	rsnapshot monthly' >> /etc/anacrontab; \
	fi
	read -r -p "Activate cronie at startup? (y/N)" resp; \
	if [ "$${resp}" == "y" ]; then \
		systemctl enable cronie.service; \
	fi
	@echo
	@echo "* ************************************ *"
	@echo "* /etc/rsnapshot.conf is in test mode  *"
	@echo "* You must update it to make it useful *"
	@echo "* ************************************ *"

