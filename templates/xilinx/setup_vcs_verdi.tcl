set project_name "vivado_vcs_project"
set project_dir  "./vivado_prj"
set rtl_dir      "../../demo/src"
set tb_file      "../../demo/testbench/tb_demo.sv"

set simlib_path $::env(XILINX_SIMLIB_PATH)

create_project -force $project_name $project_dir -part xc7k70tfbv676-1
add_files [glob $rtl_dir/*.v $rtl_dir/*.sv]
add_files -fileset sim_1 $tb_file
update_compile_order -fileset sources_1

set_property target_simulator VCS [current_project]
set_property compxlib.vcs_compiled_library_dir $simlib_path [current_project]

set verdi_home $::env(VERDI_HOME)
set pli_cmd "-P $verdi_home/share/PLI/VCS/LINUX64/novas.tab $verdi_home/share/PLI/VCS/LINUX64/pli.a"
set_property -name {vcs.elaborate.vcs.more_options} -value $pli_cmd -objects [get_filesets sim_1]

launch_simulation -simset [get_filesets sim_1]

set sim_run_dir "$project_dir/$project_name.sim/sim_1/behav/vcs"
set fsdb_file "$sim_run_dir/top.fsdb"

if {[file exists $fsdb_file]} {
    puts "Sim Finished. Launching Verdi..."
    # 启动 Verdi，指定库目录和 fsdb
    exec verdi -dbdir $sim_run_dir/simv.daidir -ssf $fsdb_file &
}
