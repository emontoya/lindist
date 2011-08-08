.PHONY: all kernel lighttpd fileSystem clean FORCE

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

all: fileSystem kernel lighttpd

kernel: FORCE fileSystem
	cd ${KERNEL_DIR} && quilt push -a && $(MAKE) && make uImage

lighttpd: fileSystem 
	@(test -d ${LIGHTTPD_VER} || \
	((test -e ${LIGHTTPD_TAR} || wget http://download.lighttpd.net/lighttpd/releases-1.4.x/${LIGHTTPD_TAR} )\
 	&& tar -xzvf ${LIGHTTPD_TAR} && rm -f ${LIGHTTPD_TAR}))
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

# Target to enforce the initialization
FORCE:
	cd ${KERNEL_DIR} && quilt pop -a
clean:
	cd ${KERNEL_DIR} && quilt pop -a
	-rm -Rf fs
	-rm -Rf lighttp-1.4.29
