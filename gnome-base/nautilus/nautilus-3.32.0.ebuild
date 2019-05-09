# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome.org gnome2-utils meson readme.gentoo-r1 virtualx xdg

DESCRIPTION="Default file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-3+ LGPL-2.1+"
SLOT="0"
KEYWORDS="*"

IUSE="gnome gtk-doc +introspection packagekit +previewer selinux sendto vanilla-menu vanilla-menu-compress vanilla-rename vanilla-search vanilla-thumbnailer"

COMMON_DEPEND="
	>=dev-libs/glib-2.55.1:2
	>=media-libs/gexiv2-0.10.0
	>=app-arch/gnome-autoar-0.2.1
	gnome-base/gsettings-desktop-schemas
	>=x11-libs/gtk+-3.22.27:3[X,introspection?]
	!vanilla-thumbnailer? ( >=gnome-base/gnome-desktop-3:3= )
	vanilla-thumbnailer? ( sys-libs/libseccomp )
	>=x11-libs/pango-1.28.3
	selinux? ( >=sys-libs/libselinux-2.0 )
	>=app-misc/tracker-2.0:=
	x11-libs/libX11
	>=dev-libs/libxml2-2.7.8:2
	introspection? ( >=dev-libs/gobject-introspection-1.54:= )
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/gdbus-codegen-2.51.2
	gtk-doc? (
		>=dev-util/gtk-doc-1.10
		app-text/docbook-xml-dtd:4.1.2 )
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
"
RDEPEND="${COMMON_DEPEND}
	packagekit? ( app-admin/packagekit-base )
	vanilla-thumbnailer? ( >=sys-apps/bubblewrap-0.3.1 )
	sendto? ( !<gnome-extra/nautilus-sendto-3.0.1 )
"
PDEPEND="
	gnome? ( x11-themes/adwaita-icon-theme )
	previewer? ( >=gnome-extra/sushi-0.1.9 )
	sendto? ( >=gnome-extra/nautilus-sendto-3.0.1 )
	>=gnome-base/gvfs-1.14[gtk(+)]
	>=media-video/totem-3.26[vanilla-thumbnailer=]
	!vanilla-thumbnailer? ( media-video/ffmpegthumbnailer )
" # Need gvfs[gtk] for recent:/// support; always built (without USE=gtk) since gvfs-1.34

PATCHES=(
	"${FILESDIR}"/${PN}-3.30.5-docs-build.patch # Always install pregenerated manpage, keeping docs option for gtk-doc
)

src_prepare() {
	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi

	# Don't treat warnings as errors
	sed -e 's/-Werror=/-W/' -i meson.build || die "sed failed"

	if ! use vanilla-menu; then
		if ! use vanilla-menu-compress; then
			eapply "${FILESDIR}"/${PN}-3.30.0-use-old-compress-extension.patch
			eapply "${FILESDIR}"/${PN}-3.30.0-reorder-context-menu-rebased.patch
		else
			eapply "${FILESDIR}"/${PN}-3.30.0-reorder-context-menu.patch
		fi
	elif ! use vanilla-menu-compress; then
		eapply "${FILESDIR}"/${PN}-3.30.0-use-old-compress-extension.patch
	fi

	if ! use vanilla-rename; then
		eapply "${FILESDIR}"/${PN}-3.32.0-support-slow-double-click-to-rename.patch
	fi

	if ! use vanilla-search; then
		# From Dr. Amr Osman:
		# 	https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/1164016/comments/31
		eapply "${FILESDIR}"/${PN}-3.32.0-support-alternative-search.patch
	fi

	if ! use vanilla-thumbnailer; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/gnome-desktop/commit/8b1db18aa75c2684b513481088b4e289b5c8ed92
		# 	https://gitlab.gnome.org/GNOME/nautilus/commit/673c81cf9f1d68b71041220e6e44624dee44dbfc
		eapply "${FILESDIR}"/${PN}-3.32.0-dont-sandbox-thumbnailers-on-linux.patch
	fi

	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc docs)
		$(meson_use sendto extensions) # image file properties, sendto support
		$(meson_use introspection)
		$(meson_use packagekit)
		$(meson_use selinux)
		-Dprofiling=false
		-Dtests=$(usex test all none)
	)
	meson_src_configure
}

src_install() {
	use previewer && readme.gentoo_create_doc
	meson_src_install
}

src_test() {
	virtx meson_src_test
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
