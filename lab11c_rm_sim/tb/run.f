/*-----------------------------------------------------------------
File name     : run.f
Description   : lab01_data simulator run template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
              : Set $UVMHOME to install directory of UVM library
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/
// 64 bit option for AWS labs
-64

 -uvmhome $UVMHOME
 -timescale 1ns/1ns

// include directories
//*** add incdir include directories here
    -incdir ../sv
    -incdir ../../UVCs/yapp/sv
    -incdir ../../UVCs/channel/sv
    -incdir ../../UVCs/clock_and_reset/sv
    -incdir ../../UVCs/hbus/sv
    -incdir ../../UVCs/router/sv

// compile files
//*** add compile files here
    ../../UVCs/yapp/sv/yapp_pkg.sv
    ../../UVCs/yapp/sv/yapp_if.sv
    ../../UVCs/channel/sv/channel_pkg.sv
    ../../UVCs/channel/sv/channel_if.sv
    ../../UVCs/clock_and_reset/sv/clock_and_reset_pkg.sv
    ../../UVCs/clock_and_reset/sv/clock_and_reset_if.sv
    ../../UVCs/hbus/sv/hbus_pkg.sv
    ../../UVCs/hbus/sv/hbus_if.sv
    ../../UVCs/router/sv/router_module_pkg.sv

    ../../router_rtl/yapp_router.sv

    cdns_uvmreg_utils_pkg.sv
    yapp_router_regs_rdb.sv

    clkgen.sv
    hw_top.sv
    tb_top.sv

+UVM_TESTNAME=reg_introspect_test
+UVM_VERBOSITY=UVM_NONE
+SVSEED=random

