# Distributed under the terms of the GNU General Public License v2

EAPI="7"
VALA_USE_DEPEND="vapigen"

inherit gnome.org meson multilib-minimal vala xdg

DESCRIPTION="HTTP client/server library for GNOME"
HOMEPAGE="https://wiki.gnome.org/Projects/libsoup"

LICENSE="LGPL-2.1+"
SLOT="2.4"
KEYWORDS="*"

IUSE="gssapi gtk-doc +introspection samba ssl test +vala"
REQUIRED_USE="vala? ( introspection )"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/glib-2.38:2[${MULTILIB_USEDEP}]
	>=dev-db/sqlite-3.8.2:3[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4:2[${MULTILIB_USEDEP}]
	>=net-libs/libpsl-0.20[${MULTILIB_USEDEP}]
	gssapi? ( virtual/krb5[${MULTILIB_USEDEP}] )
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
	samba? ( net-fs/samba )
"
RDEPEND="${DEPEND}
	>=net-libs/glib-networking-2.38.2[ssl?,${MULTILIB_USEDEP}]
"
BDEPEND="
	gtk-doc? ( >=dev-util/gtk-doc-1.20
		app-text/docbook-xml-dtd:4.1.2 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	vala? ( $(vala_depend) )
"
#	test? (	www-servers/apache[ssl,apache2_modules_auth_digest,apache2_modules_alias,apache2_modules_auth_basic,
#		apache2_modules_authn_file,apache2_modules_authz_host,apache2_modules_authz_user,apache2_modules_dir,
#		apache2_modules_mime,apache2_modules_proxy,apache2_modules_proxy_http,apache2_modules_proxy_connect]
#		dev-lang/php[apache2,xmlrpc]
#		net-misc/curl
#		net-libs/glib-networking[ssl])"

PATCHES=(
	# Disable apache tests until they are usable on Gentoo, bug #326957
	"${FILESDIR}"/disable-apache-tests.patch
)

src_prepare() {
	use vala && vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	# FIXME: we need addpredict to workaround bug #324779 until
	# root cause (bug #249496) is solved
	# But necessary while apache tests are disabled
	#addpredict /usr/share/snmp/mibs/.index

	multilib-minimal_src_configure
}

multilib_src_configure() {
	local emesonargs=(
		-Dgssapi=$(multilib_native_usex gssapi true false)
		-Dkrb5_config="${CHOST}-krb5-config"
		-Dntlm=$(multilib_native_usex samba true false)
		-Dntlm_auth="${EPREFIX}/usr/bin/ntlm_auth"
		-Dtls_check=false # disables check, we still rdep on glib-networking
		-Dgnome=false
		-Dintrospection=$(multilib_native_usex introspection true false)
		-Dvapi=$(multilib_native_usex vala true false)
		-Dgtk_doc=$(multilib_native_usex gtk-doc true false)
		$(meson_use test tests)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	meson_src_install
}
