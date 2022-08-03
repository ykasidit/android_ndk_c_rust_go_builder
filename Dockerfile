FROM ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest

USER root
RUN wget https://go.dev/dl/go1.18.4.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.4.linux-amd64.tar.gz && rm go1.18.4.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"
ENV ANDROID_TOOLCHAIN=/android-sdk/android-ndk-r22b/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
RUN go install std

USER report_worker