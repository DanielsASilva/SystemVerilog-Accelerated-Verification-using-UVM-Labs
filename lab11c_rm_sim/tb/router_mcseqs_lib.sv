class router_simple_mcseq extends uvm_sequence;
    `uvm_object_utils(router_simple_mcseq)
    `uvm_declare_p_sequencer(router_mcsequencer)

    yapp_012_seq yapp_012;
    six_yapp_seq six_yapp;

    hbus_small_packet_seq hbus_small_packet;
    hbus_read_max_pkt_seq hbus_read_max_pkt;
    hbus_set_default_regs_seq hbus_set_default_regs;

    function new(string name="router_simple_mcseq");
        super.new(name);
    endfunction : new

    // raise objection
    virtual task pre_body();
        if(starting_phase != null)
            starting_phase.raise_objection(this, get_type_name());
    endtask : pre_body

    virtual task body();
        // set the router to accept small packets and enable it
        `uvm_do_on(hbus_small_packet, p_sequencer.hbus_seqr)
        // read the router MAXPKTSIZE
        `uvm_do_on(hbus_read_max_pkt, p_sequencer.hbus_seqr)
        // send six consecutive YAPP packets to addresses 0,1,2
        repeat(6)
            `uvm_do_on(yapp_012, p_sequencer.yapp_seqr)
        // set the router to accept large packets
        `uvm_do_on(hbus_set_default_regs, p_sequencer.hbus_seqr)
        // read the router MAXPKTSIZE
        `uvm_do_on(hbus_read_max_pkt, p_sequencer.hbus_seqr)
        // send a random sequence of six YAPP packets
        `uvm_do_on(six_yapp, p_sequencer.yapp_seqr)
    endtask : body

    // drop objection
    virtual task post_body();
        if(starting_phase != null)
            starting_phase.drop_objection(this, get_type_name());
    endtask : post_body

endclass : router_simple_mcseq
