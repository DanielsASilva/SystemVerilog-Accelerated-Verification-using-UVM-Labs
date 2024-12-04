class yapp_tx_monitor extends uvm_monitor;
    `uvm_component_utils(yapp_tx_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "inside of the run phase", UVM_LOW)
    endtask : run_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "start of simulation phase", UVM_HIGH)
    endfunction : start_of_simulation_phase

endclass : yapp_tx_monitor
