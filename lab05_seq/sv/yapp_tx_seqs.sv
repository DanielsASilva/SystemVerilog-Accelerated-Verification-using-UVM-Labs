/*-----------------------------------------------------------------
File name     : yapp_tx_seqs.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 01/04/11
Description   : YAPP UVC simple TX test sequence for labs 2 to 4
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

//------------------------------------------------------------------------------
//
// SEQUENCE: base yapp sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class yapp_base_seq extends uvm_sequence #(yapp_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_base_seq)

  // Constructor
  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : yapp_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_5_packets
//
//  Configuration setting for this sequence
//    - update <path> to be hierarchial path to sequencer 
//
//  uvm_config_wrapper::set(this, "<path>.run_phase",
//                                 "default_sequence",
//                                 yapp_5_packets::get_type());
//
//------------------------------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_5_packets)

  // Constructor
  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
  
endclass : yapp_5_packets

// Single packet to address 1
class yapp_1_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_1_seq)

  function new(string name="yapp_1_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr == 1; })
  endtask

endclass : yapp_1_seq

// Three packets with incrementing addresses
class yapp_012_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_012_seq)

  function new(string name="yapp_012_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_012_seq sequence", UVM_LOW)
    `uvm_do_with(req, {req.addr == 2'b00; })
    `uvm_do_with(req, {req.addr == 2'b01; })
    `uvm_do_with(req, {req.addr == 2'b10; })
  endtask

endclass : yapp_012_seq

// Three packets to address 1
class yapp_111_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_111_seq)

  function new(string name="yapp_111_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_111_seq sequence", UVM_LOW)
    repeat(3)
      `uvm_do_with(req, {addr == 1; })
  endtask

endclass : yapp_111_seq

// Two packets to the same (random) address
class yapp_repeat_addr_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_repeat_addr_seq)

  function new(string name="yapp_repeat_addr_seq");
    super.new(name);
  endfunction

  rand bit[1:0] randaddr;
  constraint c1 {randaddr != 2'b11; }

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq sequence", UVM_LOW)
    repeat(2)
      `uvm_do_with(req, {addr == randaddr; })
  endtask

endclass : yapp_repeat_addr_seq

// Single packet with incrementing payload data
class yapp_incr_payload_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_incr_payload_seq)

  int ok;

  function new(string name="yapp_incr_payload_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_incr_payload_seq sequence", UVM_LOW)
    `uvm_create(req)
    ok = req.randomize();
    for(int i = 0; i < req.length; i++) begin
      req.payload[i] = i;
    end
    req.set_parity();
    `uvm_send(req)

  endtask

endclass : yapp_incr_payload_seq

// Generates between 1 to 10 packets
class yapp_rnd_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_rnd_seq)

  function new(string name="yapp_rnd_seq");
    super.new(name);
  endfunction

  rand int count;
  constraint onetoten {count > 0; count <= 10; }

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing yapp_rnd_seq sequence with %0d packets", count), UVM_LOW)
    for(int i = 0; i < count; i++)
      `uvm_do(req)
  endtask

endclass : yapp_rnd_seq


// Do yapp_rnd_seq with count constrained to six
class six_yapp_seq extends yapp_base_seq;

  `uvm_object_utils(six_yapp_seq)

  function new(string name="six_yapp_seq");
    super.new(name);
  endfunction

  yapp_rnd_seq yrndseq;

  virtual task body();
    `uvm_info(get_type_name(), "Executing six_yapp_seq sequence", UVM_LOW)
    `uvm_do_with(yrndseq, {count == 6;})
  endtask

endclass : six_yapp_seq

class yapp_exhaustive_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_exhaustive_seq)

  yapp_1_seq y1seq;
  yapp_012_seq y012seq;
  yapp_111_seq y111seq;
  yapp_repeat_addr_seq yrepeat_addrseq;
  yapp_incr_payload_seq yincr_payloadseq;
  yapp_rnd_seq yrndseq;
  six_yapp_seq ysixseq;

  function new(string name="yapp_exhaustive_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_exhaustive_seq sequence", UVM_LOW)
    `uvm_do(y1seq)
    `uvm_do(y012seq)
    `uvm_do(y111seq)
    `uvm_do(yrepeat_addrseq)
    `uvm_do(yincr_payloadseq)
    `uvm_do(yrndseq)
    `uvm_do(ysixseq)
  endtask

endclass : yapp_exhaustive_seq
