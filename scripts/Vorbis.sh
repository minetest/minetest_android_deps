#!/bin/bash -e
ogg_ver=1.3.5
vorbis_ver=1.3.7

download () {
	get_tar_archive libogg "http://downloads.xiph.org/releases/ogg/libogg-${ogg_ver}.tar.xz"
	get_tar_archive libvorbis "http://downloads.xiph.org/releases/vorbis/libvorbis-${ogg_ver}.tar.xz"

	# Remove a flag that breaks the x86 build, configure adds it without checking...
	sed 's|-mno-ieee-fp||g' -i libvorbis/configure
}

build () {
	# Build libogg first
	mkdir -p libogg
	pushd libogg
	$srcdir/libogg/configure --host=$CROSS_PREFIX
	make

	make_install_copy
	popd

	OGG_CFLAGS="-I$pkgdir/include" OGG_LIBS="-L$pkgdir -logg" \
	$srcdir/libvorbis/configure --host=$CROSS_PREFIX
	make

	make_install_copy
}
