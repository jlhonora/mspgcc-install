Install mspgcc in Ubuntu
========================

This repo has a script to install [mspgcc uniarch](http://mspgcc.sourceforge.net/) (C compiler for [msp430](http://www.ti.com/msp430) microcontrollers) in Ubuntu, along with some utilities for it. It installs the LTS (Long Term Support) version of the compiler, 
which is the most up-to-date version. Currently, this is LTS 20120406. __Update__: There are special branches for different mspgcc flavors:
	* Branch '20120911' contains a script to install the 20-bit development compiler, based on gcc 4.7.
	* Branch 'redhat' builds the (RedHat version of mspgcc)[http://msp430-gcc-users.1086195.n5.nabble.com/MSP430-GCC-goes-Red-Hat-td1176.html].

Checkout those branches for specific instructions:

    git checkout 'branchname'

## Building ##

To build mspgcc you will need to install _at least_ the following packages:

    sudo apt-get install patch ncurses-dev build-essential bison flex libgmp3-dev libmpfr-dev libmpc-dev texinfo zlib1g-dev

The installation folder is `/usr/local/msp430` (modifiable in the script). If you already have contents in this folder I recommend you to move it to a backup folder, i.e.:
    
    sudo mv /usr/local/msp430 /usr/local/msp430-backup

To install go to the console and run:

    git clone https://github.com/jlhonora/mspgcc-install.git
    cd mspgcc-install
    ./install-all

You should be careful to watch for error messages. 

If everything goes well, I recommend you to add the msp430-gcc path to your environment path. For that, append the following line to your `.bashrc`:

    export PATH=/usr/local/msp430/bin:/usr/local/msp430/lib:/usr/local/msp430/include:$PATH

Also paste it in the command line to use the modified $PATH right away.

## Testing ##

To check that everything is ok, type:

    cd tests
    msp430-gcc -mmcu=msp430g2553 hello_world.c 

The mmcu option should match the microcontroller you will be using.

## Installing the file in a Launchpad board ##

The previous command should generate a compiled file named `a.out`, ready to install in the microcontroller. If you have a [MSP430 Launchpad Board](http://www.ti.com/ww/en/launchpad/msp430_head.html) at reach you can install the compiled file with [mspdebug](http://mspdebug.sourceforge.net/). It can be installed with the `install-mspdebug` script (`$ ./install-mspdebug`) or by running the following commands:

    sudo apt-get install libusb-dev libreadline6-dev
    wget http://sourceforge.net/projects/mspdebug/files/mspdebug-0.22.tar.gz
    tar -xvf mspdebug-0.22.tar.gz
    cd mspdebug-0.22
    make
    sudo make install

Update: If you're using Ubuntu 13.04 I strongly recommend installing mspdebug via the `install-mspdebug` script, since there's a modification that should be made to the source for it to compile successfully.

USB permissions should be added to the FET interface of the Launchpad ([source](https://github.com/sergiocampama/Launchpad#mspdebug-usb-permissions)). As root, create the file `/etc/udev/rules.d/71-persistent-msp430.rules` and add `AATR{idVendor}=="0451", ATTRS{idProduct}=="f432", MODE="0660", GROUP="plugdev"` . Then run

    sudo addgroup YOUR_USERNAME plugdev
    sudo restart udev

If everything goes well, you can install the compiled program:

    sudo mspdebug rf2500 "prog a.out"

This should also work with the [MSP-EXP430F5529 board](http://www.ti.com/tool/msp-exp430f5529), but changing the compile options to `-mmcu=msp430f5529`.

## 20-bit support ##
To install the development version of the compiler, do:

    git checkout 20120911

And then follow the instructions above.

## Credits ##
    
This guide is loosely based on [Sergio Campama's](https://github.com/sergiocampama/Launchpad) guide and the README files of mspgcc.

