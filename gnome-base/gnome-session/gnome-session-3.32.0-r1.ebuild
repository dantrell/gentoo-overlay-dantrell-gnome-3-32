# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson xdg

DESCRIPTION="Gnome session manager"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-session"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="consolekit doc elogind gconf systemd wayland"
# There is a null backend available, thus ?? not ^^
# consolekit can be enabled alone, or together with a logind provider; in latter case CK is used as fallback
REQUIRED_USE="
	?? ( consolekit elogind systemd )
	wayland? ( || ( elogind systemd ) )
"

COMMON_DEPEND="
	>=dev-libs/glib-2.46.0:2
	>=x11-libs/gtk+-3.18.0:3
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	>=gnome-base/gnome-desktop-3.18:3=
	>=dev-libs/json-glib-0.10
	gconf? ( >=gnome-base/gconf-2:2 )
	wayland? ( media-libs/mesa[egl(+),gles2] )
	!wayland? ( media-libs/mesa[gles2,X(+)] )
	media-libs/libepoxy
	x11-libs/libXcomposite

	systemd? ( sys-apps/systemd )
	elogind? ( sys-auth/elogind )
	consolekit? ( >=sys-auth/consolekit-0.9 )
"

# Pure-runtime deps from the session files should *NOT* be added here
# Otherwise, things like gdm pull in gnome-shell.
# gnome-settings-daemon is assumed to be >=3.27.90, but this is about
# removed components, so no need to strictly require it (older just
# won't have those daemons loaded by gnome-session).
# x11-misc/xdg-user-dirs{,-gtk} are needed to create the various XDG_*_DIRs, and
# create .config/user-dirs.dirs which is read by glib to get G_USER_DIRECTORY_*
# xdg-user-dirs-update is run during login (see 10-user-dirs-update-gnome below).
# sys-apps/dbus[X] is needed for session management.
# Our 90-xcursor-theme-gnome reads a setting from gsettings-desktop-schemas.
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gnome-settings-daemon-3.23.2
	>=gnome-base/gsettings-desktop-schemas-0.1.7
	sys-apps/dbus[X]

	x11-misc/xdg-user-dirs
	x11-misc/xdg-user-dirs-gtk
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	dev-util/gdbus-codegen
	>=sys-devel/gettext-0.19.8
	x11-libs/xtrans
	virtual/pkgconfig
	doc? ( app-text/xmlto
		app-text/docbook-xml-dtd:4.1.2 )
"

src_prepare() {
	# Install USE=doc in ${PF} if enabled
	sed -i -e "s:meson\.project_name(), 'dbus':'${PF}', 'dbus':" doc/dbus/meson.build || die

	if use gconf; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-session/-/commit/926c3fce17d9665047412046a7298fad55934b2d
		eapply "${FILESDIR}"/${PN}-3.28.1-support-gconf.patch
	fi

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-session/-/commit/d8b8665dae18700cc4caae5e857b1c23a005a62e
	eapply "${FILESDIR}"/${PN}-3.28.1-support-old-upower.patch

	eapply "${FILESDIR}"/${PN}-3.30.1-support-elogind.patch

	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		-Ddeprecation_flags=false
		$(meson_use elogind)
		-Dsession_selector=true # gnome-custom-session
		$(meson_use systemd)
		$(meson_use systemd systemd_journal)
		$(meson_use consolekit)
		$(meson_use doc docbook)
		-Dman=true
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	dodir /etc/X11/Sessions
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}"/Gnome

	insinto /usr/share/applications
	newins "${FILESDIR}"/${PN}-3.16.0-defaults.list gnome-mimeapps.list

	dodir /etc/X11/xinit/xinitrc.d/
	exeinto /etc/X11/xinit/xinitrc.d/
	newexe "${FILESDIR}"/15-xdg-data-gnome-r1 15-xdg-data-gnome

	# This should be done here as discussed in bug #270852
	newexe "${FILESDIR}"/10-user-dirs-update-gnome-r1 10-user-dirs-update-gnome

	# Set XCURSOR_THEME from current dconf setting instead of installing
	# default cursor symlink globally and affecting other DEs (bug #543488)
	# https://bugzilla.gnome.org/show_bug.cgi?id=711703
	newexe "${FILESDIR}"/90-xcursor-theme-gnome 90-xcursor-theme-gnome
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	if ! has_version gnome-base/gdm && ! has_version x11-misc/sddm; then
		ewarn "If you use a custom .xinitrc for your X session,"
		ewarn "make sure that the commands in the xinitrc.d scripts are run."
	fi

	if ! use systemd && ! use elogind && ! use consolekit; then
		ewarn "You are building without systemd, elogind and/or consolekit support."
		ewarn "gnome-session won't be able to correctly track and manage your session."
	fi
}

pkg_postrm() {
	xdg_pkg_postinst
	gnome2_schemas_update
}
