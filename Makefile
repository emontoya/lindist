.PHONY: all kernel lighttpd tarea2_t busybox devices config_files clean

# File System root directory
FS_ROOTD=$(shell pwd)/fs

# Kernel directory
KERNEL_DIR=$(shell pwd)/linux-2.6.29

# lighttpd directory
LIGHTTPD_VER=lighttpd-1.4.29
LIGHTTPD_DIR=$(shell pwd)/${LIGHTTPD_VER}
LIGHTTPD_TAR=${LIGHTTPD_VER}.tar.gz

# tarea 2 dir
TAREA2_DIR=$(shell pwd)/tarea2

# Set and export the cross compiler default path
CC_PATH=/opt/arm-2009q1
export CC_PATH
CC_PREFIX=arm-none-linux-gnueabi

# Add the cross compiler to the PATH
export PATH := ${CC_PATH}/bin:$(PATH)

# Set and export the ARCH value
ARCH := arm
export ARCH

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

# Set the toochain's library path
TOOLCHAIN_LIB_DIR=${CC_PATH}/arm-none-linux-gnueabi/libc/lib
export TOOLCHAIN_LIB_DIR

#------------------------------------------------------------------------------

all: busybox libraries config_files kernel lighttpd tarea2_t

kernel: fileSystem
	-cd ${KERNEL_DIR} && quilt push -a 
	-cd ${KERNEL_DIR}&& $(MAKE) && make uImage && cp arch/${ARCH}/boot/uImage ${FS_ROOTD}/ && echo "uImage copied to ${FS_ROOTD}/uImage"

