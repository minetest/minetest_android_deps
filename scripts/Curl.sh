#!/bin/bash -e
mbedtls_ver=2.26.0
curl_ver=7.79.1

download () {
	get_tar_archive mbedtls "https://github.com/ARMmbed/mbedtls/archive/mbedtls-${mbedtls_ver}.tar.gz"
	get_tar_archive curl "https://curl.se/download/curl-${curl_ver}.tar.gz"
}

build () {
	# Build mbedtls first
	mkdir -p mbedtls
	local mbedtls=$PWD/mbedtls
	pushd $srcdir/mbedtls
	make -s clean # necessary
	make library
	make DESTDIR=$mbedtls install
	popd

	$srcdir/curl/configure --host=$CROSS_PREFIX \
		--with-mbedtls="$mbedtls" \
		--disable-shared --enable-static --disable-{debug,verbose} \
		--disable-{proxy,cookies,crypto-auth,manual,ares,ftp,unix-sockets} \
		--disable-{ldap,rtsp,dict,telnet,tftp,pop3,imap,smtp,gopher,mqtt}
	make
	make_install_copy

	# For mbedtls install only the libraries
	cp $mbedtls/lib/*.a $pkgdir/
}
