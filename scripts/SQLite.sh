#!/bin/bash -e
ver=3430200

download () {
	get_tar_archive sqlite-autoconf "https://www.sqlite.org/2023/sqlite-autoconf-${ver}.tar.gz"
}

build () {
	$srcdir/sqlite-autoconf/configure --host=$CROSS_PREFIX \
		--disable-shared --enable-static \
		--disable-fts{3,4,5} --disable-json1 --disable-rtree
	make

	make_install_copy
}
