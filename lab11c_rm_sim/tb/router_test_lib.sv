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

class reg_access_test extends base_test;

    // convenience handle for the register block
    yapp_regs_c yapp_reg;

    // component macro
    `uvm_component_utils(reg_access_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);

      super.build_phase(phase);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    yapp_reg = tb.yapp_rm.yapp_regs;
  endfunction : connect_phase

  virtual task run_phase (uvm_phase phase);
     int rdata;
     uvm_status_e status;
     phase.raise_objection(this, {"Raising Objection ",get_type_name()});

     `uvm_info(get_type_name(), "RW test en_reg", UVM_NONE)
     yapp_reg.en_reg.write(status, 8'hff);
     `uvm_info("WRITE", "Wrote 0xff to en_reg", UVM_NONE)
     yapp_reg.en_reg.peek(status, rdata);
     `uvm_info("PEEK", $sformatf("Peeked 0x%0h from en_reg", rdata), UVM_NONE)
     yapp_reg.en_reg.poke(status, 8'h00);
     `uvm_info("POKE", "Poked 0x00 to en_reg", UVM_NONE)
     yapp_reg.en_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("Read 0x%0h from en_reg", rdata), UVM_NONE)

     `uvm_info(get_type_name(), "RO test addr0_cnt_reg", UVM_NONE)
     yapp_reg.addr0_cnt_reg.poke(status, 8'hff);
     `uvm_info("POKE", "Poked 0xff to addr0_cnt_reg", UVM_NONE)
     yapp_reg.addr0_cnt_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("Read 0x%0h from addr0_cnt_reg", rdata), UVM_NONE)
      yapp_reg.addr0_cnt_reg.write(status, 8'h00);
     `uvm_info("WRITE", "Wrote 0x00 to addr0_cnt_reg", UVM_NONE)
     yapp_reg.addr0_cnt_reg.peek(status, rdata);
     `uvm_info("PEEK", $sformatf("Peeked 0x%0h from addr0_cnt_reg", rdata), UVM_NONE)

     phase.drop_objection(this,{"Dropping Objection ",get_type_name()});

  endtask

endclass : reg_access_test

class reg_function_test extends base_test;

    // convenience handle for the register block
    yapp_regs_c yapp_reg;

    yapp_tx_sequencer yapp_sequencer;
    yapp_012_seq yapp012;

    // component macro
    `uvm_component_utils(reg_function_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());
      uvm_config_wrapper::set(this, "tb.chenv?.rx_agent.sequencer.run_phase",
                                 "default_sequence",
                                 channel_rx_resp_seq::get_type());
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);

      yapp012 = yapp_012_seq::type_id::create("yapp012", this);
      super.build_phase(phase);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    yapp_reg = tb.yapp_rm.yapp_regs;
    yapp_sequencer = tb.env.agent.sequencer;
  endfunction : connect_phase

  virtual task run_phase (uvm_phase phase);
     int rdata;
     uvm_status_e status;

     phase.raise_objection(this, {"Raising Objection ",get_type_name()});

     `uvm_info(get_type_name(), "reg function test", UVM_NONE)
     yapp_reg.en_reg.router_en.write(status, 8'h01);
     `uvm_info("WRITE", "Set router enable bit to 1", UVM_NONE)
     yapp_reg.en_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("en_reg is 0x%h", rdata), UVM_NONE)

     yapp012.start(yapp_sequencer);

     yapp_reg.addr0_cnt_reg.read(status, rdata);
     if(rdata == 0)
        `uvm_info("READ", $sformatf("addr0_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ INCREMENTED", $sformatf("addr0_cnt_reg: 0x%0h | expected: 0x0", rdata))
     yapp_reg.addr1_cnt_reg.read(status, rdata);
     if(rdata == 0)
        `uvm_info("READ", $sformatf("addr1_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ INCREMENTED", $sformatf("addr1_cnt_reg: 0x%0h | expected: 0x0", rdata))
     yapp_reg.addr2_cnt_reg.read(status, rdata);
     if(rdata == 0)
        `uvm_info("READ", $sformatf("addr2_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ INCREMENTED", $sformatf("addr2_cnt_reg: 0x%0h | expected: 0x0", rdata))
     yapp_reg.addr3_cnt_reg.read(status, rdata);
     if(rdata == 0)
        `uvm_info("READ", $sformatf("addr2_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ INCREMENTED", $sformatf("addr2_cnt_reg: 0x%0h | expected: 0x0", rdata))

     yapp_reg.en_reg.write(status, 8'hff);
     `uvm_info("WRITE", "Set all enable bits on en_reg to 1", UVM_NONE)

     yapp012.start(yapp_sequencer);
     yapp012.start(yapp_sequencer);

     yapp_reg.addr0_cnt_reg.read(status, rdata);
     if(rdata != 0)
        `uvm_info("READ", $sformatf("addr0_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ NOT INCREMENTED", $sformatf("addr0_cnt_reg: 0x%0h | expected: 0x02", rdata))
     yapp_reg.addr1_cnt_reg.read(status, rdata);
     if(rdata != 0)
        `uvm_info("READ", $sformatf("addr1_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ NOT INCREMENTED", $sformatf("addr1_cnt_reg: 0x%0h | expected: 0x02", rdata))
     yapp_reg.addr2_cnt_reg.read(status, rdata);
     if(rdata != 0)
        `uvm_info("READ", $sformatf("addr2_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ NOT INCREMENTED", $sformatf("addr2_cnt_reg: 0x%0h | expected: 0x02", rdata))
     yapp_reg.addr3_cnt_reg.read(status, rdata);
     if(rdata != 0)
        `uvm_info("READ", $sformatf("addr3_cnt_reg: 0x%0h", rdata), UVM_NONE)
     else
        `uvm_warning("READ NOT INCREMENTED", $sformatf("addr3_cnt_reg: 0x%0h | expected: 0x02", rdata))

     yapp_reg.parity_err_cnt_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("parity_err_cnt_reg: 0x%0h", rdata), UVM_NONE)
     yapp_reg.oversized_pkt_cnt_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("oversized_pkt_cnt_reg: 0x%0h", rdata), UVM_NONE)

     phase.drop_objection(this,{"Dropping Objection ",get_type_name()});

  endtask

endclass : reg_function_test

class reg_check_on_read_test extends base_test;

    // convenience handle for the register block
    yapp_regs_c yapp_reg;

    yapp_tx_sequencer yapp_sequencer;
    yapp_012_seq yapp012;

    // component macro
    `uvm_component_utils(reg_check_on_read_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_config_wrapper::set(this, "tb.clkrstenv.agent.sequencer.run_phase",
                                 "default_sequence",
                                 clk10_rst5_seq::get_type());
      uvm_config_wrapper::set(this, "tb.chenv?.rx_agent.sequencer.run_phase",
                                 "default_sequence",
                                 channel_rx_resp_seq::get_type());
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);

      yapp012 = yapp_012_seq::type_id::create("yapp012", this);
      super.build_phase(phase);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    yapp_reg = tb.yapp_rm.yapp_regs;
    yapp_sequencer = tb.env.agent.sequencer;
  endfunction : connect_phase

  virtual task run_phase (uvm_phase phase);
     int rdata;
     uvm_status_e status;

     phase.raise_objection(this, {"Raising Objection ",get_type_name()});
     tb.yapp_rm.default_map.set_check_on_read(0);

     `uvm_info(get_type_name(), "reg function test", UVM_NONE)
     yapp_reg.en_reg.router_en.write(status, 8'h01);
     `uvm_info("WRITE", "Set router enable bit to 1", UVM_NONE)

     yapp012.start(yapp_sequencer);

     yapp_reg.addr0_cnt_reg.mirror(status, UVM_CHECK);
     yapp_reg.addr1_cnt_reg.mirror(status, UVM_CHECK);
     yapp_reg.addr2_cnt_reg.mirror(status, UVM_CHECK);
     yapp_reg.addr3_cnt_reg.mirror(status, UVM_CHECK);

     yapp_reg.en_reg.write(status, 8'hff);
     `uvm_info("WRITE", "Set all enable bits on en_reg to 1", UVM_NONE)

     yapp012.start(yapp_sequencer);
     yapp012.start(yapp_sequencer);

     yapp_reg.addr0_cnt_reg.predict(2);
     yapp_reg.addr0_cnt_reg.mirror(status, UVM_CHECK);
     yapp_reg.addr1_cnt_reg.predict(2);
     yapp_reg.addr1_cnt_reg.mirror(status, UVM_CHECK);
     yapp_reg.addr2_cnt_reg.predict(2);
     yapp_reg.addr2_cnt_reg.mirror(status, UVM_CHECK);
     yapp_reg.addr3_cnt_reg.predict(2);
     yapp_reg.addr3_cnt_reg.mirror(status, UVM_CHECK);

     yapp_reg.parity_err_cnt_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("parity_err_cnt_reg: 0x%0h", rdata), UVM_NONE)
     yapp_reg.oversized_pkt_cnt_reg.read(status, rdata);
     `uvm_info("READ", $sformatf("oversized_pkt_cnt_reg: 0x%0h", rdata), UVM_NONE)

     phase.drop_objection(this,{"Dropping Objection ",get_type_name()});

  endtask

endclass : reg_check_on_read_test

class reg_introspect_test extends base_test;

    // convenience handle for the register block
    yapp_regs_c yapp_reg;

    // component macro
    `uvm_component_utils(reg_introspect_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      super.build_phase(phase);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    yapp_reg = tb.yapp_rm.yapp_regs;
  endfunction : connect_phase

  virtual task run_phase (uvm_phase phase);
     uvm_reg qregs[$], rwregs[$], roregs[$];

     phase.raise_objection(this, {"Raising Objection ",get_type_name()});
        yapp_reg.get_registers(qregs);

        foreach(qregs[i])
            `uvm_info("READ ALL", $sformatf("%s", qregs[i].get_name()), UVM_NONE)

        rwregs = qregs.find(i) with (i.get_rights() == "RW");

        foreach(rwregs[i])
            `uvm_info("READ RW", $sformatf("%s", rwregs[i].get_name()), UVM_NONE)

        roregs = qregs.find(i) with (i.get_rights() == "RO");

        foreach(roregs[i])
            `uvm_info("READ RO", $sformatf("%s", roregs[i].get_name()), UVM_NONE)

     phase.drop_objection(this,{"Dropping Objection ",get_type_name()});

  endtask

endclass : reg_introspect_test
