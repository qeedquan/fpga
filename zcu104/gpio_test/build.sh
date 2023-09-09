#!/bin/sh

set -e

function setup_env() {
	if [ -z ${XILINX_VIVADO} ]; then
		echo "Environment variable \$XILINX_VIVADO needs to be set!"
		exit 1
	fi

	source $XILINX_VIVADO/settings64.sh
}

function build_pl() {
	vivado -mode batch -source gen_pl.tcl
	vivado -mode batch -source build_pl.tcl
}

function build_ps() {
	xsct ./gen_ps.xsct
}

setup_env
build_pl
build_ps

