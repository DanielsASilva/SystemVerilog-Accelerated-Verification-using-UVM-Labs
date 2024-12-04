class router_module_env extends uvm_env;
    `uvm_component_utils(router_module_env)

    uvm_analysis_export #(hbus_transaction) hbus_in;
    uvm_analysis_export #(yapp_packet) yapp_in;

    uvm_analysis_export #(channel_packet) chan0;
    uvm_analysis_export #(channel_packet) chan1;
    uvm_analysis_export #(channel_packet) chan2;

    router_reference  router_ref;
    router_scoreboard scoreboard;

    function new(string name, uvm_component parent=null);
        super.new(name, parent);
        hbus_in = new("hbus_in", this);
        yapp_in = new("yapp_in", this);

        chan0 = new("chan0", this);
        chan1 = new("chan1", this);
        chan2 = new("chan2", this);

    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scoreboard = router_scoreboard::type_id::create("scoreboad", this);
        router_ref = router_reference::type_id::create("reference", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        router_ref.score_out.connect(scoreboard.yapp_in);

        hbus_in.connect(router_ref.hbus_in);
        yapp_in.connect(router_ref.yapp_in);

        chan0.connect(scoreboard.chan0);
        chan1.connect(scoreboard.chan1);
        chan2.connect(scoreboard.chan2);

    endfunction : connect_phase

endclass : router_module_env
