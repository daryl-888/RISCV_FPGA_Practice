# Eight-week course. Source in a supported Vivado Tcl Console.
# Creates a complete RTL project; it does not run synthesis or program hardware.
# Optional before sourcing: set course_pipeline 0  (single-cycle implementation)
# Default: course_pipeline=1. Distinct project folders permit both variants.

set course_root [file normalize [file join [file dirname [info script]] ..]]
if {![info exists course_pipeline]} { set course_pipeline 1 }
if {$course_pipeline ni {0 1}} { error "course_pipeline must be 0 or 1" }
if {$course_pipeline} { set course_variant pipeline } else { set course_variant single }
set course_project_name basys3_$course_variant
set course_project_dir [file join $course_root build vivado $course_project_name]
set course_image [file join $course_root programs boot.hex]

if {[llength [info commands create_project]] == 0} {
    error "Run this script inside Vivado, not a general Tcl shell."
}
if {[llength [get_projects -quiet]] != 0} {
    error "Close the current Vivado project before sourcing this script."
}
if {[file exists $course_project_dir]} {
    error "Output already exists: $course_project_dir. Open its .xpr or choose a fresh output directory; this script never overwrites a project."
}
if {[llength [get_parts -quiet xc7a35tcpg236-1]] != 1} {
    error "Artix-7 part xc7a35tcpg236-1 unavailable. Install its Vivado device support."
}

# Explicit order is intentional: both CPUs import the package.
set course_rtl {}
foreach name {common/rv32_pkg.sv common/alu.sv common/pc.sv common/imem.sv common/regfile.sv common/decode.sv common/execute_stage.sv single_cycle/cpu_single.sv pipeline/forwarding.sv pipeline/hazard.sv pipeline/cpu_pipeline.sv soc/teaching_memory.sv soc/basys3_top.sv} {
    set path [file join $course_root rtl $name]
    if {![file isfile $path]} { error "Required reference RTL missing: $path" }
    lappend course_rtl $path
}
if {![file isfile $course_image]} {
    error "Boot ROM image missing: $course_image. Restore/build the included programs/boot.hex before continuing."
}

create_project $course_project_name $course_project_dir -part xc7a35tcpg236-1
set_property target_language Verilog [current_project]
add_files -norecurse $course_rtl
set_property file_type SystemVerilog [get_files $course_rtl]
set_property top basys3_top [current_fileset]
set_property generic "PIPELINED=$course_pipeline" [current_fileset]
set_property include_dirs [list [file join $course_root rtl]] [current_fileset]
add_files -norecurse $course_image
set_property file_type {Memory Initialization Files} [get_files $course_image]
add_files -fileset constrs_1 -norecurse [file join $course_root fpga basys3_minimal.xdc]
set course_boundary_xdc [file join $course_root fpga board_timing.xdc]
if {[file isfile $course_boundary_xdc]} {
    add_files -fileset constrs_1 -norecurse $course_boundary_xdc
}
update_compile_order -fileset sources_1
puts "Created [file join $course_project_dir $course_project_name.xpr]"
puts "Selected PIPELINED=$course_pipeline; top imports boot.hex from project memory files."
puts "Inspect elaboration, ROM initialization, synthesis, CDC and timing before building a bitstream."
puts "No synthesis, timing result, bitstream generation, or physical board test is claimed."
