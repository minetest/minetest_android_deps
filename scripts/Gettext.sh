#!/bin/bash -e
ver=0.22.3

download () {
	get_tar_archive gettext "https://ftp.gnu.org/pub/gnu/gettext/gettext-${ver}.tar.gz"
}

build () {
	$srcdir/gettext/gettext-runtime/configure --host=$CROSS_PREFIX \
		--enable-static --disable-shared
	make

	mkdir $pkgdir/include
	cp intl/libintl.h $pkgdir/include/
	cp intl/.libs/libintl.a $pkgdir/
}
