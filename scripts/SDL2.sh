#!/bin/bash -e
ver=2.30.1

download () {
	get_tar_archive sdl2 "https://github.com/libsdl-org/SDL/releases/download/release-${ver}/SDL2-${ver}.tar.gz"
}

build () {
	cmake $srcdir/sdl2 "${CMAKE_FLAGS[@]}" \
		-DSDL_SHARED=OFF \
		-DSDL_STATIC=ON \
		-DSDL_TEST=OFF \
		-DSDL2_DISABLE_SDL2MAIN=ON
	make

	make_install_copy
}
