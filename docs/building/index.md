# Building Lethean

The easiest way to compile our source code is to use our Docker images, 
this lets you build anything on any host that can run docker

# Native Builds

- [Linux](linux.md)
- [MacOS](macos.md)
- [Windows](windows.md)
- [Raspberry PI](raspberry-pi.md)
- [NetBSD](netbsd.md)
- [FreeBSD](freebsd.md)
- [OpenBSD](openbsd.md)
- [Solaris](solaris.md)


# Building portable statically linked binaries

By default, in either dynamically or statically linked builds, binaries target the specific host processor on which the build happens and are not portable to other processors. Portable binaries can be built using the following targets:

* ```make release-static-linux-x86_64``` builds binaries on Linux on x86_64 portable across POSIX systems on x86_64 processors
* ```make release-static-linux-i686``` builds binaries on Linux on x86_64 or i686 portable across POSIX systems on i686 processors
* ```make release-static-linux-armv8``` builds binaries on Linux portable across POSIX systems on armv8 processors
* ```make release-static-linux-armv7``` builds binaries on Linux portable across POSIX systems on armv7 processors
* ```make release-static-linux-armv6``` builds binaries on Linux portable across POSIX systems on armv6 processors
* ```make release-static-win64``` builds binaries on 64-bit Windows portable across 64-bit Windows systems
* ```make release-static-win32``` builds binaries on 64-bit or 32-bit Windows portable across 32-bit Windows systems

# Cross Compiling

You can also cross-compile static binaries on Linux for Windows and macOS with the `depends` system.

* ```make depends target=x86_64-linux-gnu``` for 64-bit linux binaries.
* ```make depends target=x86_64-w64-mingw32``` for 64-bit windows binaries.
    * Requires: `python3 g++-mingw-w64-x86-64 wine1.6 bc`
* ```make depends target=x86_64-apple-darwin11``` for macOS binaries.
    * Requires: `cmake imagemagick libcap-dev librsvg2-bin libz-dev libbz2-dev libtiff-tools python-dev`
* ```make depends target=i686-linux-gnu``` for 32-bit linux binaries.
    * Requires: `g++-multilib bc`
* ```make depends target=i686-w64-mingw32``` for 32-bit windows binaries.
    * Requires: `python3 g++-mingw-w64-i686`
* ```make depends target=arm-linux-gnueabihf``` for armv7 binaries.
    * Requires: `g++-arm-linux-gnueabihf`
* ```make depends target=aarch64-linux-gnu``` for armv8 binaries.
    * Requires: `g++-aarch64-linux-gnu`
* ```make depends target=riscv64-linux-gnu``` for RISC V 64 bit binaries.
    * Requires: `g++-riscv64-linux-gnu`
* ```make depends target=x86_64-unknown-freebsd``` for freebsd binaries.
    * Requires: `clang-8`
* ```make depends target=arm-linux-android``` for 32bit android binaries
* ```make depends target=aarch64-linux-android``` for 64bit android binaries


The required packages are the names for each toolchain on apt. Depending on your distro, they may have different names.

Using `depends` might also be easier to compile Lethean on Windows than using MSYS. Activate Windows Subsystem for Linux (WSL) with a distro (for example Ubuntu), install the apt build-essentials and follow the `depends` steps as depicted above.

The produced binaries still link libc dynamically. If the binary is compiled on a current distribution, it might not run on an older distribution with an older installation of libc. Passing `-DBACKCOMPAT=ON` to cmake will make sure that the binary will run on systems having at least libc version 2.17.
