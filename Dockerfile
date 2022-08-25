FROM ykasidit/android_ndk_c_rust_go_builder_base:latest

USER root

ENV PATH="/android-sdk/android-ndk-r22b:$PATH"
ENV ANDROID_NDK_HOME=/android-sdk/android-ndk-r22b

RUN apt -y update
RUN apt -y install curl
RUN apt -y install build-essential

USER builder

# install rust stuff
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi
RUN cargo install cargo-ndk cbindgen bindgen

USER root
RUN apt -y install wget

# install go stuff
RUN wget https://go.dev/dl/go1.18.4.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.4.linux-amd64.tar.gz && rm go1.18.4.linux-amd64.tar.gz
RUN apt -y install file clang

USER builder
ENV PATH="${PATH}:/usr/local/go/bin"
ENV ANDROID_TOOLCHAIN=/android-sdk/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
RUN go install std
