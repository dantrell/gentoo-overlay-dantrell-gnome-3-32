# Distributed under the terms of the GNU General Public License v2

EAPI="6"
PYTHON_COMPAT=( python{3_4,3_5,3_6,3_7} )
VALA_USE_DEPEND="vapigen"

inherit gnome2 meson multilib-minimal python-any-r1 vala

DESCRIPTION="An HTTP library implementation in C"
HOMEPAGE="https://wiki.gnome.org/Projects/libsoup"

LICENSE="LGPL-2+"
SLOT="2.4"
KEYWORDS="*"

IUSE="doc gnome gssapi +introspection samba ssl test vala"
REQUIRED_USE="vala? ( introspection )"

RDEPEND="
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4:2[${MULTILIB_USEDEP}]
	>=dev-db/sqlite-3.8.2:3[${MULTILIB_USEDEP}]
	>=net-libs/libpsl-0.20.0[${MULTILIB_USEDEP}]
	>=net-libs/glib-networking-2.38.2[ssl?,${MULTILIB_USEDEP}]
	gssapi? ( virtual/krb5[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
	samba? ( net-fs/samba )
"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	>=dev-util/gtk-doc-am-1.20
	>=dev-util/intltool-0.35
	sys-devel/gettext
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.40:2[${MULTILIB_USEDEP}]
	vala? ( $(vala_depend) )
"

src_prepare() {
	use vala && vala_src_prepare
	gnome2_src_prepare
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_use gssapi)
		$(meson_use samba ntlm)
		$(usex samba -Dntlm_auth="'${EPREFIX}/usr/bin/ntlm_auth'" "")
		$(meson_use gnome)
		$(meson_use doc)
		$(meson_use test tests)
	)
	if multilib_is_native_abi; then
		emesonargs+=(
			$(meson_use introspection)
			$(meson_use vala vapi)
		)
	else
		emesonargs+=(
			-Dintrospection=false
			-Dvapi=false
		)
	fi
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}
