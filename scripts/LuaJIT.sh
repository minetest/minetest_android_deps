#!/bin/bash -e
ver=2.1.0-beta3

download () {
	get_tar_archive LuaJIT "https://luajit.org/download/LuaJIT-${ver}.tar.gz"
}

build () {
	# Figure out needed host compiler
	local hostcc="cc -m32"
	[[ "$TARGET_ABI" == "arm64-"* ]] && hostcc="cc -m64"

	cd $srcdir/LuaJIT/src
	local targetcc="$CC $CFLAGS"
	unset CC CXX CFLAGS CXXFLAGS
	make -s clean # necessary
	make amalg BUILDMODE=static \
		CROSS=${CROSS_PREFIX}- TARGET_AR="llvm-ar rc" TARGET_STRIP="true" \
		STATIC_CC="$targetcc" DYNAMIC_CC="$targetcc" TARGET_LD="$targetcc" \
		XCFLAGS="-DLUAJIT_DISABLE_FFI" HOST_CC="$hostcc"

	mkdir $pkgdir/include
	cp *.h $pkgdir/include/
	cp libluajit.a $pkgdir/
}
