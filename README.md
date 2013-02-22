Install mspgcc in Ubuntu
========================

This repo has a script to install and some utilities to use  [mspgcc uniarch](http://mspgcc.sourceforge.net/) (C compiler for [msp430](http://www.ti.com/msp430) microcontrollers) in Ubuntu. It installs the LTS (Long Term Support) version of the compiler, 
which is the most up-to-date version. Currently, this is LTS 20120406. 

To build mspgcc you will need to install _at least_ the following packages:

    $ sudo apt-get install patch ncurses-dev build-essential bison flex libgmp3-dev libmpfr-dev libmpc-dev texinfo zlib1g-dev

The installation folder is `/usr/local/msp430` (modifiable in the script). If you already have contents in this folder I recommend you to move it to a backup folder, i.e.:
    
    $ sudo mv /usr/local/msp430 /usr/local/msp430-backup

To install go to the console and run:

    $ git clone https://github.com/jlhonora/mspgcc-install.git
    $ cd mspgcc-install
    $ chmod +x install-all
    $ ./install-all

You should be careful to watch for error messages. 

If everything goes well, I recommend you to add the msp430-gcc path to your environment path. For that, append the following line to your `.bashrc`:

    PATH=$PATH:/usr/local/msp430/bin

## Testing ##

To check that everything is ok, type:

    $ cd tests
    $ msp430-gcc -mmcu=msp430g2553 hello_world.c 

The mmcu option should match the microcontroller you will be using.

## Installing the file in a Launchpad board ##

The previous command should generate a compiled file named `a.out`, ready to install in the microcontroller. If you have a [MSP430 Launchpad Board](http://www.ti.com/ww/en/launchpad/msp430_head.html) at reach you can install the compiled file with [mspdebug](http://mspdebug.sourceforge.net/). It can be installed with 

    $ sudo apt-get install libusb-dev
    $ wget http://sourceforge.net/projects/mspdebug/files/mspdebug-0.21.tar.gz
    $ cd mspdebug-0.21
    $ make WITHOUTH_READLINE=1
    $ sudo make install

USB permissions should be added to the FET interface of the Launchpad ([source](https://github.com/sergiocampama/Launchpad#mspdebug-usb-permissions)). As root, creat the file `/etc/udev/rules.d/71-persistent-msp430.rules` and add `AATR{idVendor}=="0451", ATTRS{idProduct}=="f432", MODE="0660", GROUP="plugdev"` . Then run

    sudo addgroup YOUR_USERNAME plugdev
    sudo restart udev

If everything goes well, you can install the compiled program:

    $ sudo mspdebug rf2500 "prog a.out"

This should also work with the [MSP-EXP430F5529 board](http://www.ti.com/tool/msp-exp430f5529), but changing the compile options to `-mmcu=msp430f5529`.

## Credits ##
    
This guide is loosely based on [Sergio Campama's](https://github.com/sergiocampama/Launchpad) guide and the README files of mspgcc.

----

## Building every part separately ##

In the following sections you will find how to build each part of the project in order.

## mspgcc basics ##
```bash
    # Installation path. This will overwrite your
    # changes to the INSTALL_PATH folder
    INSTALL_PATH=/usr/local/msp430

    # get LTS mspgcc
    wget http://sourceforge.net/projects/mspgcc/files/mspgcc/mspgcc-20120406.tar.bz2
    tar xvf mspgcc-20120406.tar.bz2
    cd mspgcc-20120406
```

## binutils ##
Utilities for working with msp430 (hexdumps, etc.)
```bash
    echo "Downloading binutils" 
    wget ftp://ftp.gnu.org/pub/gnu/binutils/binutils-2.21.1a.tar.bz2
    echo "Extracting binutils" 
    tar xjf binutils-2.21.1a.tar.bz2
    echo "Installing binutils" 
    ( cd binutils-2.21.1 ; patch -p1 < ../msp430-binutils-2.21.1a-20120406.patch )
    mkdir -p BUILD/binutils
    cd BUILD/binutils
    ../../binutils-2.21.1/configure \
      --target=msp430 \
      --prefix=$INSTALL_PATH \
    2>&1 | tee co
    make 2>&1 | tee mo
    sudo make install 2>&1 | tee moi
    echo "Done with binutils" 
    cd ../../
```
    
## gcc ##
The compiler itself.
```bash
    echo "Downloading gcc" 
    wget ftp://ftp.gnu.org/pub/gnu/gcc/gcc-4.6.3/gcc-4.6.3.tar.bz2
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3540953.patch
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3559978.patch
    echo "Extracting gcc" 
    tar xjf gcc-4.6.3.tar.bz2
    echo "Installing gcc" 
    cd gcc-4.6.3
    patch -p1 < ../msp430-gcc-4.6.3-20120406.patch
    patch -p1 < ../msp430-gcc-4.6.3-20120406-sf3540953.patch
    patch -p1 < ../msp430-gcc-4.6.3-20120406-sf3559978.patch
    cd ..
    mkdir -p BUILD/gcc
    cd BUILD/gcc
    ../../gcc-4.6.3/configure \
      --target=msp430 \
      --enable-languages=c,c++ \
      --prefix=$INSTALL_PATH \
    2>&1 | tee co
    make 2>&1 | tee mo
    sudo make install 2>&1 | tee moi
    echo "Done with gcc" 
```
    
## gdb ##

GDB for msp430.

```bash
    echo "Downloading gdb" 
    wget ftp://ftp.gnu.org/pub/gnu/gdb/gdb-7.2a.tar.bz2
    echo "Extracting gdb" 
    tar xjf gdb-7.2a.tar.bz2
    echo "Installing gdb" 
    ( cd gdb-7.2 ; patch -p1 < ../msp430-gdb-7.2a-20111205.patch )
    mkdir -p BUILD/gdb
    cd BUILD/gdb
    ../../gdb-7.2/configure \
      --target=msp430 \
      --prefix=$INSTALL_PATH \
    2>&1 | tee co
    make 2>&1 | tee mo
    sudo make install 2>&1 | tee moi
    echo "Done with gdb" 
    cd ../../
```

## msp430mcu ##

Installs the header files and others related to every TI mcu.

```bash
    echo "Downloading msp430mcu" 
    wget http://sourceforge.net/projects/mspgcc/files/msp430mcu/msp430mcu-20120406.tar.bz2
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430mcu-20120406-sf3522088.patch
    echo "Extracting msp430mcu" 
    tar xvf msp430mcu-20120406.tar.bz2
    cd msp430mcu-20120406
    patch -p1 < ../msp430mcu-20120406-sf3522088.patch
    echo "Installing msp430mcu" 
    sudo MSP430MCU_ROOT=`pwd` ./scripts/install.sh $INSTALL_PATH | tee so
    cd ..
```
## msp430-libc ##
Minimal libc for msp430.
```bash
    OLDPATH=$PATH
    export PATH=$INSTALL_PATH/bin:$PATH
    echo "Downloading libc" 
    wget https://sourceforge.net/projects/mspgcc/files/msp430-libc/msp430-libc-20120224.tar.bz2
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-libc-20120224-sf3522752.patch
    echo "Extracting libc" 
    tar xvf msp430-libc-20120224.tar.bz2
    echo "Installing libc" 
    cd msp430-libc-20120224
    patch -p1 < ../msp430-libc-20120224-sf3522752.patch
    ./configure
    cd src/
    make | tee mo
    sudo make PREFIX=$INSTALL_PATH install | tee mio
    echo "Done with libc" 
    cd ..
    PATH=$OLDPATH
```

----

## Install script ##
Here's the script in case you don't want to clone the repo. Just copy the following text to a script file and run it.

```bash
    #/usr/bin/env bash

    # A simple (and sometimes buggy) error checking tool
    check_for_errors(){
        echo "$1" | tail 
        if [ -n "$1" ]
        then
            echo "There seems to be errors, exiting"
            exit
        else
            echo "All OK"
        fi
    }

    # Installation path. This will overwrite your
    # changes to the INSTALL_PATH folder
    INSTALL_PATH=/usr/local/msp430

    # get LTS mspgcc
    wget http://sourceforge.net/projects/mspgcc/files/mspgcc/mspgcc-20120406.tar.bz2
    tar xvf mspgcc-20120406.tar.bz2
    cd mspgcc-20120406

    #binutils
    echo "Downloading binutils" 
    wget ftp://ftp.gnu.org/pub/gnu/binutils/binutils-2.21.1a.tar.bz2
    echo "Extracting binutils" 
    tar xjf binutils-2.21.1a.tar.bz2
    echo "Installing binutils" 
    ( cd binutils-2.21.1 ; patch -p1 < ../msp430-binutils-2.21.1a-20120406.patch )
    mkdir -p BUILD/binutils
    cd BUILD/binutils
    ../../binutils-2.21.1/configure \
      --target=msp430 \
      --prefix=$INSTALL_PATH \
    2>&1 | tee co
    make 2>&1 | tee mo
    sudo make install 2>&1 | tee moi
    echo "Done with binutils" 
    errors=`cat co mo moi | grep "Error [0-9]"`
    check_for_errors "$errors"
    cd ../../

    #gcc
    echo "Downloading gcc" 
    wget ftp://ftp.gnu.org/pub/gnu/gcc/gcc-4.6.3/gcc-4.6.3.tar.bz2
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3540953.patch
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3559978.patch
    echo "Extracting gcc" 
    tar xjf gcc-4.6.3.tar.bz2
    echo "Installing gcc" 
    cd gcc-4.6.3
    patch -p1 < ../msp430-gcc-4.6.3-20120406.patch
    patch -p1 < ../msp430-gcc-4.6.3-20120406-sf3540953.patch
    patch -p1 < ../msp430-gcc-4.6.3-20120406-sf3559978.patch
    cd ..
    mkdir -p BUILD/gcc
    cd BUILD/gcc
    ../../gcc-4.6.3/configure \
      --target=msp430 \
      --enable-languages=c,c++ \
      --prefix=$INSTALL_PATH \
    2>&1 | tee co
    make 2>&1 | tee mo
    sudo make install 2>&1 | tee moi
    echo "Done with gcc" 
    errors=`cat co mo moi | grep "Error [0-9]"`
    check_for_errors "$errors"
    cd ../../

    #gdb
    echo "Downloading gdb" 
    wget ftp://ftp.gnu.org/pub/gnu/gdb/gdb-7.2a.tar.bz2
    echo "Extracting gdb" 
    tar xjf gdb-7.2a.tar.bz2
    echo "Installing gdb" 
    ( cd gdb-7.2 ; patch -p1 < ../msp430-gdb-7.2a-20111205.patch )
    mkdir -p BUILD/gdb
    cd BUILD/gdb
    ../../gdb-7.2/configure \
      --target=msp430 \
      --prefix=$INSTALL_PATH \
    2>&1 | tee co
    make 2>&1 | tee mo
    sudo make install 2>&1 | tee moi
    echo "Done with gdb" 
    errors=`cat co mo moi | grep "Error [0-9]"`
    check_for_errors "$errors"
    cd ../../

    #msp430-mcu
    echo "Downloading msp430mcu" 
    wget http://sourceforge.net/projects/mspgcc/files/msp430mcu/msp430mcu-20120406.tar.bz2
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430mcu-20120406-sf3522088.patch
    echo "Extracting msp430mcu" 
    tar xvf msp430mcu-20120406.tar.bz2
    cd msp430mcu-20120406
    patch -p1 < ../msp430mcu-20120406-sf3522088.patch
    echo "Installing msp430mcu" 
    sudo MSP430MCU_ROOT=`pwd` ./scripts/install.sh $INSTALL_PATH | tee so
    cd ..

    OLDPATH=$PATH
    export PATH=$INSTALL_PATH/bin:$PATH

    #libc
    echo "Downloading libc" 
    wget https://sourceforge.net/projects/mspgcc/files/msp430-libc/msp430-libc-20120224.tar.bz2
    wget http://sourceforge.net/projects/mspgcc/files/Patches/LTS/20120406/msp430-libc-20120224-sf3522752.patch
    echo "Extracting libc" 
    tar xvf msp430-libc-20120224.tar.bz2
    echo "Installing libc" 
    cd msp430-libc-20120224
    patch -p1 < ../msp430-libc-20120224-sf3522752.patch
    ./configure
    cd src/
    make | tee mo
    sudo make PREFIX=$INSTALL_PATH install | tee mio
    echo "Done with libc" 
    errors=`cat mo mio | grep "Error [0-9]"`
    check_for_errors "$errors"
    cd ..

    PATH=$OLDPATH
    echo "Done installing, installed at $INSTALL_PATH"
```
