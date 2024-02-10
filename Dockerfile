FROM ykasidit/android_ndk_c_rust_go_builder:latest

USER root

RUN apt -y install gcc make gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu g++-aarch64-linux-gnu libusb-dev libusb-1.0-0-dev

USER builder
RUN rustup target add aarch64-unknown-linux-gnu
RUN rustup target add x86_64-pc-windows-gnu i686-pc-windows-gnu i686-pc-windows-msvc x86_64-pc-windows-msvc

USER root
COPY ./hello_world /home/builder/hello_world
RUN chown -R builder /home/builder/hello_world
RUN apt -y install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686
RUN apt -y install g++-mingw-w64-x86-64 g++-mingw-w64-i686
RUN apt -y install netcat busybox

USER builder
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN id && rm -rf ~/.cargo/registry/index && cd ~/hello_world && cargo update --dry-run --color never
RUN cd ~/hello_world && cargo fetch
# test offline build works
RUN cd ~/hello_world && cargo build --offline && cargo build --offline --release