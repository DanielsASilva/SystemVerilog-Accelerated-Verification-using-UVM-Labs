class router_scoreboard_fifo extends uvm_scoreboard;

    // analysis fifo instantiations
    uvm_tlm_analysis_fifo #(yapp_packet) yapp_fifo;
    uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo;

    uvm_tlm_analysis_fifo #(channel_packet) chan0_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan1_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan2_fifo;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);

        yapp_fifo = new("yapp_fifo", this);
        hbus_fifo = new("hbus_fifo", this);

        chan0_fifo = new("chan0_fifo", this);
        chan1_fifo = new("chan1_fifo", this);
        chan2_fifo = new("chan2_fifo", this);

    endfunction : new

    `uvm_component_utils(router_scoreboard_fifo)

    bit [7:0] max_pktsize;
    bit [7:0] router_enable;

    int pkt_in, pkt_drop;
    int pkt0_count, pkt0_match, pkt0_mis;
    int pkt1_count, pkt1_match, pkt1_mis;
    int pkt2_count, pkt2_match, pkt2_mis;
    int pkt_badaddr, pkt_routerdisable, pkt_maxlength;

    task hbus_reg();
        hbus_transaction hbustr;
        forever begin
          hbus_fifo.get_peek_export.get(hbustr);
          `uvm_info(get_type_name(), $sformatf("Received HBUS Transaction: \n%s", hbustr.sprint()), UVM_MEDIUM)
          if(hbustr.hwr_rd == HBUS_WRITE) begin
              case(hbustr.haddr)
                  'h1000: max_pktsize = hbustr.hdata;
                  'h1001: router_enable = hbustr.hdata;
              endcase
          end
        end
    endtask : hbus_reg

    task packet_analysis();
        yapp_packet pkt;
        channel_packet cpkt;
        bit comp;

        forever begin
          yapp_fifo.get_peek_export.get(pkt);
          `uvm_info(get_type_name(), $sformatf("YAPP Packet received:\n%s", pkt.sprint()), UVM_LOW)
        if(router_enable == 0) begin
            `uvm_warning(get_type_name(), "YAPP Packet dropped [ROUTER DISABLED]")
            pkt_badaddr++;
            pkt_drop++;
        end else if(pkt.addr == 3 ) begin
            `uvm_warning(get_type_name(), "YAPP Packet dropped [INVALID ADDRESS]")
            pkt_routerdisable++;
            pkt_drop++;
        end else if(pkt.length > max_pktsize) begin
            `uvm_warning(get_type_name(), "YAPP Packet dropped [EXCEEDED MAX LENGTH]")
            pkt_maxlength++;
            pkt_drop++;
        end else begin
            pkt_in++;
            case(pkt.addr)

              2'b00:  begin
                          chan0_fifo.get_peek_export.get(cpkt);
                          `uvm_info(get_type_name(), "Got packet from channel 0 FIFO", UVM_HIGH)
                          comp = comp_uvm(pkt, cpkt);
                          if(comp == 1) begin
                              `uvm_info(get_type_name(), $sformatf("Channel 0: Package match\n%s", pkt.sprint()), UVM_LOW)
                              pkt0_match++;
                          end else begin
                              `uvm_info(get_type_name(), $sformatf("Channel 0: Package mismatch\nExpected:\n%s\nGot:\n%s", pkt.sprint(), cpkt.sprint()), UVM_LOW)
                              pkt0_mis++;
                          end
                      end
              2'b01:  begin
                          chan1_fifo.get_peek_export.get(cpkt);
                          `uvm_info(get_type_name(), "Got packet from channel 1 FIFO", UVM_HIGH)
                          comp = comp_uvm(pkt, cpkt);
                          if(comp == 1) begin
                              `uvm_info(get_type_name(), $sformatf("Channel 1: Package match\n%s", pkt.sprint()), UVM_LOW)
                              pkt1_match++;
                          end else begin
                              `uvm_info(get_type_name(), $sformatf("Channel 1: Package mismatch\nExpected:\n%s\nGot:\n%s", pkt.sprint(), cpkt.sprint()), UVM_LOW)
                              pkt1_mis++;
                          end
                      end
              2'b10:  begin
                          chan2_fifo.get_peek_export.get(cpkt);
                          `uvm_info(get_type_name(), "Got packet from channel 2 FIFO", UVM_HIGH)
                          comp = comp_uvm(pkt, cpkt);
                          if(comp == 1) begin
                              `uvm_info(get_type_name(), $sformatf("Channel 2: Package match\n%s", pkt.sprint()), UVM_LOW)
                              pkt2_match++;
                          end else begin
                              `uvm_info(get_type_name(), $sformatf("Channel 2: Package mismatch\nExpected:\n%s\nGot:\n%s", pkt.sprint(), cpkt.sprint()), UVM_LOW)
                              pkt2_mis++;
                          end
                      end
            endcase

        end
      end
    endtask : packet_analysis

    // custom packet compare function using inequality operators
   function bit comp_equal (input yapp_packet yp, input channel_packet cp);
      // returns first mismatch only
      if (yp.addr != cp.addr) begin
        `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
        return(0);
      end
      if (yp.length != cp.length) begin
        `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
        return(0);
      end
      foreach (yp.payload [i])
        if (yp.payload[i] != cp.payload[i]) begin
          `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
          return(0);
        end
      if (yp.parity != cp.parity) begin
        `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
        return(0);
      end
      return(1);
   endfunction : comp_equal

    // custom packet compare function using UVM
   function bit comp_uvm (input yapp_packet yp, input channel_packet cp, uvm_comparer comparer = null);
      if(comparer == null)
        comparer = new();

      if (!(comparer.compare_field("addr", yp.addr, cp.addr, 2))) begin
        `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
        return(0);
      end
      if (!(comparer.compare_field("length", yp.length, cp.length, 6))) begin
        `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
        return(0);
      end
      foreach (yp.payload [i])
        if (!(comparer.compare_field("payload[i]", yp.payload[i], cp.payload[i], 8))) begin
          `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
          return(0);
        end
      if (!(comparer.compare_field("parity", yp.parity, cp.parity, 1))) begin
        `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
        return(0);
      end
      return(1);
   endfunction : comp_uvm

  task run_phase(uvm_phase phase);
    fork
      packet_analysis();
      hbus_reg();
    join
  endtask : run_phase

  function void check_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Checking router scoreboard FIFOs...", UVM_LOW)
    if(yapp_fifo.is_empty() && chan0_fifo.is_empty() && chan1_fifo.is_empty() && chan2_fifo.is_empty() && hbus_fifo.is_empty())
      `uvm_info(get_type_name(), "Router scoreboard is empty", UVM_LOW)
    else
      `uvm_error(get_type_name(), $sformatf("Router scoreboard is NOT empty:\n YAPP: %0d Channel 0: %0d Channel 1:%0d Channel 2:%0d HBUS: %0d", yapp_fifo.size(), chan0_fifo.size(), chan1_fifo.size(), chan2_fifo.size(), hbus_fifo.size()))
  endfunction : check_phase

  function void report_phase(uvm_phase phase);
      `uvm_info(get_type_name(), $sformatf("\n[Total] Packets In: %0d Packets Dropped: %0d\n[Dropped] Bad Address: %0d Router Disabled: %0d Max Length Exceeded: %0d\n[Channel 0] Total:%0d Match: %0d Miscompare: %0d\n[Channel 1] Total:%0d Match: %0d Miscompare: %0d\n[Channel 2] Total:%0d Match: %0d Miscompare: %0d\n", pkt_in, pkt_drop, pkt_badaddr, pkt_routerdisable, pkt_maxlength, pkt0_count, pkt0_match, pkt0_mis, pkt1_count, pkt1_match, pkt1_mis, pkt2_count, pkt2_match, pkt2_mis), UVM_LOW)

      if((pkt0_mis + pkt1_mis + pkt2_mis + pkt_drop) > 0)
        `uvm_error(get_type_name(), "SIMULATION FAILED")
      else
        `uvm_info(get_type_name(), "SIMULATION PASSED", UVM_LOW)
  endfunction : report_phase

endclass : router_scoreboard_fifo
