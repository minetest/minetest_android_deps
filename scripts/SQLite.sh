#!/bin/bash -e
ver=3450100

download () {
	get_tar_archive sqlite-autoconf "https://www.sqlite.org/2024/sqlite-autoconf-${ver}.tar.gz"
}

build () {
	$srcdir/sqlite-autoconf/configure --host=$CROSS_PREFIX \
		--disable-shared --enable-static \
		--disable-fts{3,4,5} --disable-rtree
	# strerror_r build issue
	sed -re '/^#if.*STRERROR_R_CHAR_P/ s|.+|#if 0|g' -i $srcdir/sqlite-autoconf/sqlite3.c
	make

	make_install_copy
}
