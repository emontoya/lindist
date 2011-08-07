.PHONY: FORCE all kernel lighttpd

# Kernel directory
KERNEL_DIR=$(shell pwd)/linux-2.6.29

# lighttpd directory
LIGHTTPD_VER=lighttpd-1.4.29
LIGHTTPD_DIR=$(shell pwd)/${LIGHTTPD_VER}
LIGHTTPD_TAR=${LIGHTTPD_VER}.tar.gz

# Set and export the cross compiler default path
CC_PATH=/opt/arm-2009q1
export CC_PATH

# Add the cross compiler to the PATH
export PATH := ${CC_PATH}/bin:$(PATH)

# Set and export the cross compiler
CROSS_COMPILE ?= arm-none-linux-gnueabi-
export CROSS_COMPILE

# Set and export the BusyBox uncompressed directory
#BUSYBOX_DIR=busybox-1.18.3
BUSYBOX_DIR=busybox-1.18.5
export BUSYBOX_DIR

# Set and export the BusyBox version
BUSYBOX_TAR=${BUSYBOX_DIR}.tar.bz2
export BUSYBOX_TAR

# Set and export the BusyBox UR Set and export the BusyBox URLL
BUSYBOX_URL=http://www.busybox.net/downloads/
export BUSYBOX_URL

#------------------------------------------------------------------------------

all: kernel lighttpd

kernel: FORCE
	cd ${KERNEL_DIR} && quilt push -a && $(MAKE) && make uImage

lighttpd: 
	@(test -d ${LIGHTTPD_VER} || \
	((test -e ${LIGHTTPD_TAR} || wget http://download.lighttpd.net/lighttpd/releases-1.4.x/${LIGHTTPD_TAR} )\
 	&& tar -xzvf ${LIGHTTPD_TAR} && vrm -f ${LIGHTTPD_TAR}))
	@echo "Lighttp cross compiled"

#This line will compile BusyBox: make install ARCH=arm CROSS_COMPILE=arm-none-linux-gnuabi- CONFIG_PRFIX=sudir
# Downloads and compiles BusyBox
busybox:
	wget ${BUSYBOX_URL}${BUSYBOX_TAR}
	tar xvjf ${BUSYBOX_TAR}
	cd ${BUSYBOX_DIR}

# Target to enforce the initialization
FORCE:
	cd ${KERNEL_DIR} && quilt pop -a

#------------------------------------------------------------------------------

clean:
	rm -f ${BUSYBOX_TAR}
	rm -fr ${BUSYBOX_DIR}
