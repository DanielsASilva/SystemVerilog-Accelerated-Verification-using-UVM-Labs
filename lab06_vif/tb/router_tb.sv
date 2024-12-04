class router_tb extends uvm_env;
    `uvm_component_utils(router_tb)

    yapp_env env;

    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Build phase is being executed", UVM_HIGH)
        super.build_phase(phase);
        env = yapp_env::type_id::create("env", this);
    endfunction : build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "start of simulation phase", UVM_HIGH)
    endfunction : start_of_simulation_phase

endclass : router_tb
