default:
	@echo "Run 'sudo make install' to install kernel sign pacman hook"

install:
	mkdir -p /etc/pacman.d/hooks
	cp $(cpopt) /usr/share/libalpm/hooks/90-mkinitcpio-install.hook \
		/etc/pacman.d/hooks/90-mkinitcpio-install.hook
	patch /etc/pacman.d/hooks/90-mkinitcpio-install.hook \
		< 90-mkinitcpio-install.hook.patch
	mkdir -p /usr/local/share/libalpm/scripts
	cp $(cpopt) /usr/share/libalpm/scripts/mkinitcpio-install \
		/usr/local/share/libalpm/scripts/mkinitcpio-install
	patch /usr/local/share/libalpm/scripts/mkinitcpio-install \
		< mkinitcpio-install.patch

clean:
	rm -f /etc/pacman.d/hooks/90-mkinitcpio-install.hook
	rm -f /usr/local/share/libalpm/scripts/mkinitcpio-install

