# step 7
setDesignMode -process 45
fit
setDrawView fplan
getIoFlowFlag

#step 8
floorPlan -r 1.0 0.63 2 2 2 2
uiSetTool select
getIoFlowFlag

# step 9
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo