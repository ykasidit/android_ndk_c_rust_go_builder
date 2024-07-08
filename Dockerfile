FROM ykasidit/android_ndk_c_rust_go_builder_base_u2004:latest
USER root
RUN apt -y update
RUN DEBIAN_FRONTEND=noninteractive apt -y install cmake git pkgconf libglib2.0-dev libgcrypt20-dev libpcap-dev libc-ares-dev libgcrypt20-dev libglib2.0-dev flex bison libpcre2-dev libnghttp2-dev libspeexdsp-dev libunwind-dev
COPY ./hello_world /home/builder/hello_world
RUN chown -R builder /home/builder/hello_world

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
RUN echo "deb https://dl.winehq.org/wine-builds/ubuntu/ focal main" | tee /etc/apt/sources.list.d/winehq.list

# Update package list and install Wine 64-bit
RUN apt-get update && apt-get install -y --install-recommends winehq-stable:amd64

# Set the Wine prefix to avoid configuration dialogs
ENV WINEPREFIX=/home/builder/.wine64

# Install any additional software via Wine (optional)
# Example: RUN wine64 <installer.exe>

USER builder
ENV PATH="/home/builder/.cargo/bin:$PATH"
RUN id && rm -rf ~/.cargo/registry/index && cd ~/hello_world && cargo update --dry-run --color never
RUN cd ~/hello_world && cargo fetch
# test offline build works
RUN cd ~/hello_world && cargo build --offline && cargo build --offline --release