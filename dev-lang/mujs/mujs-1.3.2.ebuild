# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs

DESCRIPTION="An embeddable Javascript interpreter in C."
HOMEPAGE="https://mujs.com/"
SRC_URI="https://mujs.com/downloads/mujs-1.3.2.tar.xz -> mujs-1.3.2.tar.xz"

LICENSE="ISC"
# subslot matches SONAME
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND="sys-libs/readline:0="
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-1.1.1-flags.patch"
)

src_prepare() {
	default

	tc-export AR CC

	# library's ABI (and API) changes in ~each release:
	# diff 'usr/includemujs.h' across releases to validate
	append-cflags -fPIC -Wl,-soname=lib${PN}.so.${PV}
}

src_compile() {
	emake VERSION=${PV} prefix=/usr shared
}

src_install() {
	local myeconfargs=(
		DESTDIR="${ED}"
		install-shared
		libdir="/usr/$(get_libdir)"
		prefix="/usr"
		VERSION="${PV}"
		$(usex static-libs install-static '')
	)

	emake "${myeconfargs[@]}"

	mv -v "${ED}"/usr/$(get_libdir)/lib${PN}.so{,.${PV}} || die

	dosym lib${PN}.so.${PV} /usr/$(get_libdir)/lib${PN}.so
	dosym lib${PN}.so.${PV} /usr/$(get_libdir)/lib${PN}.so.${PV:0:1}
}