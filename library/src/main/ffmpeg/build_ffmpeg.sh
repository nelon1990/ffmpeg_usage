#!/bin/bash

set -e

# Set NDK
fileLocalProperties="../../../../local.properties"
if [ -a "$fileLocalProperties" ]; then
    echo "file \"local.properties\" exited"
    while read line
    do
        if [[ ${line} == "ndk.dir="* ]]; then
            NDK=${line#*ndk.dir=}
            break
        else
            NDK=/opt/ndk/android-ndk-r13b/
        fi
    done < "$fileLocalProperties"
else
    NDK=/home/nelon/mine/android/ndk/android-ndk-r14b
fi

echo "set NDK=${NDK}"
if [ "${NDK}" = "" ] || [ ! -d ${NDK} ]; then
    echo "NDK variable not set or path to NDK is invalid, exiting..."
    exit 1
fi

export TARGET=$1
echo -e "\033[33m ---------------------BUILD ${TARGET}--------------------- \033[0m"

ARM_PLATFORM=${NDK}/platforms/android-9/arch-arm
ARM_PREBUILT=${NDK}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64

ARM64_PLATFORM=${NDK}/platforms/android-21/arch-arm64
ARM64_PREBUILT=${NDK}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64

X86_PLATFORM=${NDK}/platforms/android-9/arch-x86
X86_PREBUILT=${NDK}/toolchains/x86-4.9/prebuilt/linux-x86_64

X86_64_PLATFORM=${NDK}/platforms/android-21/arch-x86_64
X86_64_PREBUILT=${NDK}/toolchains/x86_64-4.9/prebuilt/linux-x86_64

MIPS_PLATFORM=${NDK}/platforms/android-9/arch-mips
MIPS_PREBUILT=${NDK}/toolchains/mipsel-linux-android-4.9/prebuilt/linux-x86_64


BUILD_DIR=`pwd`/build
if [ -a ${BUILD_DIR} ]; then
    rm -rf ${BUILD_DIR}
    echo "remove ${BUILD_DIR}"
fi

# ffmpeg版本
FFMPEG_VERSION="3.3.5"

if [ ! -e "ffmpeg-${FFMPEG_VERSION}.tar.bz2" ]; then
    echo "Downloading ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    curl -LO http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
else
    echo "using ffmpeg-${FFMPEG_VERSION}.tar.bz2"
fi

if [ -a "ffmpeg-${FFMPEG_VERSION}" ]; then
    rm -rf "`pwd`/ffmpeg-${FFMPEG_VERSION}"
    echo "remove `pwd`/ffmpeg-${FFMPEG_VERSION}"
fi

echo "unzip tar"
tar -xf ffmpeg-${FFMPEG_VERSION}.tar.bz2

for i in `find diffs -name "*.patch"`; do
    (cd ffmpeg-${FFMPEG_VERSION} && patch -p1 < ../$i)
done

for i in `find patches -name "*.patch"`; do
    (cd ffmpeg-${FFMPEG_VERSION}/libswscale && patch -R -p1 < ../../$i)
done


build_one() {
    if [ ${ARCH} == "arm" ]
    then
        PLATFORM=${ARM_PLATFORM}
        PREBUILT=${ARM_PREBUILT}
        HOST=arm-linux-androideabi
    #added by alexvas
    elif [ ${ARCH} == "arm64" ]
    then
        PLATFORM=${ARM64_PLATFORM}
        PREBUILT=${ARM64_PREBUILT}
        HOST=aarch64-linux-android
    elif [ ${ARCH} == "mips" ]
    then
        PLATFORM=${MIPS_PLATFORM}
        PREBUILT=${MIPS_PREBUILT}
        HOST=mipsel-linux-android
    #alexvas
    elif [ ${ARCH} == "x86_64" ]
    then
        PLATFORM=${X86_64_PLATFORM}
        PREBUILT=${X86_64_PREBUILT}
        HOST=x86_64-linux-android
    else
        PLATFORM=${X86_PLATFORM}
        PREBUILT=${X86_PREBUILT}
        HOST=i686-linux-android
    fi

    pushd ffmpeg-${FFMPEG_VERSION}
    echo
    echo "exec configure"
    ./configure --target-os=linux \
        --prefix=${BUILD_DIR}/${TARGET} \
        --incdir=${BUILD_DIR}/${TARGET}/include \
        --libdir=${BUILD_DIR}/${TARGET}/lib \
        --enable-cross-compile \
        --extra-libs="-lgcc" \
        --arch=${ARCH} \
        --cc=${PREBUILT}/bin/${HOST}-gcc \
        --cross-prefix=${PREBUILT}/bin/${HOST}- \
        --nm=${PREBUILT}/bin/${HOST}-nm \
        --sysroot=${PLATFORM}/ \
        --extra-cflags="$OPTIMIZE_CFLAGS" \
        --enable-shared \
        --enable-small \
        --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
        --disable-ffserver \
        --disable-doc \
        --enable-encoder=png \
        --enable-protocol=file,http,https,mmsh,mmst,pipe,rtmp,rtmps,rtmpt,rtmpts,rtp \
        --disable-debug \
        --disable-asm \
        ${ADDITIONAL_CONFIGURE_FLAG}

    make clean
    echo -e "\033[33m ---------------------BEGIN TO MAKE ${TARGET}--------------------- \033[0m"
    make -j4
    echo -e "\033[33m ---------------------BEGIN TO INSTALL ${TARGET}--------------------- \033[0m"
    make install

    ${PREBUILT}/bin/${HOST}-ar d libavcodec/libavcodec.a inverse.o
    popd

    # copy the binaries to jni
    if [ -a "${JNI_DIR}" ]; then
        rm -rf ${JNI_DIR}
    fi
    mkdir -p ${JNI_DIR}
    cp -r ${BUILD_DIR}/${TARGET}/* ${JNI_DIR}
    rm -rf ${JNI_DIR}/lib/*
    cp ${BUILD_DIR}/${TARGET}/lib/*.so ${JNI_DIR}/lib
    cp ${BUILD_DIR}/${TARGET}/lib/*.a ${JNI_DIR}/lib
}

if [ ${TARGET} == 'arm-v5te' ]; then
    #arm v5te
    CPU=armv5te
    ARCH=arm
    OPTIMIZE_CFLAGS="-marm -march=$CPU"
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'arm-v6' ]; then
    #arm v6
    CPU=armv6
    ARCH=arm
    OPTIMIZE_CFLAGS="-marm -march=$CPU"
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'arm-v7vfpv3' ]; then
    #arm v7vfpv3
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'arm-v7vfp' ]; then
    #arm v7vfp
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}-vfp
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'arm-v7n' ]; then
    #arm v7n
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}
    ADDITIONAL_CONFIGURE_FLAG=--enable-neon
    build_one
fi

if [ ${TARGET} == 'arm-v6+vfp' ]; then
    #arm v6+vfp
    CPU=armv6
    ARCH=arm
    OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}_vfp
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'arm64-v8a' ]; then
    #arm64-v8a
    CPU=arm64-v8a
    ARCH=arm64
    OPTIMIZE_CFLAGS=
    JNI_DIR=`pwd`/../jni/ffmpeg/${CPU}
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'x86_64' ]; then
    #x86_64
    CPU=x86_64
    ARCH=x86_64
    OPTIMIZE_CFLAGS="-fomit-frame-pointer"
    JNI_DIR=`pwd`/../jni/ffmpeg/x86_64
    ADDITIONAL_CONFIGURE_FLAG=
fi

if [ ${TARGET} == 'i686' ]; then
    #x86
    CPU=i686
    ARCH=i686
    OPTIMIZE_CFLAGS="-fomit-frame-pointer"
    JNI_DIR=`pwd`/../jni/ffmpeg/x86
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'mips' ]; then
    #mips
    CPU=mips
    ARCH=mips
    OPTIMIZE_CFLAGS="-std=c99 -O3 -Wall -pipe -fpic -fasm \
-ftree-vectorize -ffunction-sections -funwind-tables -fomit-frame-pointer -funswitch-loops \
-finline-limit=300 -finline-functions -fpredictive-commoning -fgcse-after-reload -fipa-cp-clone \
-Wno-psabi -Wa,--noexecstack"
    JNI_DIR=`pwd`/../jni/ffmpeg/mips
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'armv7-a' ]; then
    #arm armv7-a
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -marm -march=$CPU "
    JNI_DIR=`pwd`/../jni/ffmpeg/armeabi-v7a
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

if [ ${TARGET} == 'arm' ]; then
    #arm arm
    CPU=arm
    ARCH=arm
    OPTIMIZE_CFLAGS=""
    JNI_DIR=`pwd`/../jni/ffmpeg/armeabi
    ADDITIONAL_CONFIGURE_FLAG=
    build_one
fi

echo -e "\033[33m ---------------------COMPLETED ${TARGET}--------------------- \033[0m"
