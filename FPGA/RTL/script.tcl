create_project [lindex $argv 0] [lindex $argv 1]/[lindex $argv 0]/ -part xczu7ev-ffvc1156-2-e -force
set_property board_part xilinx.com:zcu104:part0:1.1 [current_project]
create_bd_design "SkyNet"
update_compile_order -fileset sources_1

set_property ip_repo_paths [lindex $argv 2] [current_project]
update_ip_catalog

startgroup

  # Create instance: SkyNet, and set properties
  set SkyNet [ create_bd_cell -type ip -vlnv xilinx.com:hls:SkyNet:1.0 SkyNet ]

  # Create instance: axi_smc_0, and set properties
  set axi_smc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_0 ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $axi_smc_0

  # Create instance: axi_smc_1, and set properties
  set axi_smc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_1 ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $axi_smc_1

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {94.862} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {300.000} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.000} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.PHASE_DUTY_CONFIG {true} \
   CONFIG.USE_DYN_RECONFIG {true} \
 ] $clk_wiz

  # Create instance: ps8_0_clkwiz, and set properties
  set ps8_0_clkwiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_clkwiz ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {1} \
 ] $ps8_0_clkwiz

  # Create instance: ps8_0_skynet, and set properties
  set ps8_0_skynet [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_skynet ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {1} \
 ] $ps8_0_skynet

  # Create instance: rst_clkwiz, and set properties
  set rst_clkwiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clkwiz ]

  # Create instance: rst_ps8_0_100M, and set properties
  set rst_ps8_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_100M ]
  
  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0 ]
  apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
  set_property -dict [list \
   CONFIG.PSU__USE__S_AXI_ACE {0} \
   CONFIG.PSU__USE__S_AXI_ACP {0} \
   CONFIG.PSU__USE__S_AXI_GP0 {0} \
   CONFIG.PSU__USE__S_AXI_GP1 {0} \
   CONFIG.PSU__USE__S_AXI_GP2 {1} \
   CONFIG.PSU__USE__S_AXI_GP3 {1} \
   CONFIG.PSU__USE__S_AXI_GP4 {0} \
   CONFIG.PSU__USE__S_AXI_GP5 {0} \
   CONFIG.PSU__USE__S_AXI_GP6 {0} \
  CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
  ] $zynq_ultra_ps_e_0
  

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins ps8_0_skynet/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins ps8_0_clkwiz/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
  connect_bd_intf_net -intf_net SkyNet_m_axi_INPUT_r [get_bd_intf_pins SkyNet/m_axi_INPUT_r] [get_bd_intf_pins axi_smc_0/S00_AXI]
  connect_bd_intf_net -intf_net SkyNet_m_axi_OUTPUT_r [get_bd_intf_pins SkyNet/m_axi_OUTPUT_r] [get_bd_intf_pins axi_smc_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins axi_smc_1/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP1_FPD]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_smc_0/M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
  connect_bd_intf_net -intf_net ps8_0_axi_periph1_M00_AXI [get_bd_intf_pins SkyNet/s_axi_AXILiteS] [get_bd_intf_pins ps8_0_skynet/M00_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins clk_wiz/s_axi_lite] [get_bd_intf_pins ps8_0_clkwiz/M00_AXI]

  # Create port connections
  connect_bd_net -net ACLK_1 [get_bd_pins SkyNet/ap_clk] [get_bd_pins axi_smc_0/aclk] [get_bd_pins axi_smc_1/aclk] [get_bd_pins clk_wiz/clk_out1] [get_bd_pins ps8_0_skynet/ACLK] [get_bd_pins ps8_0_skynet/M00_ACLK] [get_bd_pins ps8_0_skynet/S00_ACLK] [get_bd_pins rst_clkwiz/slowest_sync_clk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/saxihp1_fpd_aclk]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rst_clkwiz/dcm_locked]
  connect_bd_net -net rst_ps8_0_300M_interconnect_aresetn [get_bd_pins ps8_0_clkwiz/ARESETN] [get_bd_pins rst_ps8_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_ps8_0_300M_peripheral_aresetn [get_bd_pins SkyNet/ap_rst_n] [get_bd_pins axi_smc_0/aresetn] [get_bd_pins axi_smc_1/aresetn] [get_bd_pins ps8_0_skynet/ARESETN] [get_bd_pins ps8_0_skynet/M00_ARESETN] [get_bd_pins ps8_0_skynet/S00_ARESETN] [get_bd_pins rst_clkwiz/peripheral_aresetn]
  connect_bd_net -net rst_ps8_0_300M_peripheral_aresetn1 [get_bd_pins clk_wiz/s_axi_aresetn] [get_bd_pins ps8_0_clkwiz/M00_ARESETN] [get_bd_pins ps8_0_clkwiz/S00_ARESETN] [get_bd_pins rst_ps8_0_100M/peripheral_aresetn]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins clk_wiz/clk_in1] [get_bd_pins clk_wiz/s_axi_aclk] [get_bd_pins ps8_0_clkwiz/ACLK] [get_bd_pins ps8_0_clkwiz/M00_ACLK] [get_bd_pins ps8_0_clkwiz/S00_ACLK] [get_bd_pins rst_ps8_0_100M/slowest_sync_clk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins rst_clkwiz/ext_reset_in] [get_bd_pins rst_ps8_0_100M/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

endgroup

assign_bd_address

make_wrapper -files [get_files [lindex $argv 1]/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/bd/SkyNet/SkyNet.bd] -top
add_files -norecurse [lindex $argv 1]/[lindex $argv 0]/[lindex $argv 0].srcs/sources_1/bd/SkyNet/hdl/SkyNet_wrapper.v

#launch_runs impl_1 -to_step write_bitstream -jobs 32
