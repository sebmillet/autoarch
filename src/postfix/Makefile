default:
	@echo "Run 'sudo make configure' to configure postfix"

configure:
	cp $(cpopt) /etc/postfix/aliases /etc/
	patch /etc/aliases < aliases.patch
	if [ ! -e /etc/postfix/main.cf.orig ]; then \
		cp /etc/postfix/main.cf /etc/postfix/main.cf.orig; \
	fi
	cp $(cpopt) /etc/postfix/main.cf.orig /etc/postfix/main.cf
	patch /etc/postfix/main.cf < main.cf.patch
	cp $(cpopt) passwd sender_canonical /etc/postfix/
	newaliases
	postmap hash:/etc/postfix/passwd
	postmap hash:/etc/postfix/sender_canonical
	chmod 600 /etc/postfix/passwd*
	chmod 644 /etc/postfix/sender_canonical*
	systemctl enable postfix.service
	systemctl restart postfix.service

