#!/bin/bash

if [[ "${1}" != "skip" ]] ; then
	./build_clean.sh
	./build_kernel.sh "$@" || exit 1
fi

VERSION="$(cat version)"

if [ -e arch/arm64/boot/Image.gz ] ; then
	echo "Packing Kernel Pkg"

	[ -f Mawrol-kernel-$VERSION.zip ] && echo "Removing Exist Pkg"
	[ -f Mawrol-kernel-$VERSION.zip ] && rm Mawrol-kernel-$VERSION.zip 2>/dev/null

	# Pack AnyKernel3
	rm -rf kernelzip
	mkdir kernelzip
	echo "
kernel.string=Mawrol kernel $(cat version) @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus7
device.name2=OnePlus7Pro
device.name3=OnePlus7T
device.name4=OnePlus7TPro
device.name5=guacamoleb
device.name6=guacamole
device.name7=hotdogb
device.name8=hotdog
block=/dev/block/bootdevice/by-name/boot
is_slot_device=1
ramdisk_compression=gzip
" > kernelzip/props
	cp -rp ~/android/anykernel/* kernelzip/
	find arch/arm64/boot/dts -name '*.dtb' -exec cat {} + > kernelzip/dtb
	cd kernelzip/
	7z a -mx9 Mawrol-kernel-$VERSION-tmp.zip *
	7z a -mx0 Mawrol-kernel-$VERSION-tmp.zip ../arch/arm64/boot/Image.gz
	zipalign -v 4 Mawrol-kernel-$VERSION-tmp.zip ../Mawrol-kernel-$VERSION.zip
	rm Mawrol-kernel-$VERSION-tmp.zip
	cd ..
	ls -al Mawrol-kernel-$VERSION.zip
fi

