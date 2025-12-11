add wave -noupdate -group eyeriss_top_tb
add wave -noupdate -group eyeriss_top_tb -radix unsigned /eyeriss_top_tb/*

add wave -noupdate -group eyeriss_top
add wave -noupdate -group eyeriss_top -radix unsigned /eyeriss_top_tb/eyeriss_top_inst/*

add wave -noupdate -group buf_array_inst
add wave -noupdate -group buf_array_inst -radix unsigned /eyeriss_top_tb/eyeriss_top_inst/buf_array_inst/*

# Loop through Rows (0 to 4)
for {set r 0} {$r <= 4} {incr r} {
    # Loop through Cols (0 to 5)
    for {set c 0} {$c <= 5} {incr c} {
        
        # Create a group name: pe_00, pe_65, etc
        set group_name "pe_${r}${c}"
        
        # Define the path dynamically
        set path "/eyeriss_top_tb/eyeriss_top_inst/noc_inst/pe_array_inst/rows\[$r\]/cols\[$c\]/pe_inst/*"
        
        # Add the group header
        add wave -noupdate -group $group_name
        
        # Add the signals to the group
        add wave -noupdate -group $group_name -radix unsigned $path
    }
}

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
