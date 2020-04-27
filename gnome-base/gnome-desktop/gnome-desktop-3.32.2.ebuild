# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson virtualx

DESCRIPTION="Library with common API for various GNOME modules"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-desktop"

LICENSE="GPL-2+ FDL-1.1+ LGPL-2+"
SLOT="3/17" # subslot = libgnome-desktop-3 soname version
KEYWORDS="*"

IUSE="debug doc gtk-doc +introspection udev vanilla-thumbnailer"

# cairo[X] needed for gnome-bg
COMMON_DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.53.0:2
	>=x11-libs/gdk-pixbuf-2.36.5:2[introspection?]
	>=x11-libs/gtk+-3.3.6:3[X,introspection?]
	x11-libs/cairo:=[X]
	x11-libs/libX11
	x11-misc/xkeyboard-config
	>=gnome-base/gsettings-desktop-schemas-3.27.0
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
	vanilla-thumbnailer? ( sys-libs/libseccomp )
	udev? (
		sys-apps/hwids
		virtual/libudev:= )
"
RDEPEND="${COMMON_DEPEND}
	vanilla-thumbnailer? ( sys-apps/bubblewrap )
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.14
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	x11-base/xorg-proto
	virtual/pkgconfig
	media-libs/fontconfig
"

src_prepare() {
	if ! use vanilla-thumbnailer; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-desktop/commit/8b1db18aa75c2684b513481088b4e289b5c8ed92
		eapply "${FILESDIR}"/${PN}-3.32.1.2-dont-sandbox-thumbnailers-on-linux.patch
	fi

	gnome2_src_prepare
}

src_configure() {
	local emesonargs=(
		-D gnome_distributor=Gentoo
		$(meson_use doc desktop_docs)
		$(meson_use debug debug_tools)
		$(meson_feature udev udev)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use debug installed_tests)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}
