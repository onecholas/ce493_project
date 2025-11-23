add wave -noupdate -group pe_tb
add wave -noupdate -group pe_tb -radix unsigned /pe_tb/*

add wave -noupdate -group pe
add wave -noupdate -group pe -radix unsigned /pe_tb/pe_inst/*

WaveRestoreCursors {{Cursor 1} {0 ns} 0}
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ns} {1 us}
