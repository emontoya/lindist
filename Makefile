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

all: kernel lighttpd

kernel: FORCE
	cd ${KERNEL_DIR} && quilt push -a && $(MAKE) && make uImage

lighttpd: 
	@(test -d ${LIGHTTPD_VER} || \
	((test -e ${LIGHTTPD_TAR} || wget http://download.lighttpd.net/lighttpd/releases-1.4.x/${LIGHTTPD_TAR} )\
 	&& tar -xzvf ${LIGHTTPD_TAR} && rm -f ${LIGHTTPD_TAR}))
	cd ${LIGHTTPD_DIR} && ./configure --prefix=/usr/bin --host=arm-none-linux-gnueabi --without-pcre --without-zlib --without-bzip2


# Target to enforce the initialization
FORCE:
	cd ${KERNEL_DIR} && quilt pop -a
