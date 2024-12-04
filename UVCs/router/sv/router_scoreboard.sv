class router_scoreboard extends uvm_scoreboard;

    `uvm_analysis_imp_decl(_yapp)

    `uvm_analysis_imp_decl(_chan0)
    `uvm_analysis_imp_decl(_chan1)
    `uvm_analysis_imp_decl(_chan2)

    `uvm_component_utils(router_scoreboard)

    uvm_analysis_imp_yapp#(yapp_packet, router_scoreboard) yapp_in;

    uvm_analysis_imp_chan0#(channel_packet, router_scoreboard) chan0;
    uvm_analysis_imp_chan1#(channel_packet, router_scoreboard) chan1;
    uvm_analysis_imp_chan2#(channel_packet, router_scoreboard) chan2;

    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        chan0 = new("chan0", this);
        chan1 = new("chan1", this);
        chan2 = new("chan2", this);
    endfunction : new

    yapp_packet queue0[$];
    yapp_packet queue1[$];
    yapp_packet queue2[$];

    int pkt_in, pkt_drop;
    int pkt0_count, pkt0_match, pkt0_mis, pkt0_drop;
    int pkt1_count, pkt1_match, pkt1_mis, pkt1_drop;
    int pkt2_count, pkt2_match, pkt2_mis, pkt2_drop;

    virtual function void write_yapp(yapp_packet pkt);
        yapp_packet clone_pkt;

        $cast(clone_pkt, pkt.clone());
        pkt_in++;

        case(clone_pkt.addr)
            2'b00:  begin
                        queue0.push_back(clone_pkt);                       `uvm_info(get_type_name(), "Added packet to queue 0", UVM_HIGH)
                    end
            2'b01:  begin
                        queue1.push_back(clone_pkt);
                        `uvm_info(get_type_name(), "Added packet to queue 1", UVM_HIGH)
                    end
            2'b10:  begin
                        queue2.push_back(clone_pkt);
                        `uvm_info(get_type_name(), "Added packet to queue 2", UVM_HIGH)
                    end
            default:    begin
                           `uvm_info(get_type_name(), $sformatf("Package dropped: bad address = %d\n%s", clone_pkt.addr, clone_pkt.sprint()), UVM_LOW)
                           pkt_drop++;
                        end
        endcase

    endfunction : write_yapp

    virtual function void write_chan0(channel_packet cpkt);
      yapp_packet popped_packet;
      bit comp;
      pkt0_count++;

      if(queue0.size() == 0) begin
        `uvm_warning(get_type_name(), $sformatf("Channel 0: Queue empty, received unexpected package\n%s", cpkt.sprint()))
        pkt0_drop++;
      end

      comp = comp_equal(queue0[0], cpkt);

      if(comp == 1) begin
          popped_packet = queue0.pop_front();
          `uvm_info(get_type_name(), $sformatf("Channel 0: Package match\n%s", popped_packet.sprint()), UVM_LOW)
          pkt0_match++;
      end else begin
          `uvm_info(get_type_name(), $sformatf("Channel 0: Package mismatch\nExpected:\n%s\nGot:\n%s", queue0[0].sprint(), cpkt.sprint()), UVM_LOW)
          pkt0_mis++;
      end

    endfunction : write_chan0

    virtual function void write_chan1(channel_packet cpkt);
      yapp_packet popped_packet;
      bit comp;
      pkt1_count++;

      if(queue1.size() == 0) begin
        `uvm_warning(get_type_name(), $sformatf("Channel 1: Queue empty, received unexpected package\n%s", cpkt.sprint()))
        pkt1_drop++;
      end

      comp = comp_equal(queue1[0], cpkt);

      if(comp == 1) begin
          popped_packet = queue1.pop_front();
          `uvm_info(get_type_name(), $sformatf("Channel 1: Package match\n%s", popped_packet.sprint()), UVM_LOW)
          pkt1_match++;
      end else begin
          `uvm_info(get_type_name(), $sformatf("Channel 1: Package mismatch\nExpected:\n%s\nGot:\n%s", queue1[0].sprint(), cpkt.sprint()), UVM_LOW)
          pkt1_mis++;
      end

    endfunction : write_chan1

    virtual function void write_chan2(channel_packet cpkt);
      yapp_packet popped_packet;
      bit comp;
      pkt2_count++;

      if(queue2.size() == 0) begin
        `uvm_warning(get_type_name(), $sformatf("Channel 2: Queue empty, received unexpected package\n%s", cpkt.sprint()))
        pkt2_drop++;
      end

      comp = comp_equal(queue2[0], cpkt);

      if(comp == 1) begin
          popped_packet = queue2.pop_front();
          `uvm_info(get_type_name(), $sformatf("Channel 2: Package match\n%s", popped_packet.sprint()), UVM_LOW)
          pkt2_match++;
      end else begin
          `uvm_info(get_type_name(), $sformatf("Channel 2: Package mismatch\nExpected:\n%s\nGot:\n%s", queue2[0].sprint(), cpkt.sprint()), UVM_LOW)
          pkt2_mis++;
      end

    endfunction : write_chan2

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

   function void report_phase(uvm_phase phase);
      `uvm_info(get_type_name(), $sformatf("\n[Total] Packets In: %0d Packets Dropped: %0d\n[Channel 0] Total:%0d Match: %0d Miscompare: %0d Dropped: %0d\n[Channel 1] Total:%0d Match: %0d Miscompare: %0d Dropped: %0d\n[Channel 2] Total:%0d Match: %0d Miscompare: %0d Dropped: %0d\n", pkt_in, pkt_drop, pkt0_count, pkt0_match, pkt0_mis, pkt0_drop, pkt1_count, pkt1_match, pkt1_mis, pkt1_drop, pkt2_count, pkt2_match, pkt2_mis, pkt2_drop), UVM_LOW)

      if((pkt0_mis + pkt1_mis + pkt2_mis + pkt0_drop + pkt1_drop + pkt2_drop) > 0)
        `uvm_error(get_type_name(), "SIMULATION FAILED")
      else
        `uvm_info(get_type_name(), "SIMULATION PASSED", UVM_LOW)
   endfunction : report_phase

endclass : router_scoreboard
