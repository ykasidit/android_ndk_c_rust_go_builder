FROM ykasidit/android_ndk_c_rust_go_builder:latest

USER root
RUN apt -y install file pkg-config libopus-dev libopusfile-dev libasound2-dev

USER builder
ENV PATH="${PATH}:/usr/local/go/bin"
ENV ANDROID_TOOLCHAIN=/android-sdk/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
