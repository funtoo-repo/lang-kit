# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Embeddable Javascript engine"
HOMEPAGE="https://duktape.org"
SRC_URI="https://github.com/svaarala/duktape/releases/download/v2.7.0/duktape-2.7.0.tar.xz -> duktape-2.7.0.tar.xz"

LICENSE="MIT"
# Upstream don't maintain binary compatibility
# https://github.com/svaarala/duktape/issues/1524
SLOT="0/${PV}"
KEYWORDS="*"

src_prepare() {
	default

	# Set install path
	sed -i "s#INSTALL_PREFIX ?= /usr/local#INSTALL_PREFIX ?= ${ED}/usr#" \
			Makefile.sharedlibrary || die "failed to set install path"

	# Edit pkgconfig
	sed "s#VERSION#${PV}#" "${FILESDIR}/${PN}.pc" > "${S}/${PN}.pc" || die
	sed -i "s#LIBDIR#$(get_libdir)#" "${S}/${PN}.pc" || die

	# Set lib folder
	sed -i "s#LIBDIR ?= /lib#LIBDIR ?= /$(get_libdir)#" \
		Makefile.sharedlibrary || die "failed to set lib path"

	mv Makefile.sharedlibrary Makefile || die "failed to rename makefile"
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	dodir /usr/$(get_libdir)
	dodir /usr/include
	emake install

	insinto /usr/$(get_libdir)/pkgconfig/
	doins "${S}/${PN}.pc"
}