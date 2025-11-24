quit -sim

setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -sv -work work ./../../rtl/pe.sv
vlog -sv -work work ./../../rtl/pe_array.sv
vlog -sv -work work ./../../rtl/fifo.sv
vlog -sv -work work ./../../rtl/noc.sv
vlog -sv -work work ./noc_tb.sv

vsim -voptargs=+acc +notimingchecks -L work work.noc_tb -wlf noc_sim.wlf

do noc_wave.do

run -all