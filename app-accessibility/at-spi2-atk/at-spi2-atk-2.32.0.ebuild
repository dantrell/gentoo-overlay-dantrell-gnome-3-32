# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit flag-o-matic gnome.org meson multilib-minimal virtualx xdg

DESCRIPTION="Gtk module for bridging AT-SPI to Atk"
HOMEPAGE="https://wiki.gnome.org/Accessibility"

LICENSE="LGPL-2+"
SLOT="2"
KEYWORDS="*"

IUSE="test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=sys-apps/dbus-1.5[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.32:2[${MULTILIB_USEDEP}]
	>=dev-libs/atk-2.30.0[${MULTILIB_USEDEP}]
	>=app-accessibility/at-spi2-core-2.30.0[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( >=dev-libs/libxml2-2.9.1 )
"

multilib_src_configure() {
	# Work around -fno-common (GCC 10 default)
	append-flags -fcommon

	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	virtx dbus-run-session meson test -C "${BUILD_DIR}"
}

multilib_src_install() {
	meson_src_install
}
