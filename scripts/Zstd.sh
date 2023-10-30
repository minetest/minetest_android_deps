#!/bin/bash -e
ver=1.5.5

download () {
	get_tar_archive zstd "https://github.com/facebook/zstd/releases/download/v${ver}/zstd-${ver}.tar.gz"
}

build () {
	cmake $srcdir/zstd/build/cmake "${CMAKE_FLAGS[@]}" \
		-DZSTD_BUILD_{PROGRAMS,SHARED}=OFF
	make

	make_install_copy
}
