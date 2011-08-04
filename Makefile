.PHONY: all kernel

# Set and export the cross compiler
CROSS_COMPILE ?= arm-none-linux-gnueabi-
export CROSS_COMPILE

all: kernel

kernel:
	cd linux-2.6.29 && $(MAKE)
