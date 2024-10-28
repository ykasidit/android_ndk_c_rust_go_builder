# https://github.com/cirruslabs/docker-images-android/pkgs/container/android-sdk
# https://github.com/cirruslabs/docker-images-android/blob/master/sdk/34/Dockerfile
ARG android_sdk_ver=34-ndk
FROM ghcr.io/cirruslabs/android-sdk:${android_sdk_ver}

USER root

# java 17
RUN apt -y install -y openjdk-17-jdk
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# android sdk envs
ENV ANDROID_SDK=/opt/android-sdk-linux
ENV PLATFORM_TOOLS=$ANDROID_SDK/platform-tools
ENV NDK_BIN=$ANDROID_SDK/ndk/26.2.11394342
ENV ANDROID_HOME=$ANDROID_SDK

# add envs to PATH
ENV PATH=$PATH:$ANDROID_SDK/tools
ENV PATH=$PATH:$ANDROID_SDK/tools/bin
ENV PATH=$PATH:$PLATFORM_TOOLS
ENV PATH=$NDK_BIN:$PATH

# install c/c++ stuff
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive  apt -y install netcat-openbsd busybox cmake ninja-build wget curl build-essential gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu libusb-dev libusb-1.0-0-dev clang
RUN apt -y install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686
RUN apt -y install g++-mingw-w64-x86-64 g++-mingw-w64-i686

USER root
# install go stuff
ENV GO_TAR=go1.22.2.linux-amd64.tar.gz
RUN wget https://go.dev/dl/$GO_TAR && rm -rf /usr/local/go && tar -C /usr/local -xzf $GO_TAR && rm $GO_TAR

# make builder user
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder

# install rust stuff
USER builder
ENV RUST_VER=1.77.0
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain $RUST_VER -y
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi
RUN cargo install cargo-ndk cbindgen bindgen-cli
RUN which rustc && rustc --version
RUN rustc --version | grep $RUST_VER
RUN rustup target add aarch64-unknown-linux-gnu
RUN rustup target add x86_64-pc-windows-gnu i686-pc-windows-gnu i686-pc-windows-msvc x86_64-pc-windows-msvc

ENV PATH="${PATH}:/usr/local/go/bin"
ENV ANDROID_TOOLCHAIN=$ANDROID_SDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
RUN go install std

USER root

# some requirements for some C-calling python tests and some old 32bit libs
RUN mkdir /sdcard && chmod 777 /sdcard && mkdir /data && chmod 777 /data && mkdir -p /android-sdk && chmod 777 /android-sdk
RUN dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tshark socat pcregrep lib32z1 libc6-i386 lib32stdc++6 libclang-dev socat pcregrep tshark lib32z1 libc6-i386 lib32stdc++6 libclang-dev python3 python-is-python3 xxd python3-pip ipython3 file python3-pandas python3-gevent

# flutter
ARG flutter_ver=3.24.3
ARG build_rev=0

# Install Flutter
ENV FLUTTER_HOME=/usr/local/flutter \
    FLUTTER_VERSION=${flutter_ver} \
    PATH=$PATH:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends --no-install-suggests \
            ca-certificates \
 && update-ca-certificates \
    \
 # Install dependencies for Linux toolchain
 && apt-get install -y --no-install-recommends --no-install-suggests \
            build-essential \
            clang cmake \
            lcov \
            libgtk-3-dev liblzma-dev \
            ninja-build \
            pkg-config \
    \
 # Install Flutter itself
 && curl -fL -o /tmp/flutter.tar.xz \
         https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_ver}-stable.tar.xz \
 && tar -xf /tmp/flutter.tar.xz -C /usr/local/ \
 && git config --global --add safe.directory /usr/local/flutter \
 && flutter config --enable-android \
                   --enable-linux-desktop \
                   --enable-web \
                   --no-enable-ios \
 && flutter precache --universal --linux --web --no-ios \
 && (yes | flutter doctor --android-licenses) \
 && flutter --version \
    \
 && rm -rf /var/lib/apt/lists/* \
           /tmp/*

USER builder