# https://github.com/cirruslabs/docker-images-android/pkgs/container/android-sdk
# https://github.com/cirruslabs/docker-images-android/blob/master/sdk/34/Dockerfile
ARG android_sdk_ver=34-ndk
FROM ghcr.io/cirruslabs/android-sdk:${android_sdk_ver}

RUN userdel ubuntu

USER root

#### android sdk envs
ENV ANDROID_SDK=/opt/android-sdk-linux
ENV PLATFORM_TOOLS=$ANDROID_SDK/platform-tools
ENV NDK_BIN=$ANDROID_SDK/ndk/26.2.11394342
ENV ANDROID_NDK_HOME=$NDK_BIN
ENV ANDROID_HOME=$ANDROID_SDK
ENV ANDROID_NDK=$NDK_BIN

#### add envs to PATH
ENV PATH=$PATH:$ANDROID_SDK/tools
ENV PATH=$PATH:$ANDROID_SDK/tools/bin
ENV PATH=$PATH:$PLATFORM_TOOLS
ENV PATH=$NDK_BIN:$PATH

#### test path has android sdk/ndk stuff
RUN ndk-build --version
RUN adb version

#################### install system packages
RUN apt -y update
RUN dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt -y install netcat-openbsd busybox cmake ninja-build wget curl build-essential gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu libusb-dev libusb-1.0-0-dev clang tshark socat pcregrep lib32z1 libc6-i386 lib32stdc++6 libclang-dev socat pcregrep tshark lib32z1 libc6-i386 lib32stdc++6 libclang-dev python3 python-is-python3 xxd python3-pip ipython3 file python3-pandas python3-gevent cmake git pkgconf libglib2.0-dev libgcrypt20-dev libpcap-dev libc-ares-dev libgcrypt20-dev libglib2.0-dev flex bison libpcre2-dev libnghttp2-dev libspeexdsp-dev libunwind-dev gcc-mingw-w64-x86-64 gcc-mingw-w64-i686 g++-mingw-w64-x86-64 g++-mingw-w64-i686 openjdk-17-jdk

################# install flatbuffers for system python
RUN pip3 install --break-system-packages flatbuffers websocket-client

############# test java 17
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
RUN java --version

########################### install wine for testing win64 exe/dlls
# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    gnupg2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add the WineHQ repository key and repository
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key && apt-key add winehq.key && rm winehq.key
RUN echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/winehq.list

# Update package list and install Wine 64-bit
RUN apt-get update && apt-get install -y --install-recommends wine-stable

################# ensure ndk-build and wine are in PATH for all interactive shells (docker exec -it bash)
RUN echo 'export PATH="'"$NDK_BIN"':$PATH"' > /etc/profile.d/builder-paths.sh \
 && echo 'export ANDROID_SDK='"$ANDROID_SDK" >> /etc/profile.d/builder-paths.sh \
 && echo 'export ANDROID_NDK_HOME='"$NDK_BIN" >> /etc/profile.d/builder-paths.sh \
 && echo 'export ANDROID_NDK='"$NDK_BIN" >> /etc/profile.d/builder-paths.sh \
 && echo 'export ANDROID_HOME='"$ANDROID_SDK" >> /etc/profile.d/builder-paths.sh \
 && chmod +x /etc/profile.d/builder-paths.sh \
 && echo '. /etc/profile.d/builder-paths.sh' >> /etc/bash.bashrc

######################## make dirs for android unit/integ test code that can run here
RUN mkdir /sdcard && chmod 777 /sdcard && mkdir /data && chmod 777 /data && chmod 777 $ANDROID_SDK

################# install go stuff
ENV GO_TAR=go1.22.2.linux-amd64.tar.gz
RUN wget https://go.dev/dl/$GO_TAR && rm -rf /usr/local/go && tar -C /usr/local -xzf $GO_TAR && rm $GO_TAR
ENV PATH=$PATH:/usr/local/go/bin
RUN go install std
RUN go version

################################ flutter
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

################# make builder user
RUN useradd -ms /bin/bash builder
USER builder
WORKDIR /home/builder
# Set the Wine prefix to avoid configuration dialogs
ENV WINEPREFIX=/home/builder/.wine64

################# install rust stuff (as user 'builder)
ENV RUST_VER=1.86.0
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
ENV ANDROID_TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
RUN ls -l $ANDROID_TOOLCHAIN

######################### test build rust hello world
COPY ./hello_world /home/builder/hello_world
ENV PATH="/home/builder/.cargo/bin:$PATH"
USER root
RUN chown -R builder:builder /home/builder/hello_world /home/builder/.cargo
USER builder
RUN id && rm -rf ~/.cargo/registry/index && cd ~/hello_world && cargo update --dry-run --color never
RUN cd ~/hello_world && cargo fetch
# test offline build works
RUN cd ~/hello_world && cargo build --offline && cargo build --offline --release
