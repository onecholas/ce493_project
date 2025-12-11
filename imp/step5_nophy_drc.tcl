# step 18
saveNetlist -phys -includePowerGround eyeriss_top_phy.v -excludeLeafCell
saveNetlist eyeriss_top_nophy.v -excludeLeafCell
write_sdf eyeriss_top.sdf

# step 19
verify_drc -report cnn.drc.rpt -limit 1000
verifyConnectivity -type all -error 1000 -warning 50
verifyProcessAntenna -reportfile cnn.antenna.rpt -error 1000