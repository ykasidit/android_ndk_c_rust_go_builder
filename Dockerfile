FROM ubuntu:22.04

USER root

ADD ./android-ndk-r26c /android-sdk/android-ndk-r26c
ENV PATH="/android-sdk/android-ndk-r26c:$PATH"
ENV ANDROID_NDK_HOME=/android-sdk/android-ndk-r26c

RUN apt -y update
RUN apt -y install netcat busybox cmake ninja-build wget curl build-essential gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu libusb-dev libusb-1.0-0-dev clang
RUN apt -y install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686
RUN apt -y install g++-mingw-w64-x86-64 g++-mingw-w64-i686

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

USER root
# install go stuff
RUN wget https://go.dev/dl/go1.18.4.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.4.linux-amd64.tar.gz && rm go1.18.4.linux-amd64.tar.gz

USER builder
ENV PATH="${PATH}:/usr/local/go/bin"
ENV ANDROID_TOOLCHAIN=/android-sdk/android-ndk-r26c/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
RUN go install std

USER root

# some requirements for some C-calling python tests and some old 32bit libs
RUN mkdir /sdcard && chmod 777 /sdcard && mkdir /data && chmod 777 /data && mkdir -p /android-sdk && chmod 777 /android-sdk
RUN dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tshark socat pcregrep lib32z1 libc6-i386 lib32stdc++6 libclang-dev socat pcregrep tshark lib32z1 libc6-i386 lib32stdc++6 libclang-dev python3 python-is-python3 xxd python3-pip ipython3 file
RUN pip install pandas gevent
USER builder