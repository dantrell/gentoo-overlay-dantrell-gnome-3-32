# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org meson xdg

DESCRIPTION="Font viewer utility for GNOME"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-font-viewer"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE=""

RDEPEND="
	>=dev-libs/glib-2.35.1:2
	>=x11-libs/gtk+-3.20:3
	>=media-libs/harfbuzz-0.9.9
	media-libs/fontconfig:1.0
	media-libs/freetype:2
	gnome-base/gnome-desktop:3=
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"
