#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Dec 10 12:23:16 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v16.20-p002_1 (64bit) 11/08/2016 11:31 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 16.20-p002_1 NR161103-1425/16_20-UB (database version 2.30, 354.6.1) {superthreading v1.34}
#@(#)CDS: AAE 16.20-p004 (64bit) 11/08/2016 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 16.20-p008_1 () Oct 29 2016 08:26:57 ( )
#@(#)CDS: SYNTECH 16.20-p001_1 () Oct 27 2016 11:33:00 ( )
#@(#)CDS: CPE v16.20-p011
#@(#)CDS: IQRC/TQRC 15.2.5-s803 (64bit) Tue Sep 13 18:23:58 PDT 2016 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set init_gnd_net VSS
set init_lef_file /vol/ece303/genus_tutorial/NangateOpenCellLibrary.lef
set init_design_settop 0
set init_verilog ../synth_3/eyeriss_top_syn.v
set init_mmmc_file eyeriss_top.view
set init_pwr_net VDD
init_design
setDesignMode -process 45
fit
setDrawView fplan
getIoFlowFlag
floorPlan -r 1.0 0.63 2 2 2 2
uiSetTool select
getIoFlowFlag
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo
getPinAssignMode -pinEditInBatch -quiet
fit
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 0.42 -pin {clk_i {ifmap_data_i[0]} {ifmap_data_i[1]} {ifmap_data_i[2]} {ifmap_data_i[3]} {ifmap_data_i[4]} {ifmap_data_i[5]} {ifmap_data_i[6]} {ifmap_data_i[7]} {ifmap_data_i[8]} {ifmap_data_i[9]} {ifmap_data_i[10]} {ifmap_data_i[11]} {ifmap_data_i[12]} {ifmap_data_i[13]} {ifmap_data_i[14]} {ifmap_data_i[15]} {ifmap_wr_addr_i[0]} {ifmap_wr_addr_i[1]} {ifmap_wr_addr_i[2]} {ifmap_wr_addr_i[3]} {ifmap_wr_addr_i[4]} {ifmap_wr_addr_i[5]} {ifmap_wr_addr_i[6]} {ifmap_wr_addr_i[7]} {ifmap_wr_addr_i[8]} {ifmap_wr_addr_i[9]} ifmap_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 0.42 -pin {{psum_rd_en_i[0]} {psum_rd_en_i[1]} {psum_rd_en_i[2]} {psum_rd_en_i[3]} {psum_rd_en_i[4]} {psum_rd_en_i[5]} rst_i start_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 0.42 -pin {{weight_data_i[0]} {weight_data_i[1]} {weight_data_i[2]} {weight_data_i[3]} {weight_data_i[4]} {weight_data_i[5]} {weight_data_i[6]} {weight_data_i[7]} {weight_data_i[8]} {weight_data_i[9]} {weight_data_i[10]} {weight_data_i[11]} {weight_data_i[12]} {weight_data_i[13]} {weight_data_i[14]} {weight_data_i[15]} {weight_wr_addr_i[0]} {weight_wr_addr_i[1]} {weight_wr_addr_i[2]} {weight_wr_addr_i[3]} {weight_wr_addr_i[4]} weight_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 0.42 -pin {clk_i {ifmap_data_i[0]} {ifmap_data_i[1]} {ifmap_data_i[2]} {ifmap_data_i[3]} {ifmap_data_i[4]} {ifmap_data_i[5]} {ifmap_data_i[6]} {ifmap_data_i[7]} {ifmap_data_i[8]} {ifmap_data_i[9]} {ifmap_data_i[10]} {ifmap_data_i[11]} {ifmap_data_i[12]} {ifmap_data_i[13]} {ifmap_data_i[14]} {ifmap_data_i[15]} {ifmap_wr_addr_i[0]} {ifmap_wr_addr_i[1]} {ifmap_wr_addr_i[2]} {ifmap_wr_addr_i[3]} {ifmap_wr_addr_i[4]} {ifmap_wr_addr_i[5]} {ifmap_wr_addr_i[6]} {ifmap_wr_addr_i[7]} {ifmap_wr_addr_i[8]} {ifmap_wr_addr_i[9]} ifmap_wr_en_i {psum_rd_en_i[0]} {psum_rd_en_i[1]} {psum_rd_en_i[2]} {psum_rd_en_i[3]} {psum_rd_en_i[4]} {psum_rd_en_i[5]} rst_i start_i {weight_data_i[0]} {weight_data_i[1]} {weight_data_i[2]} {weight_data_i[3]} {weight_data_i[4]} {weight_data_i[5]} {weight_data_i[6]} {weight_data_i[7]} {weight_data_i[8]} {weight_data_i[9]} {weight_data_i[10]} {weight_data_i[11]} {weight_data_i[12]} {weight_data_i[13]} {weight_data_i[14]} {weight_data_i[15]} {weight_wr_addr_i[0]} {weight_wr_addr_i[1]} {weight_wr_addr_i[2]} {weight_wr_addr_i[3]} {weight_wr_addr_i[4]} weight_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 1.0 -pin {clk_i {ifmap_data_i[0]} {ifmap_data_i[1]} {ifmap_data_i[2]} {ifmap_data_i[3]} {ifmap_data_i[4]} {ifmap_data_i[5]} {ifmap_data_i[6]} {ifmap_data_i[7]} {ifmap_data_i[8]} {ifmap_data_i[9]} {ifmap_data_i[10]} {ifmap_data_i[11]} {ifmap_data_i[12]} {ifmap_data_i[13]} {ifmap_data_i[14]} {ifmap_data_i[15]} {ifmap_wr_addr_i[0]} {ifmap_wr_addr_i[1]} {ifmap_wr_addr_i[2]} {ifmap_wr_addr_i[3]} {ifmap_wr_addr_i[4]} {ifmap_wr_addr_i[5]} {ifmap_wr_addr_i[6]} {ifmap_wr_addr_i[7]} {ifmap_wr_addr_i[8]} {ifmap_wr_addr_i[9]} ifmap_wr_en_i {psum_rd_en_i[0]} {psum_rd_en_i[1]} {psum_rd_en_i[2]} {psum_rd_en_i[3]} {psum_rd_en_i[4]} {psum_rd_en_i[5]} rst_i start_i {weight_data_i[0]} {weight_data_i[1]} {weight_data_i[2]} {weight_data_i[3]} {weight_data_i[4]} {weight_data_i[5]} {weight_data_i[6]} {weight_data_i[7]} {weight_data_i[8]} {weight_data_i[9]} {weight_data_i[10]} {weight_data_i[11]} {weight_data_i[12]} {weight_data_i[13]} {weight_data_i[14]} {weight_data_i[15]} {weight_wr_addr_i[0]} {weight_wr_addr_i[1]} {weight_wr_addr_i[2]} {weight_wr_addr_i[3]} {weight_wr_addr_i[4]} weight_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 5 -pin {clk_i {ifmap_data_i[0]} {ifmap_data_i[1]} {ifmap_data_i[2]} {ifmap_data_i[3]} {ifmap_data_i[4]} {ifmap_data_i[5]} {ifmap_data_i[6]} {ifmap_data_i[7]} {ifmap_data_i[8]} {ifmap_data_i[9]} {ifmap_data_i[10]} {ifmap_data_i[11]} {ifmap_data_i[12]} {ifmap_data_i[13]} {ifmap_data_i[14]} {ifmap_data_i[15]} {ifmap_wr_addr_i[0]} {ifmap_wr_addr_i[1]} {ifmap_wr_addr_i[2]} {ifmap_wr_addr_i[3]} {ifmap_wr_addr_i[4]} {ifmap_wr_addr_i[5]} {ifmap_wr_addr_i[6]} {ifmap_wr_addr_i[7]} {ifmap_wr_addr_i[8]} {ifmap_wr_addr_i[9]} ifmap_wr_en_i {psum_rd_en_i[0]} {psum_rd_en_i[1]} {psum_rd_en_i[2]} {psum_rd_en_i[3]} {psum_rd_en_i[4]} {psum_rd_en_i[5]} rst_i start_i {weight_data_i[0]} {weight_data_i[1]} {weight_data_i[2]} {weight_data_i[3]} {weight_data_i[4]} {weight_data_i[5]} {weight_data_i[6]} {weight_data_i[7]} {weight_data_i[8]} {weight_data_i[9]} {weight_data_i[10]} {weight_data_i[11]} {weight_data_i[12]} {weight_data_i[13]} {weight_data_i[14]} {weight_data_i[15]} {weight_wr_addr_i[0]} {weight_wr_addr_i[1]} {weight_wr_addr_i[2]} {weight_wr_addr_i[3]} {weight_wr_addr_i[4]} weight_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Top -layer 3 -spreadType center -spacing 10 -pin {}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 10 -pin {clk_i {ifmap_data_i[0]} {ifmap_data_i[1]} {ifmap_data_i[2]} {ifmap_data_i[3]} {ifmap_data_i[4]} {ifmap_data_i[5]} {ifmap_data_i[6]} {ifmap_data_i[7]} {ifmap_data_i[8]} {ifmap_data_i[9]} {ifmap_data_i[10]} {ifmap_data_i[11]} {ifmap_data_i[12]} {ifmap_data_i[13]} {ifmap_data_i[14]} {ifmap_data_i[15]} {ifmap_wr_addr_i[0]} {ifmap_wr_addr_i[1]} {ifmap_wr_addr_i[2]} {ifmap_wr_addr_i[3]} {ifmap_wr_addr_i[4]} {ifmap_wr_addr_i[5]} {ifmap_wr_addr_i[6]} {ifmap_wr_addr_i[7]} {ifmap_wr_addr_i[8]} {ifmap_wr_addr_i[9]} ifmap_wr_en_i {psum_rd_en_i[0]} {psum_rd_en_i[1]} {psum_rd_en_i[2]} {psum_rd_en_i[3]} {psum_rd_en_i[4]} {psum_rd_en_i[5]} rst_i start_i {weight_data_i[0]} {weight_data_i[1]} {weight_data_i[2]} {weight_data_i[3]} {weight_data_i[4]} {weight_data_i[5]} {weight_data_i[6]} {weight_data_i[7]} {weight_data_i[8]} {weight_data_i[9]} {weight_data_i[10]} {weight_data_i[11]} {weight_data_i[12]} {weight_data_i[13]} {weight_data_i[14]} {weight_data_i[15]} {weight_wr_addr_i[0]} {weight_wr_addr_i[1]} {weight_wr_addr_i[2]} {weight_wr_addr_i[3]} {weight_wr_addr_i[4]} weight_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Left -layer 3 -spreadType center -spacing 15 -pin {clk_i {ifmap_data_i[0]} {ifmap_data_i[1]} {ifmap_data_i[2]} {ifmap_data_i[3]} {ifmap_data_i[4]} {ifmap_data_i[5]} {ifmap_data_i[6]} {ifmap_data_i[7]} {ifmap_data_i[8]} {ifmap_data_i[9]} {ifmap_data_i[10]} {ifmap_data_i[11]} {ifmap_data_i[12]} {ifmap_data_i[13]} {ifmap_data_i[14]} {ifmap_data_i[15]} {ifmap_wr_addr_i[0]} {ifmap_wr_addr_i[1]} {ifmap_wr_addr_i[2]} {ifmap_wr_addr_i[3]} {ifmap_wr_addr_i[4]} {ifmap_wr_addr_i[5]} {ifmap_wr_addr_i[6]} {ifmap_wr_addr_i[7]} {ifmap_wr_addr_i[8]} {ifmap_wr_addr_i[9]} ifmap_wr_en_i {psum_rd_en_i[0]} {psum_rd_en_i[1]} {psum_rd_en_i[2]} {psum_rd_en_i[3]} {psum_rd_en_i[4]} {psum_rd_en_i[5]} rst_i start_i {weight_data_i[0]} {weight_data_i[1]} {weight_data_i[2]} {weight_data_i[3]} {weight_data_i[4]} {weight_data_i[5]} {weight_data_i[6]} {weight_data_i[7]} {weight_data_i[8]} {weight_data_i[9]} {weight_data_i[10]} {weight_data_i[11]} {weight_data_i[12]} {weight_data_i[13]} {weight_data_i[14]} {weight_data_i[15]} {weight_wr_addr_i[0]} {weight_wr_addr_i[1]} {weight_wr_addr_i[2]} {weight_wr_addr_i[3]} {weight_wr_addr_i[4]} weight_wr_en_i}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing -15.12 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing -15.12 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 15 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 10 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 5 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 7 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 7.0 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 8 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 3 -spreadType center -spacing 9 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Right -layer 1 -spreadType center -spacing 8 -pin {{psum_empty_o[0]} {psum_empty_o[1]} {psum_empty_o[2]} {psum_empty_o[3]} {psum_empty_o[4]} {psum_empty_o[5]} {psum_o[0][0]} {psum_o[0][1]} {psum_o[0][2]} {psum_o[0][3]} {psum_o[0][4]} {psum_o[0][5]} {psum_o[0][6]} {psum_o[0][7]} {psum_o[0][8]} {psum_o[0][9]} {psum_o[0][10]} {psum_o[0][11]} {psum_o[0][12]} {psum_o[0][13]} {psum_o[0][14]} {psum_o[0][15]} {psum_o[1][0]} {psum_o[1][1]} {psum_o[1][2]} {psum_o[1][3]} {psum_o[1][4]} {psum_o[1][5]} {psum_o[1][6]} {psum_o[1][7]} {psum_o[1][8]} {psum_o[1][9]} {psum_o[1][10]} {psum_o[1][11]} {psum_o[1][12]} {psum_o[1][13]} {psum_o[1][14]} {psum_o[1][15]} {psum_o[2][0]} {psum_o[2][1]} {psum_o[2][2]} {psum_o[2][3]} {psum_o[2][4]} {psum_o[2][5]} {psum_o[2][6]} {psum_o[2][7]} {psum_o[2][8]} {psum_o[2][9]} {psum_o[2][10]} {psum_o[2][11]} {psum_o[2][12]} {psum_o[2][13]} {psum_o[2][14]} {psum_o[2][15]} {psum_o[3][0]} {psum_o[3][1]} {psum_o[3][2]} {psum_o[3][3]} {psum_o[3][4]} {psum_o[3][5]} {psum_o[3][6]} {psum_o[3][7]} {psum_o[3][8]} {psum_o[3][9]} {psum_o[3][10]} {psum_o[3][11]} {psum_o[3][12]} {psum_o[3][13]} {psum_o[3][14]} {psum_o[3][15]} {psum_o[4][0]} {psum_o[4][1]} {psum_o[4][2]} {psum_o[4][3]} {psum_o[4][4]} {psum_o[4][5]} {psum_o[4][6]} {psum_o[4][7]} {psum_o[4][8]} {psum_o[4][9]} {psum_o[4][10]} {psum_o[4][11]} {psum_o[4][12]} {psum_o[4][13]} {psum_o[4][14]} {psum_o[4][15]} {psum_o[5][0]} {psum_o[5][1]} {psum_o[5][2]} {psum_o[5][3]} {psum_o[5][4]} {psum_o[5][5]} {psum_o[5][6]} {psum_o[5][7]} {psum_o[5][8]} {psum_o[5][9]} {psum_o[5][10]} {psum_o[5][11]} {psum_o[5][12]} {psum_o[5][13]} {psum_o[5][14]} {psum_o[5][15]}}
setPinAssignMode -pinEditInBatch true
editPin -use POWER -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Top -layer 4 -spreadType center -spacing 0.14 -pin VDD
setPinAssignMode -pinEditInBatch true
editPin -use GROUND -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Bottom -layer 4 -spreadType center -spacing 0.14 -pin VSS
setPinAssignMode -pinEditInBatch true
editPin -use GROUND -pinWidth 0.14 -pinDepth 0.14 -fixOverlap 1 -unit MICRON -spreadDirection counterclockwise -side Bottom -layer 4 -spreadType center -spacing 0.28 -pin VSS
setPinAssignMode -pinEditInBatch false
saveDesign eyeriss_top_fl.enc
addRing -nets {VSS VDD} -type core_rings -follow io -layer {top metal5 bottom metal5 left metal4 right metal4} -width {top 1 bottom 1 left 1 right 1} -spacing {top 1 bottom 1 left 1 right 1} -offset {top 0 bottom 0 left 0 right 0} -center 0 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
addStripe -block_ring_top_layer_limit metal5 -max_same_layer_jog_length 1.6 -padcore_ring_bottom_layer_limit metal3 -set_to_set_distance 5 -stacked_via_top_layer metal10 -padcore_ring_top_layer_limit metal5 -spacing 1 -xleft_offset 1 -merge_stripes_value 0.095 -layer metal4 -block_ring_bottom_layer_limit metal3 -width 1 -nets {VSS VDD } -stacked_via_bottom_layer metal1
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { 1 10 } -blockPinTarget { nearestRingStripe nearestTarget } -padPinPortConnect { allPort oneGeom } -checkAlignedSecondaryPin 1 -blockPin useLef -allowJogging 1 -crossoverViaBottomLayer 1 -allowLayerChange 1 -targetViaTopLayer 10 -crossoverViaTopLayer 10 -targetViaBottomLayer 1 -nets { VDD VSS }
saveDesign eyeriss_top_power.enc
editPowerVia -skip_via_on_pin Standardcell -bottom_layer metal1 -add_vias 1 -top_layer metal8
saveDesign eyeriss_top_power.enc
setEndCapMode -reset
setEndCapMode -boundary_tap false
setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -modulePlan 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 0 -moduleAwareSpare 0 -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setPlaceMode -fp false
placeDesign
timeDesign -preCTS -numPaths 200
optDesign -preCTS -numPaths 200
setDrawView place
saveDesign eyeriss_top_pl.enc
timeDesign -preCTS -numPaths 200
optDesign -preCTS -numPaths 200
setDrawView place
saveDesign eyeriss_top_pl.enc
set_ccopt_property update_io_latency false
clockDesign -specFile Clock.ctstch -outDir clock_report
checkPlace eyeriss_top.checkPlace
timeDesign -postCTS -numPaths 200
timeDesign -postCTS -hold -numPaths 200
optDesign -postCTS -numPaths 200
optDesign -postCTS -hold -numPaths 200
timeDesign -postCTS -hold -numPaths 200
timeDesign -postCTS -numPaths 200
saveDesign eyeriss_top_clk.enc
getFillerMode -quiet
addFillerGap 0.6
addFiller -cell FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 -prefix FILLER -markFixed
saveDesign eyeriss_top_powerroute_clk_filler.enc
setAnalysisMode -cppr none -clockGatingCheck true -timeBorrowing true -useOutputPinCap true -sequentialConstProp false -timingSelfLoopsNoSkew false -enableMultipleDriveNet true -clkSrcPath true -warn true -usefulSkew false -analysisType onChipVariation -log true
setNanoRouteMode -quiet -drouteFixAntenna false
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
setNanoRouteMode -quiet -routeTopRoutingLayer 6
routeDesign -globalDetail
saveDesign eyeriss_top_powerroute_clk_filler.enc
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 400 -prefix eyeriss_top_postRoute -outDir timingReports
clearClockDomains
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 400 -prefix eyeriss_top_postRoute -outDir timingReports
saveDesign eyeriss_top_final_layout.enc
saveNetlist -phys -includePowerGround eyeriss_top_phy.v -excludeLeafCell
saveNetlist eyeriss_top_nophy.v -excludeLeafCell
write_sdf eyeriss_top.sdf
verify_drc -report cnn.drc.rpt -limit 1000
verifyConnectivity -type all -error 1000 -warning 50
verifyProcessAntenna -reportfile cnn.antenna.rpt -error 1000
fit
