#### On the Raspberry Pi

Tested on a Raspberry Pi Zero with a clean install of minimal Raspbian Stretch (2017-09-07 or later) from https://www.raspberrypi.org/downloads/raspbian/. If you are using Raspian Jessie, [please see note in the following section](#note-for-raspbian-jessie-users).

* `apt-get update && apt-get upgrade` to install all of the latest software

* Install the dependencies for Lethean from the 'Debian' column in the table above.

* Increase the system swap size:

    ```bash
    sudo /etc/init.d/dphys-swapfile stop  
    sudo nano /etc/dphys-swapfile  
    CONF_SWAPSIZE=2048
    sudo /etc/init.d/dphys-swapfile start
    ```

* If using an external hard disk without an external power supply, ensure it gets enough power to avoid hardware issues when syncing, by adding the line "max_usb_current=1" to /boot/config.txt

* Clone Lethean and checkout the most recent release version:

    ```bash
    git clone https://gitlab.com/lthn.io/projects/chain/lethean.git
    cd lethean
    git checkout next
    ```

* Build:

    ```bash
    make release
    ```

* Wait 4-6 hours

* The resulting executables can be found in `build/release/bin`

* Add `PATH="$PATH:$HOME/lethean/build/release/bin"` to `.profile`

* Run Lethean with `letheand --detach`

* You may wish to reduce the size of the swap file after the build has finished, and delete the boost directory from your home directory

#### *Note for Raspbian Jessie users:*

If you are using the older Raspbian Jessie image, compiling Lethean is a bit more complicated. The version of Boost available in the Debian Jessie repositories is too old to use with Lethean, and thus you must compile a newer version yourself. The following explains the extra steps and has been tested on a Raspberry Pi 2 with a clean install of minimal Raspbian Jessie.

* As before, `apt-get update && apt-get upgrade` to install all of the latest software, and increase the system swap size

    ```bash
    sudo /etc/init.d/dphys-swapfile stop
    sudo nano /etc/dphys-swapfile
    CONF_SWAPSIZE=2048
    sudo /etc/init.d/dphys-swapfile start
    ```


* Then, install the dependencies for Lethean except for `libunwind` and `libboost-all-dev`

* Install the latest version of boost (this may first require invoking `apt-get remove --purge libboost*-dev` to remove a previous version if you're not using a clean install):

    ```bash
    cd
    wget https://sourceforge.net/projects/boost/files/boost/1.72.0/boost_1_72_0.tar.bz2
    tar xvfo boost_1_72_0.tar.bz2
    cd boost_1_72_0
    ./bootstrap.sh
    sudo ./b2
    ```

* Wait ~8 hours

    ```bash    
    sudo ./bjam cxxflags=-fPIC cflags=-fPIC -a install
    ```

* Wait ~4 hours

* From here, follow the [general Raspberry Pi instructions](#on-the-raspberry-pi) from the "Clone Lethean and checkout most recent release version" step.
