/*-----------------------------------------------------------------
File name     : top.sv
Description   : lab01_data top module template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

module top;
// import the UVM library
// include the UVM macros
    import uvm_pkg::*;
    `include "uvm_macros.svh"

// import the YAPP package
    import yapp_pkg::*;

// import the Channel package
    import channel_pkg::*;

// import the HBUS package
    import hbus_pkg::*;

// import the Clock and Reset package
    import clock_and_reset_pkg::*;

// import the Router Module package
    import router_module_pkg::*;

    `include "router_scoreboard.sv"
    `include "router_mcsequencer.sv"
    `include "router_mcseqs_lib.sv"

    `include "router_tb.sv"
    `include "router_test_lib.sv"

    //yapp_packet yp;

    initial begin
        yapp_vif_config::set(null,
                         "*.tb.env.agent.*",
                         "vif",
                         hw_top.in0);
        clock_and_reset_vif_config::set(null,
                         "*.tb.clkrstenv.*",
                         "vif",
                         hw_top.clk0);
        hbus_vif_config::set(null,
                         "*.tb.hbusenv.*",
                         "vif",
                         hw_top.hbus0);
        channel_vif_config::set(null,
                         "*.tb.chenv0.*",
                         "vif",
                         hw_top.ch0);
        channel_vif_config::set(null,
                         "*.tb.chenv1.*",
                         "vif",
                         hw_top.ch1);
        channel_vif_config::set(null,
                         "*.tb.chenv2.*",
                         "vif",
                         hw_top.ch2);
       run_test();
    end
endmodule : top
