class router_reference extends uvm_component;
    `uvm_component_utils(router_reference)

    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_hbus)

    uvm_analysis_imp_yapp#(yapp_packet, router_reference) yapp_in;
    uvm_analysis_imp_hbus#(hbus_transaction, router_reference) hbus_in;

    uvm_analysis_port#(yapp_packet) score_out;

    bit [7:0] max_pktsize;
    bit [7:0] router_enable;

    int pkt_dropped, pkt_sent, pkt_badaddr, pkt_routerdisable, pkt_maxlength;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        hbus_in = new("hbus_in", this);
        score_out = new("score_out", this);
    endfunction : new

    function void write_hbus(hbus_transaction hbustr);
        `uvm_info(get_type_name(), $sformatf("Received HBUS Transaction: \n%s", hbustr.sprint()), UVM_MEDIUM)
        if(hbustr.hwr_rd == HBUS_WRITE) begin
            case(hbustr.haddr)
                'h1000: max_pktsize = hbustr.hdata;
                'h1001: router_enable = hbustr.hdata;
            endcase
        end
    endfunction : write_hbus

    function void write_yapp(yapp_packet pkt);
        `uvm_info(get_type_name(), $sformatf("YAPP Packet received:\n%s", pkt.sprint()), UVM_LOW)
        if(pkt.addr == 3) begin
            `uvm_warning(get_type_name(), "YAPP Packet dropped [INVALID ADDRESS]")
            pkt_badaddr++;
            pkt_dropped++;
        end else if(router_enable == 0) begin
            `uvm_warning(get_type_name(), "YAPP Packet dropped [ROUTER DISABLED]")
            pkt_routerdisable++;
            pkt_dropped++;
        end else if(pkt.length > max_pktsize) begin
            `uvm_warning(get_type_name(), "YAPP Packet dropped [EXCEEDED MAX LENGTH]")
            pkt_maxlength++;
            pkt_dropped++;
        end else begin
            `uvm_info(get_type_name(), "YAPP Packet sent to scoreboard", UVM_MEDIUM)
            score_out.write(pkt);
            pkt_sent++;
        end
    endfunction : write_yapp

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("\nPackets Sent: %0d Packets Dropped %0d\nBad Address: %0d Router Disabled: %0d Exceeded Max Length: %0d", pkt_sent, pkt_dropped, pkt_badaddr, pkt_routerdisable, pkt_maxlength), UVM_LOW)
    endfunction : report_phase

endclass : router_reference
