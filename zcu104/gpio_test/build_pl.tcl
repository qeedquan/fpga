set cwd [pwd]
set proj "zcu104_pl"

cd ${proj}
open_project ${proj}.xpr
launch_runs impl_1 -to_step write_bitstream -jobs 10
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file ${cwd}/${proj}.xsa

