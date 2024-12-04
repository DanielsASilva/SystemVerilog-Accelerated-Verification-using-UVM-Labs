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
        set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
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

class uvm_reset_test extends base_test;

    uvm_reg_hw_reset_seq reset_seq;

  // component macro
  `uvm_component_utils(uvm_reset_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reset_seq");
      uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());

      super.build_phase(phase);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, {"Raising Objection ",get_type_name()});
     // Set the model property of the sequence to our Register Model instance
     // Update the RHS of this assignment to match your instance names. Syntax is:
     //  <testbench instance>.<register model instance>
     reset_seq.model = tb.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     reset_seq.start(null);
     phase.drop_objection(this,{"Dropping Objection ",get_type_name()});

  endtask

endclass : uvm_reset_test

class uvm_mem_walk_test extends base_test;

    uvm_mem_walk_seq mem_walk_seq;

  // component macro
  `uvm_component_utils(uvm_mem_walk_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      mem_walk_seq = uvm_mem_walk_seq::type_id::create("uvm_mem_walk_seq");
      uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());

      super.build_phase(phase);
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, {"Raising Objection ",get_type_name()});
     // Set the model property of the sequence to our Register Model instance
     // Update the RHS of this assignment to match your instance names. Syntax is:
     //  <testbench instance>.<register model instance>
     mem_walk_seq.model = tb.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     mem_walk_seq.start(null);
     phase.drop_objection(this,{"Dropping Objection ",get_type_name()});

  endtask

endclass : uvm_mem_walk_test

