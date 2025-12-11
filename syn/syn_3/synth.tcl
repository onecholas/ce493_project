# read HDL files
read_hdl -sv ../rtl/buf_array.sv
read_hdl -sv ../rtl/buffer.sv
read_hdl -sv ../rtl/eyeriss_top.sv
read_hdl -sv ../rtl/fifo.sv
read_hdl -sv ../rtl/noc.sv
read_hdl -sv ../rtl/pe_array.sv
read_hdl -sv ../rtl/pe.sv

# read lib and lef files
set_db library /vol/ece303/genus_tutorial/NangateOpenCellLibrary_typical.lib
set_db lef_library /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef

# elabroate and set current design
elaborate eyeriss_top
current_design eyeriss_top

# read SDC file
read_sdc ../eyeriss_top.sdc

# synthesis optimizations
syn_generic
syn_map
syn_opt

# timing report
report_timing > timing.rpt

# area report
report_area > area.rpt

# write_hdl
write_hdl > eyeriss_top_syn.v