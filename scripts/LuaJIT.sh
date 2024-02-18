#!/bin/bash -e

repo=https://luajit.org/git/luajit.git
rev=0d313b243194a0b8d2399d8b549ca5a0ff234db5

download () {
	if [ ! -d LuaJIT/.git ]; then
		rm -rf LuaJIT
		git clone $repo LuaJIT
		pushd LuaJIT
		git checkout $rev
		popd
	fi
}

build () {
	# Figure out needed host compiler
	local hostcc="cc -m32"
	if [[ "$TARGET_ABI" == "arm64-"* || "$TARGET_ABI" == x86_64 ]]; then
		hostcc="cc -m64"
	fi

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
