#!/bin/bash -e

# Some helpers for use by the scripts
get_tar_archive () {
	# $1: folder to extract to, $2: URL
	local filename="${2##*/}"
	[ -d "$1" ] && return 0
	wget -c "$2" -O "$filename"
	mkdir -p "$1"
	tar -xaf "$filename" -C "$1" --strip-components=1
	rm "$filename"
}

make_install_copy () {
	make DESTDIR=$PWD install
	mv usr/local/lib/*.a $pkgdir/
	if [ -d $pkgdir/include ]; then
		cp -a usr/local/include $pkgdir/
	else
		mv usr/local/include $pkgdir/
	fi
}

# Actual code used here
_setup_toolchain () {
	local toolchain=$(echo "$ANDROID_NDK"/toolchains/llvm/prebuilt/*)
	if [ ! -d "$toolchain" ]; then
		echo "Android NDK path not specified or incorrect"; return 1
	fi
	export PATH="$toolchain/bin:$ANDROID_NDK:$PATH"

	unset CFLAGS CPPFLAGS CXXFLAGS

	TARGET_ABI="$1"
	if [ "$TARGET_ABI" == armeabi-v7a ]; then
		API=16
		CROSS_PREFIX=arm-linux-androideabi
		export CC=armv7a-linux-androideabi$API-clang
		export CXX=armv7a-linux-androideabi$API-clang++
		CFLAGS="-mthumb"
		CXXFLAGS="-mthumb"
	elif [ "$TARGET_ABI" == arm64-v8a ]; then
		API=21
		CROSS_PREFIX=aarch64-linux-android
		export CC=$CROSS_PREFIX$API-clang
		export CXX=$CROSS_PREFIX$API-clang++
	elif [ "$TARGET_ABI" == x86 ]; then
		API=16
		CROSS_PREFIX=i686-linux-android
		export CC=$CROSS_PREFIX$API-clang
		export CXX=$CROSS_PREFIX$API-clang++
		CFLAGS="-mssse3 -mfpmath=sse"
		CXXFLAGS="-mssse3 -mfpmath=sse"
	else
		echo "Invalid ABI given"; return 1
	fi
	export CFLAGS="-fPIC ${CFLAGS}"
	export CXXFLAGS="-fPIC ${CXXFLAGS}"

	CMAKE_FLAGS=(
		"-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake"
		"-DANDROID_ABI=$TARGET_ABI" "-DANDROID_NATIVE_API_LEVEL=$API"
		"-DCMAKE_BUILD_TYPE=Release"
	)

	# make sure pkg-config doesn't interfere
	export PKG_CONFIG=/bin/false

	export MAKEFLAGS="-j$(nproc)"
}

_run_build () {
	local script=./scripts/$1.sh
	if [ ! -e "$script" ]; then
		echo "Specified target does not exist"; return 1
	fi
	source "$script"

	mkdir -p src
	pushd src >/dev/null
	srcdir=$PWD
	download
	popd >/dev/null

	builddir=$PWD/build/$1-$2
	pkgdir=$PWD/deps/$2/$1
	rm -rf "$pkgdir"
	mkdir -p "$builddir" "$pkgdir"

	pushd "$builddir" >/dev/null
	build
	popd >/dev/null
}

if [ $# -lt 2 ]; then
	echo "Usage: build.sh <target> <ABI>"
	exit 1
fi

_setup_toolchain "$2"

if [ "$1" == "--all" ]; then
	for name in scripts/*.sh; do
		name=${name#*/}
		( _run_build "${name%.*}" "$2" )
	done
	echo "Full build for ABI $2 successful."
else
	_run_build "$1" "$2"
	echo "Build of $1 for ABI $2 successful."
fi

exit 0
