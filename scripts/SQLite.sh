#!/bin/bash -e
ver=3360000

download () {
	get_tar_archive sqlite-autoconf "https://sqlite.org/2021/sqlite-autoconf-${ver}.tar.gz"
}

build () {
	$srcdir/sqlite-autoconf/configure --host=$CROSS_PREFIX \
		--disable-shared --enable-static \
		--disable-fts{3,4,5} --disable-json1 --disable-rtree
	make

	make_install_copy
}
