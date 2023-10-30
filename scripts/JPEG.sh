#!/bin/bash -e
jpeg_ver=3.0.0

download () {
	get_tar_archive libjpeg "https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
}

build () {
	cmake "${CMAKE_FLAGS[@]}" \
		-DCMAKE_INSTALL_PREFIX=/usr/local \
		-DENABLE_SHARED=OFF \
		-DWITH_TURBOJPEG=OFF \
		$srcdir/libjpeg
	make
	make_install_copy
}
