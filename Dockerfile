FROM ykasidit/ubuntu-pandas-data-to-report-and-more-python3:latest

USER root

# some old requirements for some old C-calling python2 tests
RUN apt-get update
RUN dpkg --add-architecture i386
RUN apt-get -y install python2 socat pcregrep tshark lib32z1 libc6-i386 lib32stdc++6 lib32gcc1 libclang-dev
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install pandas==0.24.2
RUN mkdir /sdcard && chmod 777 /sdcard && mkdir /data && chmod 777 /data && mkdir /android-sdk && chmod 777 /android-sdk
RUN python2 -m pip install gevent==20.9.0

USER report_worker
# copy the android sdk
ADD ./android-ndk-r22b /android-sdk/android-ndk-r22b
# install rust stuff
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
ENV PATH="/home/report_worker/.cargo/bin:$PATH"
ENV PATH="/android-sdk/android-ndk-r22b:$PATH"
ENV ANDROID_NDK_HOME=/android-sdk/android-ndk-r22b
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi
RUN cargo install cargo-ndk cbindgen bindgen
