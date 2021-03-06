# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson

DESCRIPTION="Logic puzzle game for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Hitori"

LICENSE="GPL-3+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE=""

# gtk+-3.22 for build-time optional gtk_show_uri_on_window usage
RDEPEND="
	>=dev-libs/glib-2.32:2
	>=x11-libs/gtk+-3.22:3
	>=x11-libs/cairo-1.4
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"
