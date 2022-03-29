# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 pax-utils virtualx

DESCRIPTION="Javascript bindings for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/Gjs"

LICENSE="MIT || ( MPL-1.1 LGPL-2+ GPL-2+ )"
SLOT="0"
KEYWORDS="*"

IUSE="+cairo examples gtk readline test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/glib-2.54.0
	>=dev-libs/gobject-introspection-1.57.2:=

	readline? ( sys-libs/readline:0= )
	dev-lang/spidermonkey:60=
	dev-libs/libffi:=
	cairo? ( x11-libs/cairo[X] )
	gtk? ( >=x11-libs/gtk+-3.20:3 )
"
DEPEND="${RDEPEND}
	gnome-base/gnome-common
	sys-devel/gettext
	virtual/pkgconfig
	test? ( sys-apps/dbus )
"

src_configure() {
	# Code Coverage support is completely useless for portage installs
	gnome2_src_configure \
		--disable-systemtap \
		--disable-dtrace \
		--enable-profiler \
		--disable-code-coverage \
		$(use_with cairo cairo) \
		$(use_with gtk) \
		$(use_enable readline) \
		$(use_with test dbus-tests) \
		--disable-installed-tests \
		--without-xvfb-tests # disables Makefile spawning Xvfb for us, as we do it ourselves:
		# https://gitlab.gnome.org/GNOME/gjs/issues/280
}

src_install() {
	# Installation sometimes fails in parallel
	gnome2_src_install -j1

	if use examples; then
		dodoc -r examples
	fi

	# Required for gjs-console to run correctly on PaX systems
	pax-mark mr "${ED}/usr/bin/gjs-console"
}

src_test() {
	virtx dbus-run-session emake check
}
