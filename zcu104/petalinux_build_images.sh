#!/bin/sh

# creates a BOOT.BIN boot image from all the images built
# the xsa file is created from vivado, it is the customized hardware description of the platform
# the system.bit is the FPGA bitstream that can be created in vivado
# the others can be built from source code using petalinux, petalinux also provides pre-built images
# that we can use

BSP_DIR="zcu104_linux_build"
BSP_FILE="xilinx-zcu104-v2020.2-final.bsp"
XSA_FILE="edt_zcu104_wrapper.xsa"
FSBL_FILE="zynqmp_fsbl.elf"
BIT_FILE="system.bit"
PMUFW_FILE="pmufw.elf"
ATF_FILE="bl31.elf"
UBOOT_FILE="u-boot.elf"

if [[ ! -d $BSP_DIR ]]; then
	petalinux-create -t project -s $BSP_FILE -n $BSP_DIR
fi

cd $BSP_DIR
petalinux-config --get-hw-description=$XSA_FILE --silentconfig
petalinux-build
petalinux-package --boot --fsbl $FSBL_FILE --fpga $BIT_FILE --pmufw $PMUFW_FILE --atf $ATF_FILE --u-boot $UBOOT_FILE

