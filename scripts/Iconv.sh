#!/bin/bash -e
ver=1.16

download () {
	get_tar_archive libiconv "https://ftp.gnu.org/gnu/libiconv/libiconv-${ver}.tar.gz"
}

build () {
	$srcdir/libiconv/configure --host=$CROSS_PREFIX \
		--disable-shared --enable-static

	make_install_copy
}
