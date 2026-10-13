#!/bin/sh
# Build a minimal static FFmpeg (the ffmpeg/ submodule, 3.0.x) for Emscripten,
# with the same decoder set PPSSPP uses on Linux (ffmpeg/linux_x86-64.sh).
# Output: $1 (default build-ffmpeg-wasm/install) with include/ and lib/.
#
# Objects are compiled with -pthread so they can be linked into the threaded
# PPSSPP build (shared memory needs the atomics/bulk-memory features).

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/ffmpeg"
PREFIX="${1:-$ROOT/build-ffmpeg-wasm/install}"
BUILD="$(dirname "$PREFIX")/obj"

if [ -f "$PREFIX/lib/libavcodec.a" ]; then
    echo "FFmpeg for wasm already built in $PREFIX"
    exit 0
fi

mkdir -p "$BUILD"
cd "$BUILD"

NM="$(command -v emnm || command -v llvm-nm || echo "${EMSDK:-/emsdk}/upstream/bin/llvm-nm")"

emconfigure "$SRC/configure" \
    --prefix="$PREFIX" \
    --cc=emcc \
    --cxx=em++ \
    --ar=emar \
    --ranlib=emranlib \
    --nm="$NM" \
    --enable-cross-compile \
    --target-os=none \
    --arch=x86_32 \
    --cpu=generic \
    --disable-asm \
    --disable-inline-asm \
    --disable-runtime-cpudetect \
    --disable-fast-unaligned \
    --disable-pthreads \
    --disable-w32threads \
    --disable-os2threads \
    --disable-debug \
    --disable-stripping \
    --disable-shared \
    --enable-static \
    --disable-everything \
    --disable-programs \
    --disable-doc \
    --disable-avdevice \
    --disable-avfilter \
    --disable-postproc \
    --disable-network \
    --disable-encoders \
    --disable-muxers \
    --disable-zlib \
    --disable-bzlib \
    --disable-lzma \
    --disable-iconv \
    --disable-sdl \
    --disable-xlib \
    --extra-cflags="-pthread -O3 -D__STDC_CONSTANT_MACROS" \
    --extra-ldflags="-pthread" \
    --enable-decoder=h264 \
    --enable-decoder=mpeg4 \
    --enable-decoder=h263 \
    --enable-decoder=h263p \
    --enable-decoder=mpeg2video \
    --enable-decoder=mjpeg \
    --enable-decoder=mjpegb \
    --enable-decoder=aac \
    --enable-decoder=aac_latm \
    --enable-decoder=atrac3 \
    --enable-decoder=atrac3p \
    --enable-decoder=mp3 \
    --enable-decoder=pcm_s16le \
    --enable-decoder=pcm_s8 \
    --enable-demuxer=h264 \
    --enable-demuxer=h263 \
    --enable-demuxer=m4v \
    --enable-demuxer=mpegps \
    --enable-demuxer=mpegvideo \
    --enable-demuxer=avi \
    --enable-demuxer=mp3 \
    --enable-demuxer=aac \
    --enable-demuxer=pmp \
    --enable-demuxer=oma \
    --enable-demuxer=pcm_s16le \
    --enable-demuxer=pcm_s8 \
    --enable-demuxer=wav \
    --enable-parser=h264 \
    --enable-parser=mpeg4video \
    --enable-parser=mpegvideo \
    --enable-parser=aac \
    --enable-parser=aac_latm \
    --enable-parser=mpegaudio \
    --enable-protocol=file

emmake make -j"$(nproc)"
emmake make install

ls -l "$PREFIX/lib"
