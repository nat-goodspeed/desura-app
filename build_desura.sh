#!/bin/bash
echo 'Make sure to run \033[1;31msudo ./install_deps.sh\033[0m before compiling!\n'

PREFIX="../install"
OFFICIAL_BUILD=OFF

# any error should terminate the script
set -e

clean() {
	rm -rf build
	rm -rf build_cef
	rm -rf install
	rm -rf build_package
	echo 'Cleaned'
}

build_desura() {
	if [ ! -d "build" ]; then
		mkdir build
	fi
	cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_CEF=OFF -DWITH_GTEST=OFF -DOFFICIAL_BUILD=$OFFICIAL_BUILD \
		-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON
	make install "$@"
	cd ..
	echo 'Building Desura completed'
}

build_cef() {
	if [ ! -d "build_cef" ]; then
		mkdir build_cef
	fi
	cd build_cef
	cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_ONLY_CEF=ON
	make install "$@"
	cd ..
	echo 'Building CEF completed'
}

pack() {
	if [ ! -d "build_package" ]; then
		mkdir build_package
	fi
	cd build_package
	cmake .. -DPACKAGE_TYPE=$PACKAGE -DINSTALL_DESKTOP_FILE=ON -DCMAKE_INSTALL_PREFIX="/opt/desura" -DDESKTOP_EXE="/opt/desura/desura" -DDESKTOP_ICON="/opt/desura/desura.png"
	make package "$@"
	if [ $PACKAGE = "DEB" ]; then
		mv Desura-*.deb ..
	elif [ $PACKAGE = "RPM" ]; then
		mv Desura-*.rpm ..
	fi
	echo 'Building $PACKAGE completed'
	cd ..
}

if [ -z "$1" ]; then
	clean
	build_desura "$@"
	build_cef
elif [ "$1" = "pack" ]; then
	shift
	PACKAGE="$1"
	shift
	clean
	pack "$@"
elif [ "$1" = "only_desura" ]; then
	shift
	clean
	build_desura "$@"
elif [ "$1" = "only_cef" ]; then
	shift
	clean
	build_cef "$@"
elif [ "$1" = "help" ]; then
	echo 'This script will allow you to easy compile Desura on Linux.'
	echo 'Type "./build_desura.sh clean" to remove build files.'
	echo 'Type "./build_desura.sh" to build Desura client.'
	echo 'Type "./build_desura.sh pack DEB" to prepare .deb package.'
	echo 'Type "./build_desura.sh pack RPM" to prepare .rpm package.'
	echo 'Type "./build_desura.sh only_desura" to compile Desura without CEF (Chromium Embedded Framework).'
	echo 'Type "./build_desura.sh only_cef" to compile CEF without Desura.'
	echo 'Type "./build_desura.sh help" to display this message.'
	echo 'Any additional shell arguments will be given to "make" command.\n'
elif declare -fF "$1" >/dev/null ; then
	# declare -fF name tests for existence of shell function --
	# in other words, is $1 the name of one of our functions above?
	fn="$1"
	shift
	"$fn" "$@"
else
	echo "Unrecognized command '$1'"
	exit 1
fi

echo 'Run \033[1;31m./install/desura\033[0m to start Desura!'
