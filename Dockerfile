FROM ykasidit/android_ndk_c_rust_go_builder_1.77.0:latest
USER root
COPY ./hello_world /home/builder/hello_world
RUN chown -R builder /home/builder/hello_world

USER builder
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN id && rm -rf ~/.cargo/registry/index && cd ~/hello_world && cargo update --dry-run --color never
RUN cd ~/hello_world && cargo fetch
# test offline build works
RUN cd ~/hello_world && cargo build --offline && cargo build --offline --release