Android NDK, Rust 'cargo ndk' builder docker image
==========================================

Use this image to quickly build Rust (or C/C++ using the `ndk-build` command) executables or shared/static libs for Android via the ['cargo ndk' project](https://github.com/bbqsrc/cargo-ndk) - full credit to the respective authors.
Below example commands are to be run in an existing Rust cargo created project folder.

Dockerfile source code in hosted at the [android_ndk_and_rust_cargo_ndk_builder_docker_image repo on github](https://github.com/ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image).

Dockerhub page:
https://hub.docker.com/r/ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image


Build Rust executable or shared/static lib for Android example
-----------------------------------------------------------------------------------------

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cargo ndk build"`

Build Rust executable or shared/static lib for GNU/Linux (Ubuntu 20.04)
-------------------------------------------------------------------------------------------------------

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cargo build"`

Clean the project ('target' folder)
------------------------------------------------
`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cargo clean"`

Generate headers for calling from C code
------------------------------------------------------------
- First create a file named `cbindgen.toml` containing the text:
`language = "C"`
- Then run command:

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cbindgen . -o yourlib.h"`

Build GNU/Linux `Makefile` (to build C/C++ code, etc)
--------------------------------------------------------------
`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build/qcdm_filter && make -j$(nproc)"`

Build 'Android.mk' (in 'jni' folder of NDK C/C++ project folders)
-----------------------------------------------------------------------------------------
`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build/qcdm_filter/android_exec_5/jni && ndk-build -j$(nproc)"`


