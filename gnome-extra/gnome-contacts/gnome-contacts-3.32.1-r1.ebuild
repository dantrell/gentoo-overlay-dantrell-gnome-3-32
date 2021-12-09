# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson vala xdg

DESCRIPTION="GNOME contact management application"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Contacts"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="telepathy v4l"

VALA_DEPEND="
	$(vala_depend)
	>=dev-libs/gobject-introspection-1.54:=
	dev-libs/folks[vala(+)]
	net-libs/gnome-online-accounts:=[vala]
	gnome-extra/evolution-data-server[gtk,vala]
	net-libs/telepathy-glib[vala]
"
# Configure is wrong; it needs cheese-3.5.91, not 3.3.91
RDEPEND="
	>=gnome-extra/evolution-data-server-3.13.90:=[gnome-online-accounts]
	>=dev-libs/folks-0.11.4:=[eds,telepathy?]
	>=dev-libs/glib-2.44:2
	>=dev-libs/libgee-0.10:0.8
	>=gui-libs/libhandy-0.0.9:0.0=
	>=gnome-base/gnome-desktop-3.0:3=
	net-libs/gnome-online-accounts:=
	>=x11-libs/gtk+-3.22:3
	v4l? ( >=media-video/cheese-3.5.91:= )
	telepathy? ( >=net-libs/telepathy-glib-0.22 )
"
DEPEND="${RDEPEND}
	${VALA_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	dev-libs/libxslt
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/gnome-contacts/commit/c5eee38cd2556403a640a0a4c11d36cbf9a5a798
	"${FILESDIR}"/${PN}-3.33.4-window-disambiguate-gtk-headerbar.patch
)

src_prepare() {
	xdg_src_prepare
	vala_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use v4l cheese)
		$(meson_use telepathy)
		-Dmanpage=true
		-Ddocs=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	# Do not install files owned by libhandy
	rm -f "${ED}"/usr/include/libhandy-*/handy.h
	rm -f "${ED}"/usr/include/libhandy-*/hdy-*.h
	rm -f "${ED}"/usr/lib*/girepository-1.0/Handy-*typelib
	rm -f "${ED}"/usr/lib*/libhandy-*.so
	rm -f "${ED}"/usr/lib*/libhandy-*.so.0
	rm -f "${ED}"/usr/lib*/pkgconfig/libhandy-*.pc
	rm -f "${ED}"/usr/share/gir-1.0/Handy-0.0.gir
	rm -f "${ED}"/usr/share/vala/vapi/libhandy-*.deps
	rm -f "${ED}"/usr/share/vala/vapi/libhandy-*.vapi
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
