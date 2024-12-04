class router_tb extends uvm_env;

    yapp_env env;

    channel_env chenv0;
    channel_env chenv1;
    channel_env chenv2;

    hbus_env hbusenv;

    clock_and_reset_env clkrstenv;

    router_mcsequencer mcseqr;

    router_scoreboard_fifo scoreboard_fifo;

    // register model
    yapp_router_regs_t yapp_rm;
    hbus_reg_adapter   reg2hbus;

    `uvm_component_utils_begin(router_tb)
        `uvm_field_object(yapp_rm, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Build phase is being executed", UVM_HIGH)
        super.build_phase(phase);

        env = yapp_env::type_id::create("env", this);

        uvm_config_int::set(this, "chenv0", "channel_id", 0);
        uvm_config_int::set(this, "chenv1", "channel_id", 1);
        uvm_config_int::set(this, "chenv2", "channel_id", 2);

        chenv0 = channel_env::type_id::create("chenv0", this);
        chenv1 = channel_env::type_id::create("chenv1", this);
        chenv2 = channel_env::type_id::create("chenv2", this);

        uvm_config_int::set(this, "hbusenv", "num_masters", 1);
        uvm_config_int::set(this, "hbusenv", "num_slaves", 0);

        hbusenv = hbus_env::type_id::create("hbusenv", this);

        clkrstenv = clock_and_reset_env::type_id::create("clkrstenv", this);

        mcseqr = router_mcsequencer::type_id::create("mcseqr", this);

        scoreboard_fifo = router_scoreboard_fifo::type_id::create("scoreboard_fifo", this);

        // configuring register model
        yapp_rm = yapp_router_regs_t::type_id::create("yapp_rm", this);
        yapp_rm.build();
        yapp_rm.lock_model();

        yapp_rm.default_map.set_auto_predict(1);
        yapp_rm.set_hdl_path_root("hw_top.dut");

        reg2hbus = hbus_reg_adapter::type_id::create("reg2hbus",this);

    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        mcseqr.hbus_seqr = hbusenv.masters[0].sequencer;
        mcseqr.yapp_seqr = env.agent.sequencer;

        env.agent.monitor.yapp_out.connect(scoreboard_fifo.yapp_fifo.analysis_export);
        hbusenv.masters[0].monitor.item_collected_port.connect(scoreboard_fifo.hbus_fifo.analysis_export);

        chenv0.rx_agent.monitor.item_collected_port.connect(scoreboard_fifo.chan0_fifo.analysis_export);
        chenv1.rx_agent.monitor.item_collected_port.connect(scoreboard_fifo.chan1_fifo.analysis_export);
        chenv2.rx_agent.monitor.item_collected_port.connect(scoreboard_fifo.chan2_fifo.analysis_export);

        yapp_rm.default_map.set_sequencer(hbusenv.masters[0].sequencer, reg2hbus);
    endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "start of simulation phase", UVM_HIGH)
    endfunction : start_of_simulation_phase

endclass : router_tb
