#!/bin/sh

ROOT_DIR="$(pwd)"
QEMU_DIR="zcu104_qemu"
BSP_FILE="xilinx-zcu104-v2020.2-final.bsp"
SETTINGS_FILE="../settings.sh"
SD_FILE="$ROOT_DIR/sd.img"
SD_SIZE=1024

# add ssh (ssh -p 1114 root@localhost) from host to login
# tftp -g -l foo.txt 10.0.2.2
SSH_ARGS="hostfwd=tcp::1114-:22"

# add tftp directory to serve 
# tftp -g -l bar.txt 10.0.2.2
TFTP_ARGS="tftp=$ROOT_DIR/tftp"

# sd card
SD_ARGS=""
if [[ $SD_FILE != "" ]]; then
	SD_ARGS="-device sd-card,drive=mydrive -drive id=mydrive,if=none,format=raw,file=$SD_FILE"
fi

QEMU_ARGS="-net nic -net nic -net nic -net nic,netdev=eth0 -netdev user,id=eth0,$SSH_ARGS,$TFTP_ARGS $SD_ARGS"

create() {
	petalinux-create -t project -s $BSP_FILE -n $QEMU_DIR
}

run() {
	if [[ $SD_FILE != "" && ! -f $SD_FILE ]]; then
		dd if=/dev/zero of=$SD_FILE bs=1M count=$SD_SIZE
		mkfs.vfat $SD_FILE
	fi
	
	cd $QEMU_DIR
	echo $QEMU_ARGS
	petalinux-boot --qemu --prebuilt 3 --qemu-args "$QEMU_ARGS"
}

main() {
	. "$SETTINGS_FILE"
	if [[ -d $QEMU_DIR ]]; then
		run
	else
		create
	fi
}

(main)
