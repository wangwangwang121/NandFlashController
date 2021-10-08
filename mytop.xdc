#提供一个注释版本，仅仅是个人理解，希望能有所帮助
#端口定义
set_property -dict {LOC F5  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports IO_NAND_DQS_0];
set_property -dict {LOC J8  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[0]}];
set_property -dict {LOC H8  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[1]}];
set_property -dict {LOC G5  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[2]}];
set_property -dict {LOC H6  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[3]}];
set_property -dict {LOC G9  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[4]}];
set_property -dict {LOC H11 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[5]}];
set_property -dict {LOC H9  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[6]}];
set_property -dict {LOC J11 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[7]}];
set_property -dict {LOC D8  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {O_NAND_CE_0[0]}]; #CE1
set_property -dict {LOC E6  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {O_NAND_CE_0[1]}]; #CE3
set_property -dict {LOC F9  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_WE_0];
set_property -dict {LOC E8  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_RE_0];
set_property -dict {LOC E5  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_ALE_0];
set_property -dict {LOC G6  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_CLE_0];
set_property -dict {LOC H7  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {I_NAND_RB_0[0]}]; #RB
set_property -dict {LOC D9  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {I_NAND_RB_0[1]}]; #RB3
set_property -dict {LOC B5  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_WP_0];

#set_property -dict {LOC F10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports IO_NAND_DQS_0];
#set_property -dict {LOC K11 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[0]}];
#set_property -dict {LOC G11 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[1]}];
#set_property -dict {LOC G12 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[2]}];
#set_property -dict {LOC G10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[3]}];
#set_property -dict {LOC  A8 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[4]}];
#set_property -dict {LOC B10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[5]}];
#set_property -dict {LOC  A9 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[6]}];
#set_property -dict {LOC A10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {IO_NAND_DQ_0[7]}];
#set_property -dict {LOC  A7 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {O_NAND_CE_0[0]}]; #CE2
#set_property -dict {LOC  C3 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {O_NAND_CE_0[1]}]; #CE4
#set_property -dict {LOC  B7 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_WE_0];
#set_property -dict {LOC E11 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_RE_0];
#set_property -dict {LOC E10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_ALE_0];
#set_property -dict {LOC D10 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_CLE_0];
#set_property -dict {LOC F12 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {I_NAND_RB_0[0]}]; #RB2
#set_property -dict {LOC H16 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {I_NAND_RB_0[1]}]; #RB4
#set_property -dict {LOC  C4 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports O_NAND_WP_0];
#controller-flash的约束
#输出端时钟
create_generated_clock -name output_clock -source [get_pins -hierarchical -filter {NAME =~ *Inst_DQSODDR/C}] -multiply_by 1 -invert [get_ports IO_NAND_DQS_0]
#控制器时钟
set data_clock [get_clocks -of_objects [get_pins -hierarchical -regexp -filter {NAME =~ ".+/NandFlashController[_\d]+/iSystemClock"}]];

set fwclk        output_clock;     # forwarded clock name (generated using create_generated_clock at output clock port)        
set tsu_r        0.800;            # destination device setup time requirement for rising edge，以下四行来源于手册
set thd_r        0.800;            # destination device hold time requirement for rising edge
set tsu_f        0.800;            # destination device setup time requirement for falling edge
set thd_f        0.800;            # destination device hold time requirement for falling edge
set trce_dly_max 0.000;            # maximum board trace delay
set trce_dly_min 0.000;            # minimum board trace delay
set output_ports IO_NAND_DQ_0*;   # list of output ports

# Output Delay Constraints  output_delay需要满足flash内部的setup,hold约束，并且约束必须在上升沿，下降沿都具有
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu_r] [get_ports $output_ports];
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd_r] [get_ports $output_ports];
set_output_delay -clock $fwclk -max [expr $trce_dly_max + $tsu_f] [get_ports $output_ports] -clock_fall -add_delay;
set_output_delay -clock $fwclk -min [expr $trce_dly_min - $thd_f] [get_ports $output_ports] -clock_fall -add_delay;
#设置异步路径，即约束仅仅在上升沿-上升沿，下降沿-下降沿有效
set_false_path -setup -rise_from [get_clocks $data_clock] -fall_to [get_clocks output_clock]
set_false_path -setup -fall_from [get_clocks $data_clock] -rise_to [get_clocks output_clock]
set_false_path -hold -rise_from [get_clocks $data_clock] -rise_to [get_clocks output_clock]
set_false_path -hold -fall_from [get_clocks $data_clock] -fall_to [get_clocks output_clock]
#flash-controller的约束
create_clock -name virclk -period 10 -waveform {5 0};
set input_clock         virclk;       # Name of input clock

set input_clock_period  10;                # Period of input clock (full-period)
set skew_bre            0.850;             # Data invalid before the rising clock edge,来源于手册，数据无效时间
set skew_are            0.850;             # Data invalid after the rising clock edge
set skew_bfe            0.850;             # Data invalid before the falling clock edge
set skew_afe            0.850;             # Data invalid after the falling clock edge
set input_ports         IO_NAND_DQ_0*;     # List of input ports

## Input Delay Constraint 输入约束，输入端口中时钟和数据的不同走线以及内部flash数据延时导致的delay
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 + $skew_afe] [get_ports $input_ports];
set_input_delay -clock $input_clock -min [expr $input_clock_period/2 - $skew_bfe] [get_ports $input_ports];
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 + $skew_are] [get_ports $input_ports] -clock_fall -add_delay;
set_input_delay -clock $input_clock -min [expr $input_clock_period/2 - $skew_bre] [get_ports $input_ports] -clock_fall -add_delay;
#表达的是两个时钟的约束需要在第几个周期完成，即时序check的setup,hold分别需要在哪一个沿确立
set_multicycle_path -setup -end -rise_from [get_clocks virclk] -rise_to [get_clocks $data_clock] 0
set_multicycle_path -setup -end -fall_from [get_clocks virclk] -fall_to [get_clocks $data_clock] 0
#设置异步路径，即约束仅仅在上升沿-上升沿，下降沿-下降沿有效
set_false_path -setup -fall_from [get_clocks virclk] -rise_to [get_clocks $data_clock]
set_false_path -setup -rise_from [get_clocks virclk] -fall_to [get_clocks $data_clock]
set_false_path -hold -rise_from [get_clocks virclk] -rise_to [get_clocks $data_clock]
set_false_path -hold -fall_from [get_clocks virclk] -fall_to [get_clocks $data_clock]

#表达两个不同时钟的异步关系
set_false_path -from [get_clocks virclk] -to [get_clocks output_clock]
set_false_path -from [get_clocks output_clock] -to [get_clocks virclk]

#set_false_path -from [get_clocks clk_50mhz] -to [get_clocks clkout1]
#set_false_path -from [get_clocks clk_50mhz] -to [get_clocks clkout2]
