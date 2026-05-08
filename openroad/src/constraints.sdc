# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>
# - Philipp Kraft <kraftp@ethz.ch>

# Backend constraints for core_wrap

#############################
## Driving Cells and Loads ##
#############################

set_load 0.05 [all_outputs]
set_driving_cell [all_inputs] -lib_cell sg13g2_buf_4


##################
## Input Clocks ##
##################
puts "Clocks..."

# Target 100 MHz
set TCK_SYS 5.8
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]


##################################
## Clock Groups & Uncertainties ##
##################################

set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]


#############
## Inputs  ##
#############
puts "Inputs..."

set_case_analysis 0 [get_ports test_enable_i]

# Reset should propagate to system domain within a clock cycle.
set_input_delay -max [expr $TCK_SYS * 0.10] [get_ports {rst_ni test_enable_i}]
set_false_path -hold -from [get_ports {rst_ni test_enable_i}]
set_max_delay $TCK_SYS -from [get_ports {rst_ni test_enable_i}]

# Mode selection (sampled at boot) 
set_false_path -from [get_ports {rv32e_mode_i reliable_mode_i}]

# Interrupts
set_input_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {irqs_i* timer_irq_i software_irq_i}]
set_input_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {irqs_i* timer_irq_i software_irq_i}]

# Boot address, debug, fetch enable
set_input_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {boot_addr_i* debug_req_i fetch_enable_i}]
set_input_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {boot_addr_i* debug_req_i fetch_enable_i}]

# Instruction memory interface
set_input_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {instr_gnt_i instr_rvalid_i instr_rdata_i* instr_err_i}]
set_input_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {instr_gnt_i instr_rvalid_i instr_rdata_i* instr_err_i}]

# Data memory interface
set_input_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {data_gnt_i data_rvalid_i data_rdata_i* data_err_i}]
set_input_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {data_gnt_i data_rvalid_i data_rdata_i* data_err_i}]


##############
## Outputs  ##
##############
puts "Outputs..."

# Instruction memory interface
set_output_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {instr_req_o instr_addr_o*}]
set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {instr_req_o instr_addr_o*}]

# Data memory interface
set_output_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {data_req_o data_we_o data_be_o* data_addr_o* data_wdata_o*}]
set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {data_req_o data_we_o data_be_o* data_addr_o* data_wdata_o*}]

# Status and error outputs
set_output_delay -min -add_delay -clock clk_sys [expr $TCK_SYS * 0.10] [get_ports {core_busy_o rel_error_o}]
set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS * 0.30] [get_ports {core_busy_o rel_error_o}]