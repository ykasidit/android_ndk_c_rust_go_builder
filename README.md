Android NDK Rust `cargo ndk` and C/C++ `ndk-build` builder docker image
=======================================================================

Use this image to quickly build Rust and/or C/C++ executables or shared/static libs for Android.

- Android Rust build support provided by the [`cargo ndk` command/project](https://github.com/bbqsrc/cargo-ndk).
- This image also contains [cbindgen](https://docs.rs/cbindgen/latest/cbindgen/)
- Android C/C++ build support provided by the `ndk-build` command of the [Android NDK](https://developer.android.com/ndk/downloads) version r22b as that works with `cargo ndk` at the time of this writing. 
- Common [`GCC` C/C++ compilers](https://gcc.gnu.org/) and [`GNU make`](https://www.gnu.org/software/make/) for Ubuntu 20.04 GNU/Linux.

Full credit to the respective authors.

Dockerhub page:
https://hub.docker.com/r/ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image

Below are some example usage/commands:

Rust: build executable or shared/static lib for Android
-----------------------------------------------------------------
(Run in an existing Rust cargo created project folder)

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cargo ndk build"`

Rust: build executable or shared/static lib for GNU/Linux (Ubuntu 20.04)
-------------------------------------------------------------------------------------------------------
(Run in an existing Rust cargo created project folder)

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cargo build"`

Rust: clean the project ('target' folder)
------------------------------------------------
(Run in an existing Rust cargo created project folder)

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cargo clean"`

Rust: Generate headers for calling from C code
------------------------------------------------------------
- First create a file named `cbindgen.toml` containing the text:
`language = "C"`
- Then run command:
(Run in an existing Rust cargo created project folder)

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build && cbindgen . -o yourlib.h"`

C/C++: build `Android.mk` for Android
-------------------------
(Run in the 'jni' folder - that contains the `Android.mk` file - inside the desired NDK C/C++ project folder)

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build/qcdm_filter/android_exec_5/jni && ndk-build -j$(nproc)"`

C/C++: build GNU/Linux `Makefile` (to build C/C++ code, etc)
--------------------------------------------------------------
(Run in the folder that has your `Makefile`)

`docker run --rm -v $(pwd):/build ykasidit/android_ndk_and_rust_cargo_ndk_builder_docker_image:latest bash -c "cd /build/qcdm_filter && make -j$(nproc)"`
