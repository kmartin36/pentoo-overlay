# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Pentoo meta ebuild to install all X and WM/DE related things"
HOMEPAGE="https://www.pentoo.org"
S="${WORKDIR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm ~arm64 x86"
IUSE="X cups enlightenment +firefox kde livecd-stage1 mate pentoo-in-a-container pentoo-full policykit pulseaudio +vnc +xfce"

#X windows stuff
PDEPEND="X? (
		!livecd-stage1? ( || ( x11-base/xorg-server dev-libs/wayland ) )
		app-admin/genmenu
		net-misc/networkmanager
		|| ( x11-misc/slim x11-misc/sddm )
		app-arch/file-roller
		amd64? (
			sys-firmware/sof-firmware
			|| ( www-client/chromium www-client/google-chrome www-client/google-chrome-beta www-client/google-chrome-unstable )
		)

		pentoo-full? (
			dev-libs/light
			net-misc/x11-ssh-askpass
			x11-apps/setxkbmap
			x11-apps/xbacklight
			x11-apps/xinit
			x11-apps/xinput
			x11-misc/arandr
			x11-apps/xrandr
			x11-terms/rxvt-unicode
			x11-terms/terminator
			x11-themes/gtk-theme-switch
		)
		pulseaudio? (
			|| ( kde? ( media-sound/pavucontrol-qt ) media-sound/pavucontrol )
		)
		vnc? (
			|| ( kde? ( kde-apps/krdc ) net-misc/tigervnc )
		)
		firefox? (
			pentoo-in-a-container? (
				|| ( www-client/firefox-bin www-client/firefox )
			)
			!pentoo-in-a-container? (
				x86? ( || ( www-client/firefox-bin www-client/firefox ) )
				!x86? ( || ( www-client/firefox www-client/firefox-bin ) )
			)
		)
	)"
#end X Windows stuff

# Window makers
PDEPEND="${PDEPEND}
	enlightenment? ( x11-wm/enlightenment:0.17
		x11-terms/terminology
		gnome-base/gnome-menus
	)
	kde? ( kde-plasma/plasma-meta
		kde-apps/konsole
		kde-apps/gwenview
		kde-apps/kate
		kde-apps/kcalc
		kde-apps/kcharselect
		kde-apps/kmix
		kde-apps/kolourpaint
		kde-plasma/spectacle
		kde-apps/okular
		kde-apps/dolphin
		kde-apps/kio-extras
	)
	mate? ( mate-base/mate
		gnome-extra/nm-applet
		x11-misc/mate-notification-daemon
	)
	xfce? ( xfce-base/xfce4-meta
		pulseaudio? ( xfce-extra/xfce4-volumed-pulse )
		gnome-extra/nm-applet
		app-editors/leafpad
		app-text/evince
		app-text/mupdf
		media-gfx/geeqie
		sys-apps/gnome-disk-utility
		x11-terms/xfce4-terminal
		x11-themes/tango-icon-theme
		xfce-base/thunar
		xfce-base/thunar-volman
		xfce-base/xfdesktop[pentoo(-)]
		xfce-extra/thunar-archive-plugin
		xfce-extra/thunar-vcs-plugin
		xfce-base/tumbler
		xfce-extra/xfce4-battery-plugin
		xfce-extra/xfce4-sensors-plugin
		pulseaudio? ( xfce-extra/xfce4-pulseaudio-plugin )
		xfce-extra/xfce4-notifyd
		xfce-extra/xfce4-screenshooter
		xfce-extra/xfce4-xkb-plugin
	)"

src_install() {
	#/usr/bin
	use enlightenment && newbin "${FILESDIR}"/dokeybindings-2012.1 dokeybindings

	dodir /etc/env.d
	use kde && echo 'XSESSION="kde"' > "${ED}"/etc/env.d/90xsession
	use xfce && echo 'XSESSION="Xfce4"' > "${ED}"/etc/env.d/90xsession

	insinto /etc/skel
	newins "${FILESDIR}"/Xdefaults .Xdefaults
	use xfce && newins "${FILESDIR}"/xfce-xinitrc .xinitrc

	if use amd64; then
		insinto /etc/skel/.config
		doins "${FILESDIR}"/mimeapps.list
	fi

	insinto /etc/skel/.config/gtk-3.0/
	newins "${FILESDIR}"/gtk3-settings.ini settings.ini

	insinto /etc/skel/.config/xfce4/terminal/
	doins "${FILESDIR}"/terminalrc

	insinto /usr/share/pentoo/wallpaper
	doins "${FILESDIR}"/domo-roolz.jpg
	doins "${FILESDIR}"/domo-roolz-shmoocon2014.png
	doins "${FILESDIR}"/tux-winfly-killah.1600x1200.jpg
	dosym /usr/share/pentoo/wallpaper/domo-roolz.jpg /usr/share/backgrounds/xfce/domo-roolz.jpg
	dosym /usr/share/pentoo/wallpaper/domo-roolz-shmoocon2014.png /usr/share/backgrounds/xfce/domo-roolz-shmoocon2014.png
	dosym /usr/share/pentoo/wallpaper/tux-winfly-killah.1600x1200.jpg /usr/share/backgrounds/xfce/tux-winfly-killah.1600x1200.jpg

	insinto /etc/skel/.config/xfce4
	doins "${FILESDIR}"/helpers.rc
	insinto /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
	doins "${FILESDIR}"/xsettings.xml

	#gtk-theme-switch needs X so do it manually
	insinto /etc/skel
	newins "${FILESDIR}"/gtkrc-2.0 .gtkrc-2.0

	#make policykit respect wheel
	if use policykit; then
		insinto /etc/polkit-1/rules.d
		doins "${FILESDIR}"/10-admin.rules
	fi
}
