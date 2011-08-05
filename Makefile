.PHONY: FORCE all kernel

# Kernel directory
KERNEL_DIR=$(shell pwd)/linux-2.6.29

# Set and export the cross compiler default path
CC_PATH=/opt/arm-2009q1
export CC_PATH

# Add the cross compiler to the PATH
export PATH := ${CC_PATH}/bin:$(PATH)

# Set and export the cross compiler
CROSS_COMPILE ?= arm-none-linux-gnueabi-
export CROSS_COMPILE

all: kernel

kernel: FORCE
	cd ${KERNEL_DIR} && quilt push -a && $(MAKE)

# Target to enforce the initialization
FORCE:
	cd ${KERNEL_DIR} && quilt pop -a
