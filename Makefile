.PHONY: all kernel lighttpd fileSystem clean

# File System root directory
FS_ROOTD=$(shell pwd)/fs

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

all: fileSystem kernel lighttpd

kernel: fileSystem
	-cd ${KERNEL_DIR} && quilt push -a 
	cd ${KERNEL_DIR}&& $(MAKE) && make uImage

lighttpd: fileSystem 
	@(test -d ${LIGHTTPD_VER} || \
	((test -e ${LIGHTTPD_TAR} || wget http://download.lighttpd.net/lighttpd/releases-1.4.x/${LIGHTTPD_TAR} )\
 	&& tar -xzvf ${LIGHTTPD_TAR} && vrm -f ${LIGHTTPD_TAR}))
	cd ${LIGHTTPD_DIR} && ./configure --prefix=/usr --host=arm-none-linux-gnueabi --without-pcre --without-zlib --without-bzip2
	cd ${LIGHTTPD_DIR} && make install DESTDIR=${FS_ROOTD}

# Building the file system structure
fileSystem:
	test -d ${FS_ROOTD} || mkdir ${FS_ROOTD}
	test -d ${FS_ROOTD}/bin || mkdir ${FS_ROOTD}/bin
	test -d ${FS_ROOTD}/dev || mkdir ${FS_ROOTD}/dev
	test -d ${FS_ROOTD}/etc || mkdir ${FS_ROOTD}/etc
	test -d ${FS_ROOTD}/lib || mkdir ${FS_ROOTD}/lib
	test -d ${FS_ROOTD}/proc || mkdir ${FS_ROOTD}/proc
	test -d ${FS_ROOTD}/sbin || mkdir ${FS_ROOTD}/sbin
	test -d ${FS_ROOTD}/usr || mkdir ${FS_ROOTD}/usr
	test -d ${FS_ROOTD}/usr/bin || mkdir ${FS_ROOTD}/usr/bin

#This line will compile BusyBox: make install ARCH=arm CROSS_COMPILE=arm-none-linux-gnuabi- CONFIG_PRFIX=sudir
# Downloads and compiles BusyBox
busybox:
	wget ${BUSYBOX_URL}${BUSYBOX_TAR}
	tar xvjf ${BUSYBOX_TAR}
	cd ${BUSYBOX_DIR}

# Creation of the needed devices with mknod
devices:
	mknod mem c 1 1
	chmod 600 mem
	mknod null c 1 3
	chmod 666 null
	mknod zero c 1 5
	chmod 666 zero
	mknod random c 1 8
	chmod 644 random
	mknod tty0 c 4 0
	chmod 600 tty0
	mknod tty1 c 4 1
	chmod 600 tty1
	mknod ttyS0 c 4 64
	chmod 600 ttyS0
	mknod tty c 5 0
	chmod 666 tty
	mknod console c 5 1
	chmod 600 console

# Target to enforce the initialization
FORCE:
	cd ${KERNEL_DIR} && quilt pop -a

#------------------------------------------------------------------------------

clean:
	rm -f ${BUSYBOX_TAR}
	rm -fr ${BUSYBOX_DIR}
	rm -fr mem
	rm -fr null
	rm -fr zero
	rm -fr random
	rm -fr tty0
	rm -fr tty1
	rm -fr ttyS0
	rm -fr tty
	rm -fr console
	-cd ${KERNEL_DIR} && quilt pop -a
	-rm -Rf fs
	-rm -Rf lighttpd-1.4.29
