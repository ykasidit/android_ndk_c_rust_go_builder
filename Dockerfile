FROM ykasidit/android_ndk_c_rust_go_builder:latest

USER root

RUN apt -y install gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu libusb-dev libusb-1.0-0-dev

USER builder
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN rustup target add aarch64-unknown-linux-gnu

