# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome2 meson virtualx

DESCRIPTION="GNOME 3 compositing window manager based on Clutter"
HOMEPAGE="https://gitlab.gnome.org/GNOME/mutter/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

IUSE="ck debug deprecated-background elogind input_devices_wacom +introspection screencast systemd test +udev +vanilla-mipmapping wayland"
REQUIRED_USE="
	?? ( ck elogind systemd )
	wayland? ( udev || ( elogind systemd ) )
"

# libXi-1.7.4 or newer needed per:
# https://bugzilla.gnome.org/show_bug.cgi?id=738944
RDEPEND="
	>=dev-libs/atk-2.5.3
	>=x11-libs/gdk-pixbuf-2:2
	>=dev-libs/json-glib-0.12.0
	>=x11-libs/pango-1.30[introspection?]
	>=x11-libs/cairo-1.14[X]
	>=x11-libs/gtk+-3.19.8:3[X,introspection?]
	>=dev-libs/glib-2.53.4:2[dbus]
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2
	>=gnome-base/gsettings-desktop-schemas-3.21.4[introspection?]
	gnome-base/gnome-desktop:3=
	>sys-power/upower-0.99:=

	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.4
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	>=x11-libs/libXfixes-3
	>=x11-libs/libXi-1.7.4
	x11-libs/libXinerama
	>=x11-libs/libXrandr-1.5
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbfile
	>=x11-libs/libxkbcommon-0.4.3[X]
	x11-misc/xkeyboard-config

	gnome-extra/zenity
	>=media-libs/mesa-17.2.0[X(+),egl]

	input_devices_wacom? ( >=dev-libs/libwacom-0.13 )
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
	udev? ( >=dev-libs/libgudev-232:= )
	screencast? ( >=media-video/pipewire-0.2.2:0/0.2 )
	wayland? (
		>=dev-libs/libinput-1.4
		>=dev-libs/wayland-1.13.0
		>=dev-libs/wayland-protocols-1.16
		>=media-libs/mesa-10.3[egl,gbm,wayland,gles2]
		|| ( sys-auth/elogind sys-apps/systemd )
		>=dev-libs/libgudev-232:=
		>=virtual/libudev-136:=
		x11-base/xorg-server[wayland]
		x11-libs/libdrm:=
	)
	media-video/pipewire
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
	x11-base/xorg-proto
	test? ( app-text/docbook-xml-dtd:4.5 )
	wayland? ( >=sys-kernel/linux-headers-4.4 )
"

src_prepare() {
	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/mutter/commit/d3dc7d6f493f820a67c9c40a50ebc544a0d50331
	eapply "${FILESDIR}"/${PN}-3.32.0-support-eudev.patch

	if use deprecated-background; then
		eapply "${FILESDIR}"/${PN}-3.26.1-restore-deprecated-background-code.patch
	fi

	# From GNOME:
	# 	https://gitlab.gnome.org/GNOME/mutter/merge_requests/89
	if ! use vanilla-mipmapping; then
		eapply "${FILESDIR}"/${PN}-3.32.0-metashapedtexture-disable-mipmapping-emulation.patch
	fi

	eapply "${FILESDIR}"/${PN}-3.32.2-eglmesaext-include.patch

	gnome2_src_prepare
}

src_configure() {
	sed -i "/'-Werror=redundant-decls',/d" "${S}"/meson.build || die "sed failed"

	local emesonargs=(
		-D opengl=true
		$(meson_use wayland gles2)
		-D egl=true
		-D glx=true
		$(meson_use wayland)
		$(meson_use wayland native_backend)
		$(meson_use screencast remote_desktop)
		$(meson_use wayland egl_device)
		-D wayland_eglstream=false
		$(meson_use udev)
		$(meson_use input_devices_wacom libwacom)
		-D pango_ft2=true
		-D startup_notification=true
		-D sm=true
		$(meson_use introspection)
		$(meson_use test cogl_tests)
		$(meson_use test clutter_tests)
		$(meson_use test tests)
		$(meson_use test installed_tests)
	)

	meson_src_configure
}

src_test() {
	virtx meson_src_test
}
