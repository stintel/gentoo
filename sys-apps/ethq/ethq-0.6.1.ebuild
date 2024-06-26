# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV=${PV//./_}
MY_P=${PN}-${MY_PV}

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Ethernet NIC Queue stats viewer"
HOMEPAGE="https://github.com/isc-projects/ethq"
SRC_URI="https://github.com/isc-projects/ethq/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="sys-libs/ncurses:="
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	# Respect FLAGS, remove Werror
	sed -i  -e '/CXXFLAGS/s/= -O3/+=/' \
		-e '/CXXFLAGS/s/ -Werror//' \
		-e '/LDFLAGS/s/=/+=/' Makefile || die "sed failed for Makefile"

	if ! use test ; then
		sed -i '/TARGETS/s/ethq_test//' Makefile \
			|| die "sed failed for USE flag test"
	fi
}

src_configure() {
	# https://github.com/isc-projects/ethq/issues/30 (bug #879893)
	filter-lto

	default
}

src_compile() {
	# override for ncurses[tinfo]
	emake CXX="$(tc-getCXX)" LIBS_CURSES="$($(tc-getPKG_CONFIG) --libs ncurses)"
}

src_test() {
	local driver
	for driver in tests/* ; do
		"${S}"/ethq_test "${driver##*/}" "${driver}" \
			|| die "test failed on ${driver}"
	done
}

src_install() {
	einstalldocs
	dobin ethq
}
