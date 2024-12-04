class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    router_tb tb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tb = new("tb", this);
        `uvm_info(get_type_name(), "Build phase is being executed", UVM_HIGH)
    endfunction : build_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

endclass : base_test

class test2 extends base_test;
    `uvm_component_utils(test2)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : test2
