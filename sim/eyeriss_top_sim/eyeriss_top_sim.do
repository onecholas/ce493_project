quit -sim

setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -sv -work work ./../../rtl/pe.sv
vlog -sv -work work ./../../rtl/pe_array.sv
vlog -sv -work work ./../../rtl/fifo.sv
vlog -sv -work work ./../../rtl/noc.sv
vlog -sv -work work ./../../rtl/buffer.sv
vlog -sv -work work ./../../rtl/buf_array.sv
vlog -sv -work work ./../../rtl/eyeriss_top.sv
vlog -sv -work work ./eyeriss_top_tb.sv

vsim -voptargs=+acc +notimingchecks -L work work.eyeriss_top_tb -wlf eyeriss_top_sim.wlf

do eyeriss_top_wave.do

run -all