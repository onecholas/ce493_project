# step 16
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

# step 17
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 400 -prefix eyeriss_top_postRoute -outDir timingReports
clearClockDomains
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 400 -prefix eyeriss_top_postRoute -outDir timingReports
saveDesign eyeriss_top_final_layout.enc