FROM ykasidit/android_ndk_c_rust_go_builder_base:latest

USER root

ENV PATH="/android-sdk/android-ndk-r22b:$PATH"
ENV ANDROID_NDK_HOME=/android-sdk/android-ndk-r22b

RUN apt -y update
RUN apt -y install curl wget
RUN apt -y install build-essential gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu

# install go stuff
RUN wget https://go.dev/dl/go1.18.4.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.4.linux-amd64.tar.gz && rm go1.18.4.linux-amd64.tar.gz
RUN apt -y install file clang

USER builder
ENV PATH="${PATH}:/usr/local/go/bin"
ENV ANDROID_TOOLCHAIN=/android-sdk/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
RUN go install std

USER root

# some requirements for some C-calling python tests and some old 32bit libs
RUN mkdir /sdcard && chmod 777 /sdcard && mkdir /data && chmod 777 /data && mkdir -p /android-sdk && chmod 777 /android-sdk
RUN dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tshark socat pcregrep lib32z1 libc6-i386 lib32stdc++6 libclang-dev xxd
RUN apt-get -y install python2 socat pcregrep tshark lib32z1 libc6-i386 lib32stdc++6 libclang-dev
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install pandas==0.24.2
RUN python2 -m pip install gevent==20.9.0

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /rustup.sh
RUN chmod +x /rustup.sh

USER builder
# install rust stuff
RUN /rustup.sh --default-toolchain 1.74.1 -y
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi
RUN rustup target add aarch64-unknown-linux-gnu
RUN cargo install cargo-ndk cbindgen