lighttpd: fileSystem 
	@(test -d ${LIGHTTPD_VER} || \
	((test -e ${LIGHTTPD_TAR} || wget http://download.lighttpd.net/lighttpd/releases-1.4.x/${LIGHTTPD_TAR} )\
 	&& tar -xzvf ${LIGHTTPD_TAR}\
	))
	cd ${LIGHTTPD_DIR} && ./configure --prefix=/usr --host=${CC_PREFIX} --without-pcre --without-zlib --without-bzip2
	cd ${LIGHTTPD_DIR} && make && make install DESTDIR=${FS_ROOTD}

tarea2_t: fileSystem
	test -d ${TAREA2_DIR} || git clone -o github git://github.com/emontoya/empotradosTarea2.git ${TAREA2_DIR}
	cd ${TAREA2_DIR} && ./configure --prefix=/usr --host=arm-none-linux-gnueabi
	cd ${TAREA2_DIR} && make && make install DESTDIR=${FS_ROOTD}

# Building the file system structure
fileSystem:
	test -d ${FS_ROOTD} || mkdir ${FS_ROOTD}
	test -d ${FS_ROOTD}/bin || mkdir ${FS_ROOTD}/bin
	test -d ${FS_ROOTD}/boot || mkdir ${FS_ROOTD}/boot
	test -d ${FS_ROOTD}/boot/images || mkdir ${FS_ROOTD}/boot/images
	test -d ${FS_ROOTD}/dev || mkdir ${FS_ROOTD}/dev
	test -d ${FS_ROOTD}/etc || mkdir ${FS_ROOTD}/etc
	test -d ${FS_ROOTD}/etc/init.d || (mkdir ${FS_ROOTD}/etc/init.d && chmod 777 ${FS_ROOTD}/etc/init.d)
	test -d ${FS_ROOTD}/lib || mkdir ${FS_ROOTD}/lib
	test -d ${FS_ROOTD}/proc || mkdir ${FS_ROOTD}/proc
	test -d ${FS_ROOTD}/sbin || mkdir ${FS_ROOTD}/sbin
	test -d ${FS_ROOTD}/sys || mkdir ${FS_ROOTD}/sys
	test -d ${FS_ROOTD}/tmp || (mkdir ${FS_ROOTD}/tmp && chmod 1777 ${FS_ROOTD}/tmp)
	test -d ${FS_ROOTD}/usr || mkdir ${FS_ROOTD}/usr
	test -d ${FS_ROOTD}/usr/bin || mkdir ${FS_ROOTD}/usr/bin
	test -d ${FS_ROOTD}/usr/lib || mkdir ${FS_ROOTD}/usr/lib
	test -d ${FS_ROOTD}/usr/sbin || mkdir ${FS_ROOTD}/usr/sbin
	test -d ${FS_ROOTD}/usr/share || mkdir ${FS_ROOTD}/usr/share
	test -d ${FS_ROOTD}/var || mkdir ${FS_ROOTD}/var
	test -d ${FS_ROOTD}/var/lib || mkdir ${FS_ROOTD}/var/lib
	test -d ${FS_ROOTD}/var/lock || mkdir ${FS_ROOTD}/var/lock
	test -d ${FS_ROOTD}/var/log || mkdir ${FS_ROOTD}/var/log
	test -d ${FS_ROOTD}/var/run || mkdir ${FS_ROOTD}/var/run
	test -d ${FS_ROOTD}/var/tmp || (mkdir ${FS_ROOTD}/var/tmp && chmod 1777 ${FS_ROOTD}/var/tmp)

# Downloads and compiles BusyBox
busybox: libraries
	@(test -d ${BUSYBOX_DIR} || \
	((test -e ${BUSYBOX_TAR} || wget ${BUSYBOX_URL}${BUSYBOX_TAR})\
 	&& tar xvjf ${BUSYBOX_TAR}\
	))
	cd ${BUSYBOX_DIR} && make defconfig && make install CONFIG_PREFIX=${FS_ROOTD}

libraries: fileSystem
	cp -dfra ${CC_PATH}/${CC_PREFIX}/libc/lib/* ${FS_ROOTD}/lib/ && ${CC_PREFIX}-strip ${FS_ROOTD}/lib/*.so
#	[ "$(ls -A mi_dir)" ] && echo "Not Empty" || echo "Empty"
	
# Creation of the needed devices with mknod
devices: fileSystem
	cd ${FS_ROOTD}/dev && (test -e mem || (mknod mem c 1 1 && chmod 600 mem)) 
	cd ${FS_ROOTD}/dev && (test -e null || (mknod null c 1 3 && chmod 666 null))
	cd ${FS_ROOTD}/dev && (test -e zero || (mknod zero c 1 5 && chmod 666 zero))
	cd ${FS_ROOTD}/dev && (test -e random || (mknod random c 1 8&&  chmod 644 random))
	cd ${FS_ROOTD}/dev && (test -e tty0 || (mknod tty0 c 4 0 && chmod 600 tty0))
	cd ${FS_ROOTD}/dev && (test -e tty1 || (mknod tty1 c 4 1 && chmod 600 tty1))
	cd ${FS_ROOTD}/dev && (test -e ttyS0 || (mknod ttyS0 c 4 64 && chmod 600 ttyS0))
	cd ${FS_ROOTD}/dev && (test -e tty || (mknod tty c 5 0 && chmod 666 tty))
	cd ${FS_ROOTD}/dev && (test -e console || (mknod console c 5 1 && chmod 600 console))

config_files: devices 
	cp config/fstab ${FS_ROOTD}/etc
	cd ${FS_ROOTD}/etc && chown -f root:root fstab && chmod 666 fstab
	cp config/inittab ${FS_ROOTD}/etc 
	cd ${FS_ROOTD}/etc && chown -f root:root inittab && chmod 666 inittab
	cp config/rcS ${FS_ROOTD}/etc/init.d
	cd ${FS_ROOTD}/etc/init.d && chown -f root:root rcS && chmod 777 rcS 

# Target to enforce the initialization
FORCE:
	cd ${KERNEL_DIR} && quilt pop -a

#------------------------------------------------------------------------------

clean:
	rm -f ${BUSYBOX_TAR}
	rm -fr ${BUSYBOX_DIR}
	cd ${FS_ROOTD}/dev && rm -fr mem && rm -fr null && rm -fr zero && rm -fr random && rm -fr tty0 && rm -fr tty1 && rm -fr ttyS0 && rm -fr tty && rm -fr console
	-cd ${KERNEL_DIR} && quilt pop -a
	-rm -Rf ${FS_ROOTD}
	-rm -f ${LIGHTTPD_TAR}
	-rm -Rf ${LIGHTTPD_DIR}
	-rm -Rf ${TAREA2_DIR}
