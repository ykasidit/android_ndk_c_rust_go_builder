FROM bitnami/minideb:bullseye

RUN useradd builder -m
USER builder
# copy the android sdk
ADD ./android-ndk-r22b /android-sdk/android-ndk-r22b
