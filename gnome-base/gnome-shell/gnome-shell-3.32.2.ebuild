# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_8,3_9,3_10,3_11} )

inherit gnome.org gnome2-utils meson pax-utils python-single-r1 virtualx xdg

DESCRIPTION="Provides core UI functions for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Projects/GnomeShell https://gitlab.gnome.org/GNOME/gnome-shell"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="+bluetooth deprecated-background elogind gtk-doc +ibus +networkmanager systemd telepathy vanilla-async vanilla-gc vanilla-motd vanilla-screen wayland"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	?? ( elogind systemd )
"

# libXfixes-5.0 needed for pointer barriers and #include <X11/extensions/Xfixes.h>
COMMON_DEPEND="
	>=dev-libs/libcroco-0.6.8:0.6
	>=gnome-extra/evolution-data-server-3.17.2:=
	>=app-crypt/gcr-3.7.5:0=[introspection]
	>=gnome-base/gnome-desktop-3.7.90:3=[introspection]
	>=dev-libs/glib-2.57.2:2
	>=dev-libs/gobject-introspection-1.49.1:=
	>=dev-libs/gjs-1.54.0
	>=x11-libs/gtk+-3.15.0:3[introspection]
	>=x11-wm/mutter-3.32.0[introspection]
	>=sys-auth/polkit-0.100[introspection]
	>=gnome-base/gsettings-desktop-schemas-3.27.90
	>=x11-libs/startup-notification-0.11
	>=app-i18n/ibus-1.5.2
	bluetooth? ( >=net-wireless/gnome-bluetooth-3.9[introspection] )
	>=media-libs/gstreamer-0.11.92:1.0
	networkmanager? (
		>=net-misc/networkmanager-1.10.4:=[introspection]
		>=app-crypt/libsecret-0.18
		dev-libs/dbus-glib )
	systemd? ( sys-apps/systemd )
	elogind? ( sys-auth/elogind )

	>=app-accessibility/at-spi2-atk-2.5.3
	media-libs/libcanberra[gtk3]
	x11-libs/gdk-pixbuf:2[introspection]
	dev-libs/libxml2:2
	x11-libs/libX11

	>=media-sound/pulseaudio-2[glib]
	>=dev-libs/atk-2[introspection]
	dev-libs/libical:=
	>=x11-libs/libXfixes-5.0

	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	wayland? ( media-libs/mesa )
	!wayland? ( media-libs/mesa[X(+)] )
"
# Runtime-only deps are probably incomplete and approximate.
# Introspection deps generated using:
#  grep -roe "imports.gi.*" gnome-shell-* | cut -f2 -d: | sort | uniq
# Each block:
# 1. Introspection stuff needed via imports.gi.*
# 2. gnome-session needed for shutdown/reboot/inhibitors/etc
# 3. Control shell settings
# 4. logind interface needed for suspending support
# 5. xdg-utils needed for xdg-open, used by extension tool
# 6. adwaita-icon-theme needed for various icons & arrows (3.26 for new video-joined-displays-symbolic and co icons; review for 3.28+)
# 7. mobile-broadband-provider-info, timezone-data for shell-mobile-providers.c  # TODO: Review
# 8. IBus is needed for nls integration
# 9. Optional telepathy chat integration
# 10. Cantarell font used in gnome-shell global CSS (if removing this for some reason, make sure it's pulled in somehow for non-meta users still too)
# 11. TODO: semi-optional webkit-gtk[introspection] for captive portal helper
RDEPEND="${COMMON_DEPEND}
	>=sys-apps/accountsservice-0.6.14[introspection]
	app-accessibility/at-spi2-core:2[introspection]
	app-misc/geoclue[introspection]
	>=dev-libs/libgweather-3.26:2[introspection]
	>=sys-power/upower-0.99:=[introspection]
	x11-libs/pango[introspection]
	gnome-base/librsvg:2[introspection]

	>=gnome-base/gnome-session-2.91.91
	>=gnome-base/gnome-settings-daemon-3.8.3

	x11-misc/xdg-utils

	>=x11-themes/adwaita-icon-theme-3.26

	networkmanager? (
		net-misc/mobile-broadband-provider-info
		sys-libs/timezone-data )
	ibus? ( >=app-i18n/ibus-1.4.99[dconf(+),gtk,introspection] )
	telepathy? (
		>=net-im/telepathy-logger-0.2.4[introspection]
		>=net-libs/telepathy-glib-0.19[introspection] )
	media-fonts/cantarell
	media-fonts/dejavu
