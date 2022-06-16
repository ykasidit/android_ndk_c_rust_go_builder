FROM ykasidit/ubuntu-pandas-data-to-report-and-more-python3:latest

USER root

RUN apt-get -y install python2 socat
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install pandas==0.24.2
RUN mkdir /sdcard
RUN chmod 777 /sdcard
RUN apt-get -y install pcregrep
RUN apt-get -y install tshark
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install lib32z1 libc6-i386 lib32stdc++6 lib32gcc1
RUN mkdir /data
RUN chmod 777 /data
RUN python2 -m pip install gevent==20.9.0
RUN mkdir /android-sdk
RUN chmod 777 /android-sdk

USER report_worker

# copy the android sdk
ADD ./android-ndk-r22b /android-sdk/android-ndk-r22b

# install rust stuff
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
ENV PATH="/home/report_worker/.cargo/bin:$PATH"
RUN cargo install cargo-ndk
RUN cargo install cbindgen
ENV PATH="/android-sdk/android-ndk-r22b:$PATH"
RUN rustup target add \
    aarch64-linux-android \
    armv7-linux-androideabi
