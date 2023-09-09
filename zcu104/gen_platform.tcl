#!/usr/bin/env xsct

# XSCT script to generate platform, adds a FSBL/PMU to the platform domain and create apps based on that domain

set xsa_file "edt_zcu104_wrapper.xsa"
set platform "edt_zcu104"
set workspace "."

setws $workspace
platform create -name $platform -hw $xsa_file
platform active $platform

domain create -name "fsbl_domain" -os standalone -proc psu_cortexa53_0
bsp setlib xilffs
bsp setlib xilpm
bsp setlib xilsecure
bsp config stdin psu_uart_1
bsp config stdout psu_uart_1
bsp config zynqmp_fsbl_bsp true

domain create -name "pmufw_domain" -os standalone -proc psu_pmu_0
bsp setlib xilfpga
bsp setlib xilsecure
bsp setlib xilskey
bsp config stdin psu_uart_1
bsp config stdout psu_uart_1

platform generate

# the template can be gotten from 'repo -apps' command in XSCT
app create -name zynqmp_fsbl -template {Zynq MP FSBL} -platform $platform -domain fsbl_domain
app create -name zynqmp_pmufw -template {ZynqMP PMU Firmware} -platform $platform -domain pmufw_domain

app config -name zynqmp_fsbl -name zynqmp_fsbl build-config release
app config -name zynqmp_pmufw -name zynqmp_pmufw build-config release

app build -name zynqmp_fsbl
app build -name zynqmp_pmufw

