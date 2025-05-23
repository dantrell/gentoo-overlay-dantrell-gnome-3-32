# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_10,3_11,3_12,3_13} )

inherit gnome.org gnome2-utils meson python-single-r1 xdg

DESCRIPTION="An API documentation browser for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Devhelp"

LICENSE="GPL-3+"
SLOT="0/3-6" # subslot = 3-(libdevhelp-3 soname version)
KEYWORDS="*"

IUSE="gedit gtk-doc +introspection"
REQUIRED_USE="gedit? ( ${PYTHON_REQUIRED_USE} )"

COMMON_DEPEND="
	>=dev-libs/glib-2.56:2
	>=x11-libs/gtk+-3.22:3[introspection?]
	>=net-libs/webkit-gtk-2.20:4[introspection?]
	>=gui-libs/amtk-5.0:5
	gnome-base/gsettings-desktop-schemas
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
"
RDEPEND="${COMMON_DEPEND}
	gedit? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			app-editors/gedit[introspection,python,${PYTHON_SINGLE_USEDEP}]
			dev-python/pygobject:3[${PYTHON_USEDEP}]
		')
	)
"
# libxml2 required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	dev-libs/libxml2:2
	dev-util/itstool
	gtk-doc? (
		>=dev-util/gtk-doc-1.25
		app-text/docbook-xml-dtd:4.3 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.30.1-optional-introspection.patch
	"${FILESDIR}"/${PN}-3.30.1-optional-gedit.patch
)

pkg_setup() {
	use gedit && python-single-r1_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Dflatpak_build=false
		$(meson_use gedit gedit_plugin)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	use gedit && python_optimize "${ED%/}"/usr/$(get_libdir)/gedit/plugins
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
