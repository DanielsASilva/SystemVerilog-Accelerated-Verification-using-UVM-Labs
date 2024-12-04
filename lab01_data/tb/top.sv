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
// generate 5 random packets and use the print method
// to display the results
    yapp_packet yp1, yp2, yp3;
    int ok;

    initial begin
        yp1 = new("yp1");
        yp2 = new("yp2");
        for(int i = 0; i < 5; i++) begin
            ok = yp1.randomize();
            yp1.print();
        end

        // tree printer test
        ok = yp1.randomize();
        yp1.print(uvm_default_tree_printer);

        // copy and clone test
        yp2.copy(yp1);
        $cast(yp3, yp1.clone());

        yp2.print(uvm_default_tree_printer);
        yp3.print(uvm_default_tree_printer);

        // compare test
        ok = yp1.compare(yp2);
        if(ok == 1)
            $display("yp1 match yp2");
        else
            $display("yp1 does not match yp2");
        ok = yp1.compare(yp3);
        if(ok == 1)
            $display("yp1 match yp3");
        else
            $display("yp1 does not match yp3");

    end
// experiment with the copy, clone and compare UVM method
endmodule : top
