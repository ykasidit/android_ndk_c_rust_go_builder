FROM ykasidit/android_ndk_c_rust_go_builder_base_u2004:latest
USER root
RUN apt -y update
RUN apt -y install cmake git pkgconf libglib2.0-dev
COPY ./hello_world /home/builder/hello_world
RUN chown -R builder /home/builder/hello_world

USER builder
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN id && rm -rf ~/.cargo/registry/index && cd ~/hello_world && cargo update --dry-run --color never
RUN cd ~/hello_world && cargo fetch
# test offline build works
RUN cd ~/hello_world && cargo build --offline && cargo build --offline --release