#!/bin/bash
export KBUILD_BUILD_USER="root"
export KBUILD_BUILD_HOST="Rakesh"
export CROSS_COMPILE=/home/neuralos/rakhi/ndk/bin/aarch64-linux-gnu-
export ARCH=arm64
export SUBARCH=arm64
make clean && make mrproper
rm -rf anykernel/dt.img
#rm -rf ../anykernel/modules/wlan.ko
rm -rf anykernel/zImage
export USE_CCACHE=1
BUILD_START=$(date +"%s")
KERNEL_DIR=$PWD
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
blue='\033[0;34m' cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
echo "Starting"
make lineageos_tomato_defconfig
echo "Making"
make -j16
echo "Making dt.img"
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
echo "Done"
export IMAGE=$KERNEL_DIR/arch/arm64/boot/Image
if [[ ! -f "${IMAGE}" ]]; then
    echo -e "Build failed :P. Check errors!";
    break;
else
BUILD_END=$(date +"%s");
DIFF=$(($BUILD_END - $BUILD_START));
BUILD_TIME=$(date +"%Y%m%d");
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol";
echo "Movings Files"
cd anykernel
mv $KERNEL_DIR/arch/arm64/boot/Image zImage
mv $KERNEL_DIR/arch/arm64/boot/dt.img dt.img
#mv $KERNEL_DIR/drivers/staging/prima/wlan.ko modules/wlan.ko
echo "Making Zip"
zip -r Myonol-kernel-$BUILD_TIME *
cd ..
gdrive upload anykernel/Myonol-kernel-$BUILD_TIME.zip
rm -rf anykernel/Myonol-kernel-$BUILD_TIME.zip
#rm -rf anykernel/dt.img
#rm -rf anykernel/zImage
fi
make clean && make mrproper
