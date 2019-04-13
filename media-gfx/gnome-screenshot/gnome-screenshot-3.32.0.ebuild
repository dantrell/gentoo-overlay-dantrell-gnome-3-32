# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson readme.gentoo-r1 xdg

DESCRIPTION="Screenshot utility for GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-screenshot"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE=""

# libcanberra 0.26-r2 is needed for gtk+:3 fixes
COMMON_DEPEND="
	x11-libs/libX11
	x11-libs/libXext
	>=dev-libs/glib-2.35.1:2[dbus]
	>=x11-libs/gtk+-3.0.3:3
	>=media-libs/libcanberra-0.26-r2[gtk3]
"
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gsettings-desktop-schemas-0.1.0
"
DEPEND="${COMMON_DEPEND}
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
"

DOC_CONTENTS="${P} saves screenshots in ~/Pictures/ and defaults to
	non-interactive mode when launched from a terminal. If you want to choose
	where to save the screenshot, run 'gnome-screenshot --interactive'"

src_install() {
	meson_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
	readme.gentoo_print_elog
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
