# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6,3_7} )

inherit gnome2 meson python-any-r1 virtualx

DESCRIPTION="A weather application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Weather"

LICENSE="GPL-2+ LGPL-2+ MIT CC-BY-3.0 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="*"

IUSE="test"

RDEPEND="
	>=app-misc/geoclue-2.3.1:2.0
	>=dev-libs/gjs-1.39.91
	>=dev-libs/glib-2.32:2
	>=dev-libs/gobject-introspection-1.35.9:=
	>=dev-libs/libgweather-3.25.91:=
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/gtk+-3.11.4:3
"
# libxml2 required for glib-compile-resources
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	>=dev-util/intltool-0.26
	virtual/pkgconfig
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep 'dev-util/dogtail[${PYTHON_USEDEP}]') )
"

python_check_deps() {
	use test && has_version "dev-util/dogtail[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_test() {
	virtx dbus-run-session meson test -C "${BUILD_DIR}" || die 'tests failed'
}