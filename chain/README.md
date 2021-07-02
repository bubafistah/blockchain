# Lethean

Copyright (c) 2017-2021 Lethean VPN.   
Portions Copyright (c) 2014-2020 The Monero Project.   
Portions Copyright (c) 2012-2013 The Cryptonote developers.

### Dependencies

See: [https://chain.lethean.help/building/dependencies](https://chain.lethean.help/building/dependencies) / [../docs/building/dependencies.md](../docs/building/dependencies.md)


### Build instructions

Basic instructions included below, for detailed instructions see: 

[https://chain.lethean.help/building](https://chain.lethean.help/building) / [../docs/building/index.md](../docs/building/index.md)

#### On Linux

* Install the [https://chain.lethean.help/building/dependencies](https://chain.lethean.help/building/dependencies) / [../docs/building/dependencies.md](../docs/building/dependencies.md)
* Change to the root of the source code directory, change to the most recent release branch, and build:

    ```bash
    cd lethean
    git checkout next
    make
    ```

    *Optional*: If your machine has several cores and enough memory, enable
    parallel build by running `make -j<number of threads>` instead of `make`. For
    this to be worthwhile, the machine should have one core and about 2GB of RAM
    available per thread.

    *Note*: The instructions above will compile the most stable release of the
    lethean software. If you would like to use and test the most recent software,
    use ```git checkout master```. The master branch may contain updates that are
    both unstable and incompatible with release software, though testing is always
    encouraged.

* The resulting executables can be found in `build/release/bin`

* Add `PATH="$PATH:$HOME/lethean/build/release/bin"` to `.profile`

* Run lethean with `letheand --detach`

* **Optional**: build and run the test suite to verify the binaries:

    ```bash
    make release-test
    ```

    *NOTE*: `core_tests` test may take a few hours to complete.

* **Optional**: to build binaries suitable for debugging:

    ```bash
    make debug
    ```

* **Optional**: to build statically-linked binaries:

    ```bash
    make release-static
    ```

Dependencies need to be built with -fPIC. Static libraries usually aren't, so you may have to build them yourself with -fPIC. Refer to their documentation for how to build them.

* **Optional**: build documentation in `doc/html` (omit `HAVE_DOT=YES` if `graphviz` is not installed):

    ```bash
    HAVE_DOT=YES doxygen Doxyfile
    ```

