# ---------------- Create_project ----------------
set project_name "vivado_vcs_project"
set project_dir  "./vivado_prj"
set top_module   "tb_test_demo"
set sim_set      "sim_1"
set part_name    "xc7k70tfbv676-1"

set script_path [file normalize [info script]]
set base_dir    [file dirname $script_path]
set rtl_dir     [file normalize "$base_dir/demo/src"]
set tb_file     [file normalize "$base_dir/demo/src/tb_test_demo.sv"]
set dump_do     [file normalize "$base_dir/vcs_dump.do"]

set simlib_path $::env(XILINX_SIMLIB_PATH)

create_project -force $project_name $project_dir -part $part_name

set_property SIMULATOR_LANGUAGE Verilog [current_project]

# ---------------- IP: clk_wiz_0 ----------------
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
] [get_ips clk_wiz_0]

generate_target {all} [get_ips clk_wiz_0]
export_ip_user_files -of_objects [get_ips clk_wiz_0] -no_script -sync -force -quiet

set gen_ip_dir [file normalize "$project_dir/${project_name}.gen/sources_1/ip/clk_wiz_0"]

set ip_vfiles [glob -nocomplain \
    "$gen_ip_dir/clk_wiz_0.v" \
    "$gen_ip_dir/*clk_wiz*.v" \
    "$gen_ip_dir/*.v" \
    "$gen_ip_dir/*.sv" \
]
if {[llength $ip_vfiles] == 0} {
    puts "ERROR: No generated IP verilog files found under: $gen_ip_dir"
} else {
    add_files -fileset sources_1 -norecurse $ip_vfiles
}

# ---------------- Design + TB ----------------
add_files -fileset sources_1 [glob -nocomplain "$rtl_dir/*.v" "$rtl_dir/*.sv"]
add_files -fileset $sim_set $tb_file
set_property top $top_module [get_filesets $sim_set]

update_compile_order -fileset sources_1
update_compile_order -fileset $sim_set

# ---------------- Simulator: VCS ----------------
set_property TARGET_SIMULATOR VCS [current_project]
set_property compxlib.vcs_compiled_library_dir $simlib_path [current_project]

set_property -name {vcs.compile.vlogan.more_options} \
    -value {-full64 -sverilog -kdb -lca} \
    -objects [get_filesets $sim_set]

set_property -name {vcs.elaborate.vcs.more_options} \
    -value {-full64 -kdb -lca} \
    -objects [get_filesets $sim_set]

set_property -name {vcs.simulate.vcs.more_options} \
    -value "-ucli -do $dump_do" \
    -objects [get_filesets $sim_set]

file delete -force "$project_dir/$project_name.sim/$sim_set/behav/vcs"
launch_simulation -scripts_only -simset [get_filesets $sim_set]
puts "Vivado simulation scripts generated successfully."
