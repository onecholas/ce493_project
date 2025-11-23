quit -sim

setenv LMC_TIMEUNIT -9
vlib work
vmap work work

vlog -sv -work work ./../../rtl/pe.sv
vlog -sv -work work ./../../rtl/pe_array.sv
vlog -sv -work work ./pe_array_tb.sv

vsim -voptargs=+acc +notimingchecks -L work work.pe_array_tb -wlf pe_array_sim.wlf

do pe_array_wave.do

run -all