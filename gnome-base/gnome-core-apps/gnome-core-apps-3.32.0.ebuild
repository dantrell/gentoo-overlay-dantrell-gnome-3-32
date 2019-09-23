# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eapi7-ver

DESCRIPTION="Sub-meta package for the core applications integrated with GNOME 3"
HOMEPAGE="https://www.gnome.org/"

LICENSE="metapackage"
SLOT="3.0"
KEYWORDS="*"

IUSE="+bluetooth +cdr cups"

# Note to developers:
# This is a wrapper for the core apps tightly integrated with GNOME 3
RDEPEND="
	>=gnome-base/gnome-core-libs-${PV}[cups?]

	>=gnome-base/gnome-session-${PV}
	>=gnome-base/gnome-menus-${PV}
	>=gnome-base/gnome-settings-daemon-${PV}[cups?]
	>=gnome-base/gnome-control-center-${PV}[cups(+)?]

	>=app-crypt/gcr-3.28.0
	>=gnome-base/nautilus-${PV}
	>=gnome-base/gnome-keyring-3.31.91
	>=gnome-extra/evolution-data-server-${PV}

	>=app-crypt/seahorse-${PV}
	>=app-editors/gedit-${PV}
	>=app-text/evince-${PV}
	>=gnome-extra/gnome-contacts-$(ver_cut 1-2)
	>=media-gfx/eog-${PV}
	>=media-video/totem-${PV}
	>=x11-terms/gnome-terminal-${PV}

	>=gnome-extra/gnome-user-docs-${PV}
	>=gnome-extra/yelp-${PV}

	>=x11-themes/adwaita-icon-theme-$(ver_cut 1-2)
	>=x11-themes/gnome-themes-extra-3.28

	bluetooth? ( >=net-wireless/gnome-bluetooth-${PV} )
	cdr? ( >=app-cdr/brasero-3.12.2 )

	!gnome-base/gnome-applets
"
DEPEND=""

S="${WORKDIR}"
