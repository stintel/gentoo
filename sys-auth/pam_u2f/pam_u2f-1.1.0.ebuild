# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic pam

DESCRIPTION="PAM module for FIDO2 and U2F keys"
HOMEPAGE="https://github.com/Yubico/pam-u2f"
SRC_URI="https://developers.yubico.com/${PN/_/-}/Releases/${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug libressl"

RDEPEND="
	dev-libs/libfido2:0=
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	sys-libs/pam"

BDEPEND="virtual/pkgconfig"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${PN}-1.0.2-fix-Makefile.patch" )

src_prepare() {
	default
	use debug || append-cppflags -UDEBUG_PAM -UPAM_DEBUG
	eautoreconf
}

src_configure() {
	econf --with-pam-dir=$(getpam_mod_dir)
}
