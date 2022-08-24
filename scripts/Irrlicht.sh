#!/bin/bash -e
irrlicht_ver=1.9.0mt7
png_ver=1.6.37
jpeg_ver=2.1.3

download () {
	[ -d irrlicht ] || git clone https://github.com/minetest/irrlicht -b $irrlicht_ver irrlicht
	get_tar_archive libpng "https://download.sourceforge.net/libpng/libpng-${png_ver}.tar.gz"
	get_tar_archive libjpeg "https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${jpeg_ver}.tar.gz"
}

build () {
	# Build libjpg and libpng first because Irrlicht needs them
	mkdir -p libpng
	pushd libpng
	$srcdir/libpng/configure --host=$CROSS_PREFIX
	make && make DESTDIR=$PWD install
	popd

	mkdir -p libjpeg
	pushd libjpeg
	cmake $srcdir/libjpeg "${CMAKE_FLAGS[@]}"
	make && make DESTDIR=$PWD install
	popd

	local libpng=$PWD/libpng/usr/local/lib/libpng.a
	local libjpeg=$(echo $PWD/libjpeg/opt/libjpeg-turbo/lib*/libjpeg.a)
	cmake $srcdir/irrlicht "${CMAKE_FLAGS[@]}" \
		-DBUILD_SHARED_LIBS=OFF \
		-DPNG_LIBRARY=$libpng \
		-DPNG_PNG_INCLUDE_DIR=$(dirname "$libpng")/../include \
		-DJPEG_LIBRARY=$libjpeg \
		-DJPEG_INCLUDE_DIR=$(dirname "$libjpeg")/../include
	make

	cp -p lib/Android/libIrrlichtMt.a $libpng $libjpeg $pkgdir/
	cp -a $srcdir/irrlicht/include $pkgdir/include
	cp -a $srcdir/irrlicht/media/Shaders $pkgdir/Shaders
}