"
# avoid circular dependency, see bug #546134
PDEPEND="
	>=gnome-base/gdm-3.5[introspection(+)]
	>=gnome-base/gnome-control-center-3.26[bluetooth(+)?,networkmanager(+)?]
"
DEPEND="${COMMON_DEPEND}
	dev-lang/sassc
	dev-libs/libxslt
	>=dev-util/gdbus-codegen-2.45.3
	gtk-doc? ( >=dev-util/gtk-doc-1.17 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	if use deprecated-background; then
		eapply "${FILESDIR}"/${PN}-3.26.1-restore-deprecated-background-code.patch
	fi

	if ! use vanilla-async; then
		# From Endless:
		# 	https://github.com/endlessm/gnome-shell/commit/6d675c2c7df6652291f45f08293eadddc1ef65bc
		eapply "${FILESDIR}"/${PN}-3.20.4-gtk-embed-dont-allow-multiple-async-allocations.patch
	fi

	if ! use vanilla-gc; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-shell/issues/64
		eapply "${FILESDIR}"/${PN}-3.14.4-force-garbage-collection.patch
	fi

	if ! use vanilla-motd; then
		eapply "${FILESDIR}"/${PN}-3.32.0-improve-motd-handling.patch
	fi

	if ! use vanilla-screen; then
		eapply "${FILESDIR}"/${PN}-3.32.0-improve-screen-blanking.patch
	fi

	# Change favorites defaults, bug #479918
	eapply "${FILESDIR}"/${PN}-3.22.0-defaults.patch

	# Fix automagic gnome-bluetooth dep, bug #398145
	eapply "${FILESDIR}"/${PN}-3.32.0-optional-bluetooth.patch

	# Hack in correct python shebang
	sed -e "s:python\.path():'/usr/bin/env ${EPYTHON}':" -i src/meson.build || die

	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use bluetooth)
		$(meson_use gtk-doc gtk_doc)
		-Dman=true
		$(meson_use networkmanager)
		$(meson_use systemd) # this controls journald integration only as of 3.26.2 (structured logging and having gnome-shell launched apps use its own identifier instead of gnome-session)
		# suspend support is runtime optional via /run/systemd/seats presence and org.freedesktop.login1.Manager dbus interface; elogind should provide what's necessary
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# Required for gnome-shell on hardened/PaX, bug #398941; FIXME: Is this still relevant?
	pax-mark m "${ED}usr/bin/gnome-shell"{,-extension-prefs}
}

src_test() {
	virtx meson_src_test
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	if ! has_version 'media-libs/gst-plugins-good:1.0' || \
	   ! has_version 'media-plugins/gst-plugins-vpx:1.0'; then
		ewarn "To make use of GNOME Shell's built-in screen recording utility,"
		ewarn "you need to either install media-libs/gst-plugins-good:1.0"
		ewarn "and media-plugins/gst-plugins-vpx:1.0, or use dconf-editor to change"
		ewarn "apps.gnome-shell.recorder/pipeline to what you want to use."
	fi

	if ! has_version "media-libs/mesa[llvm]"; then
		elog "llvmpipe is used as fallback when no 3D acceleration"
		elog "is available. You will need to enable llvm USE for"
		elog "media-libs/mesa if you do not have hardware 3D setup."
	fi

	# https://bugs.gentoo.org/563084
	if has_version "x11-drivers/nvidia-drivers[-kms]"; then
		ewarn "You will need to enable kms support in x11-drivers/nvidia-drivers,"
		ewarn "otherwise Gnome will fail to start"
	fi

	if use systemd && [[ ! -d /run/systemd/system ]]; then
		ewarn "You have installed GNOME Shell *with* systemd support"
		ewarn "but the system was not booted using systemd."
		ewarn "To correct this, reference: https://wiki.gentoo.org/wiki/Systemd"
	fi

	if ! use systemd; then
		ewarn "You have installed GNOME Shell *without* systemd support."
		ewarn "To report issues, see: https://github.com/dantrell/gentoo-project-gnome-without-systemd/blob/master/GOVERNANCE.md#bugs-and-other-issues"
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
