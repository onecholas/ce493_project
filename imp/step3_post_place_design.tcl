# step 14 cont. 
timeDesign -preCTS -numPaths 200
optDesign -preCTS -numPaths 200
setDrawView place
saveDesign eyeriss_top_pl.enc

# step 15
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

