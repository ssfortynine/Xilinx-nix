# setup_vcs_verdi.tcl
set project_name "vivado_vcs_project"
set project_dir  "./vivado_prj"
set top_module   "tb_demo"
set sim_set      "sim_1"

set script_path [file normalize [info script]]
set base_dir    [file dirname $script_path]
set rtl_dir     [file normalize "$base_dir/demo/src"]
set tb_file     [file normalize "$base_dir/demo/src/tb_demo.sv"]
set dump_do     [file normalize "$base_dir/vcs_dump.do"]

set simlib_path $::env(XILINX_SIMLIB_PATH)

create_project -force $project_name $project_dir -part xc7k70tfbv676-1
add_files [glob -nocomplain "$rtl_dir/*.v" "$rtl_dir/*.sv"]
add_files -fileset $sim_set $tb_file
set_property top $top_module [get_filesets $sim_set]

set_property target_simulator VCS [current_project]
set_property compxlib.vcs_compiled_library_dir $simlib_path [current_project]

set_property -name {vcs.compile.vlogan.more_options} -value {-sverilog -kdb -lca} -objects [get_filesets $sim_set]
set_property -name {vcs.elaborate.vcs.more_options} -value {-full64 -kdb -lca} -objects [get_filesets $sim_set]

set_property -name {vcs.simulate.vcs.more_options} -value "-ucli -do $dump_do" -objects [get_filesets $sim_set]

file delete -force "$project_dir/$project_name.sim/$sim_set/behav/vcs"

launch_simulation -scripts_only -simset [get_filesets $sim_set]

puts "Vivado simulation scripts generated successfully."


