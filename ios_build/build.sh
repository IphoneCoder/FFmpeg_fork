build() {
    set -e

while [ $# -gt 0 ]; do
    case $1 in
        help|--help|-h)
            echo "Use -a to set the ARCH:"
            echo "  ARM:     armeabi-v7a"
            echo "  ARM64:   arm64-v8a"
            echo "  X86:     x86, x86_64"
            exit 0
            ;;
        a|-a)
            FF_ARCH=$2
            shift
            ;;
    esac
    shift
done
FF_XCRUN_PLATFORM="iPhoneOS"
HOST="arm-apple-darwin"
if [ "$FF_ARCH" = "i386" ]; then
    FF_XCRUN_PLATFORM="iPhoneSimulator"
    FF_XCRUN_OSVERSION="-mios-simulator-version-min=6.0"
    HOST=i386-apple-darwin
elif [ "$FF_ARCH" = "x86_64" ]; then
    FF_XCRUN_PLATFORM="iPhoneSimulator"
    FF_XCRUN_OSVERSION="-mios-simulator-version-min=9.0"
    HOST=x86_64-apple-darwin
elif [ "$FF_ARCH" = "armv7" ]; then
    FF_XCRUN_OSVERSION="-miphoneos-version-min=9.0"
#    FFMPEG_CFG_CPU="--cpu=cortex-a8"
elif [ "$FF_ARCH" = "armv7s" ]; then
    FFMPEG_CFG_CPU="--cpu=swift"
    FF_XCRUN_OSVERSION="-miphoneos-version-min=9.0"
elif [ "$FF_ARCH" = "arm64" ]; then
    FF_XCRUN_OSVERSION="-miphoneos-version-min=11.0"
else
    echo "unknown architecture $FF_ARCH";
    exit 1
fi
FF_XCRUN_SDK=`echo $FF_XCRUN_PLATFORM | tr '[:upper:]' '[:lower:]'`

# Make in //
if [ -z "$MAKEFLAGS" ]; then
    UNAMES=$(uname -s)
    MAKEFLAGS=
    if which nproc >/dev/null; then
        MAKEFLAGS=-j`nproc`
    elif [ "$UNAMES" == "Darwin" ] && which sysctl >/dev/null; then
        MAKEFLAGS=-j`sysctl -n machdep.cpu.thread_count`
    fi
fi
CFLAGS="$CFLAGS -arch $FF_ARCH $FF_XCRUN_OSVERSION"
PREFIX=$(pwd)/output/ios/${FF_ARCH}

# export AR='xcrun -sdk iphoneos ar'
export CC="xcrun -sdk $FF_XCRUN_SDK clang -arch $FF_ARCH"
# export CXX="xcrun -sdk $FF_XCRUN_SDK cxx"
export SDKROOT=`xcrun --sdk iphoneos --show-sdk-path`
# export AS=$CC
# export LD="xcrun -sdk $FF_XCRUN_SDK ld"
# export RANLIB=$NDK_TOOLCHAIN_PATH/llvm-ranlib
# export STRIP="xcrun -sdk $FF_XCRUN_SDK strip"
# export CPP='xcrun -sdk iphoneos cpp'
export CFLAGS=$CFLAGS
export LDFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS


FF_EXTRA_CFLAGS="-I$(pwd)/libs/include -I$(pwd)/libs/include/SDL2 -I$(pwd)/libs/include/x265 -I$(pwd)/libs/include/x264"
FF_EXTRA_LDFLAGS="-L$(pwd)/libs/libs -Wl,-framework,CoreVideo -Wl,-framework,CoreAudio -Wl,-framework,AudioToolbox -Wl,-framework,AVFoundation -Wl,-framework,CoreBluetooth -Wl,-framework,CoreGraphics -Wl,-framework,CoreMotion -Wl,-framework,Foundation -Wl,-weak_framework,GameController -Wl,-framework,Metal -Wl,-framework,OpenGLES -Wl,-framework,QuartzCore -Wl,-framework,UIKit -Wl,-weak_framework,CoreHaptics -lpthread  -lm -ldl -lstdc++"
export PKG_CONFIG_PATH="/Users/wangyaqiang/Documents/own_projects/fribidi/ios-build/output/ios/arm64/out/lib/pkgconfig:/Users/wangyaqiang/Documents/own_projects/fontconfig/out/lib/pkgconfig:/Users/wangyaqiang/Documents/own_projects/libass/ios-build/output/ios/arm64/out/lib/pkgconfig:/Users/wangyaqiang/Documents/own_projects/libunibreak/ios-build/output/ios/arm64/out/lib/pkgconfig:/Users/wangyaqiang/Documents/own_projects/harfbuzz/out/lib/pkgconfig"
mkdir -p ${PREFIX}
pushd $(pwd)/../
sudo make clean
sudo make distclean
./configure \
    --enable-debug \
    --disable-optimizations \
    --enable-cross-compile \
    --prefix=${PREFIX}/out \
    --disable-avdevice \
    --disable-metal \
    --enable-sdl2 \
    --enable-libx265 \
    --enable-libx264 \
    --enable-filter=subtitles \
    --enable-libass \
    --enable-libfribidi \
    --enable-gpl \
    --disable-doc \
    --extra-cflags="$FF_EXTRA_CFLAGS" \
    --disable-programs \
    --sysroot="$SDKROOT" \
    --extra-ldflags="$FF_EXTRA_LDFLAGS"

sudo make -j12
sudo make install
cp -rf $PREFIX/out/* /Users/wangyaqiang/Downloads/FFmpeg_Test/FFmpeg_Test/libs/FFmpeg 
cp -rf $PREFIX/out/* /Users/wangyaqiang/Documents/own_projects/moment/Moment/Modules/Recorder/Recorder/libs/FFmpeg
popd
}

build -a arm64
