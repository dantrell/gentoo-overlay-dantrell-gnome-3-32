# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GNOME2_LA_PUNT="yes"

inherit autotools gnome2 multilib systemd

DESCRIPTION="Personal file sharing for the GNOME desktop"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-user-share"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE=""

# FIXME: could libnotify be made optional ?
# FIXME: selinux automagic support
RDEPEND="
	>=dev-libs/glib-2.58:2
	>=x11-libs/gtk+-3:3
	>=gnome-base/nautilus-3.27.90
	media-libs/libcanberra[gtk3]
	>=www-apache/mod_dnssd-0.6
	>=www-servers/apache-2.2[apache2_modules_dav,apache2_modules_dav_fs,apache2_modules_authn_file,apache2_modules_auth_digest,apache2_modules_authz_groupfile]
	>=x11-libs/libnotify-0.7:=
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	# Upstream forces to use prefork because of Fedora defaults, but
	# that is problematic for us (bug #551012)
	# https://bugzilla.gnome.org/show_bug.cgi?id=750525#c2
	eapply "${FILESDIR}"/${PN}-3.18.1-no-prefork.patch

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/vino/-/commit/1538798a89653b8921ca574aebb3f153543b4921
	eapply "${FILESDIR}"/${PN}-3.18.2-allow-building-on-non-systemd-systems.patch

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--with-httpd=apache2 \
		--with-modules-path=/usr/$(get_libdir)/apache2/modules/ \
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
}
