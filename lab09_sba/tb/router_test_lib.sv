class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    router_tb tb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Build phase is being executed", UVM_HIGH)
        super.build_phase(phase);
        uvm_config_int::set(this, "*", "recording_detail", 1);
        tb = router_tb::type_id::create("tb", this);
        // uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
        //                         "default_sequence",
        //                         yapp_5_packets::get_type());
    endfunction : build_phase

    virtual function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction : check_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask : run_phase

endclass : base_test

class exhaustive_seq_test extends base_test;
    `uvm_component_utils(exhaustive_seq_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_exhaustive_seq::get_type());
    endfunction : build_phase

endclass : exhaustive_seq_test

class yapp_012_test extends base_test;
    `uvm_component_utils(yapp_012_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_012_seq::get_type());
    endfunction : build_phase

endclass : yapp_012_test

class simple_test extends base_test;
    `uvm_component_utils(simple_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        super.build_phase(phase);
        // default YAPP UVC sequence
        uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_012_seq::get_type());
        // default sequence for channel UVCs
        uvm_config_wrapper::set(this, "tb.chenv?.rx_agent.sequencer.run_phase",
                                 "default_sequence",
                                 channel_rx_resp_seq::get_type());
        // default sequence for clock and reset UVC
        uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());
    endfunction : build_phase

endclass : simple_test

class test_uvc_integration extends base_test;
    `uvm_component_utils(test_uvc_integration)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        super.build_phase(phase);
        // default YAPP UVC sequence
        uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_four_channel_seq::get_type());
        // default sequence for HBUS UVCs
        uvm_config_wrapper::set(this, "tb.hbusenv.masters[0].sequencer.run_phase",
                                 "default_sequence",
                                 hbus_small_packet_seq::get_type());
        // default sequence for channel UVCs
        uvm_config_wrapper::set(this, "tb.chenv?.rx_agent.sequencer.run_phase",
                                 "default_sequence",
                                 channel_rx_resp_seq::get_type());
        // default sequence for clock and reset UVC
        uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());
    endfunction : build_phase

endclass : test_uvc_integration

class multichannel_test extends base_test;
    `uvm_component_utils(multichannel_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        //set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
        super.build_phase(phase);
        // default sequence for channel UVCs
        uvm_config_wrapper::set(this, "tb.chenv?.rx_agent.sequencer.run_phase",
                                 "default_sequence",
                                 channel_rx_resp_seq::get_type());
        // default sequence for clock and reset UVC
        uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());
        uvm_config_wrapper::set(this, "tb.mcseqr.run_phase",
                                "default_sequence",
                                router_simple_mcseq::get_type());
    endfunction : build_phase

endclass : multichannel_test
