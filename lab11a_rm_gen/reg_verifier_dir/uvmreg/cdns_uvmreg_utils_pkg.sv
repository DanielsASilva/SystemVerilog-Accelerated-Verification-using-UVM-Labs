//*************************************************************************//
//   ** Cadence Design Systems
//   //   **
//   //   ** (C) COPYRIGHT, Cadence Design Systems, Inc. 2016
//   //   ** All Rights Reserved
//   //   ** Licensed Materials - Property of Cadence Design Systems, Inc.
//   //   **
//   //   ** No part of this file may be reproduced, stored in a retrieval system,
//   //   ** or transmitted in any form or by any means --- electronic, mechanical,
//   //   ** photocopying, recording, or otherwise --- without prior written permission
//   //   ** of Cadence Design Systems, Inc.
//*************************************************************************//

`ifndef CDNS_UVMREG_CONFIG_DATA_DIR
`define CDNS_UVMREG_CONFIG_DATA_DIR .
`endif
`define CDNS_UVMREG_CONFIG_DATA_DIR_VALUE `"`CDNS_UVMREG_CONFIG_DATA_DIR`"

package cdns_uvmreg_utils_pkg;
        import uvm_pkg::*;
	`include "uvm_macros.svh"

	parameter string configuration_base_dir = `CDNS_UVMREG_CONFIG_DATA_DIR_VALUE ;

	typedef struct  {
                  string         name;
                  int unsigned   size;
                  int unsigned   lsb_pos;
                  string         access;
                  bit            volatile;
                  uvm_reg_data_t reset;
                  bit            has_reset;
                  bit            is_rand;
                  bit            individually_accessible;
                } uvm_reg_field_config_t;


	typedef struct  {
                  string          reg_type_name;
                  string          configUID;
                  string          name;
                  uvm_reg_addr_t  offset;
                  int unsigned    size_bytes;
                  int unsigned    addr_bits;
                  string          access;
                  int             is_array;
                  int             range;
                } uvm_reg_config_t;

	typedef struct {
                  uvm_reg_addr_t   base_addr;
                  int              n_bytes;
                  uvm_endianness_e endianess;
                  bit              byte_addr_t;
               } uvm_blk_config_t;



/******************************************
* Creating own factory : cdns_factory_base
*******************************************/

virtual class cdns_factory_base;
   pure virtual function uvm_object create(string typename, string pathname,string objectname);
endclass


class uvm_factory_proxy extends cdns_factory_base;
        virtual function uvm_object create(string typename, string pathname,string objectname);
                static uvm_factory factory = uvm_factory::get();
                create = factory.create_object_by_name(typename, pathname, objectname);
        endfunction
endclass

//Creating an handle for the base factory
cdns_factory_base factory;


function automatic void build_uvm_reg_fields (uvm_reg parent, ref uvm_reg_field_config_t props_t[], output uvm_reg_field out[$]);
    uvm_factory factory;
    factory = uvm_factory::get();
    foreach(props_t[idx]) begin
        uvm_reg_field_config_t f= props_t[idx];
        uvm_reg_field fld;
        $cast(fld,factory.create_object_by_type(uvm_reg_field::get_type(),parent.get_full_name(),f.name));
        fld.configure(parent,
               f.size,
               f.lsb_pos,
               f.access,
               f.volatile,
               f.reset,
               f.has_reset,
               f.is_rand,
               f.individually_accessible);
        out.push_back(fld);
    end
endfunction

virtual class cdns_uvm_reg extends uvm_reg;
	local static string  configUID;
	virtual function void setconfigUID(string a);
		configUID=a;
	endfunction
	virtual function string getconfigUID();
		return configUID;
	endfunction

        pure virtual function void build();

        function new(input string name="cdns_uvm_reg", int unsigned n_bits,int has_coverage);
              super.new(name,n_bits,has_coverage);
        endfunction
endclass


virtual 	class cdns_uvm_reg_block extends uvm_reg_block;
	virtual function void do_print (uvm_printer printer);
		uvm_reg_block b[$];
		uvm_reg r[$];
		uvm_vreg vr[$];
		uvm_mem m[$];

		get_blocks(b,UVM_NO_HIER);
		foreach(b[i])
			printer.print_object(b[i].get_name(), b[i]);

		get_registers(r,UVM_NO_HIER);
		foreach(r[i])
			printer.print_object(r[i].get_name(), r[i]);

		get_virtual_registers(vr,UVM_NO_HIER);
		foreach(vr[i]) 
			printer.print_object(vr[i].get_name(), vr[i]);

		get_memories(m,UVM_NO_HIER);
		foreach(m[i]) 
			printer.print_object(m[i].get_name(), m[i]);

		if(printer.m_scope.depth() ==1)
		begin
			uvm_reg_map mp[$];
			uvm_reg_map mp2[$];
			uvm_reg_map mp3[$];
			get_maps(mp);
			foreach(mp[idx]) 
				mp[idx].get_submaps(mp2,UVM_HIER);

			foreach(mp[i]) begin
				int q[$];

			q=mp2.find_first_index(item) with (item == mp[i]);
			if(q.size==0)
				mp3.push_back(mp[i]);
			end
			foreach(mp3[i])
				do_print_reg_map(0,printer,mp3[i],0);

		end
	endfunction

	function new(input string name="dut", int has_coverage=UVM_NO_COVERAGE);
		super.new(name, has_coverage);
	endfunction
endclass

function automatic void do_print_reg_map (int level=0,uvm_printer printer,uvm_reg_map self,uvm_reg_addr_t offset);
   // print props of self
   int i = 4*level;
   uvm_sequencer_base seqr = self.get_sequencer(UVM_HIER);
   string seqr_name = (seqr == null) ? "(none)" : seqr.get_full_name();
   

   
   printer.m_scope.down("xxxxx");

   printer.print_generic(self.get_name(),self.get_type_name(),0,$sformatf("id=@%0d seqr=%s offset=0x%0x size=0x%0x baseaddr=0x%0x",
									  self.get_inst_id(),seqr_name,offset,
									  self.get_size(),
									  self.get_base_addr()
									  ));
   
   
   // then descent below
   begin
      uvm_reg_map mp2[$];
      self.get_submaps(mp2,UVM_NO_HIER);
      foreach(mp2[idx])
	do_print_reg_map(level+1,printer,mp2[idx],self.get_submap_offset(mp2[idx]));
   end
   printer.m_scope.up(".");
endfunction   

function automatic void build_uvm_regs(uvm_reg_map map, uvm_reg_block pblock, uvm_reg_file pfile, ref uvm_reg_config_t f_props[], output uvm_reg out[$]);
     foreach(f_props[idx]) begin
        uvm_reg_config_t f= f_props[idx];
	if(f.is_array == 0) begin
	        cdns_uvm_reg reg_t;
	        uvm_object obj = factory.create(f.reg_type_name, pfile!=null ? pfile.get_full_name(): "",f.name);
        	assert($cast(reg_t,obj));
  	        reg_t.configure(pblock, pfile, "");
		reg_t.setconfigUID(f.configUID);
        	reg_t.build();
        	map.add_reg(reg_t, f.offset, f.access);
        	out.push_back(reg_t);
	end
	else if (f.is_array == 1) begin
		int unsigned array_offset;
		for(int i = 0; i < f.range; i++) begin
           		cdns_uvm_reg reg_t;
			uvm_object obj = factory.create(f.reg_type_name, pfile!=null ? pfile.get_full_name(): "", {f.name, $sformatf("[%0d]", i)});
           		array_offset = i * f.size_bytes;
			array_offset = array_offset / (f.addr_bits / 8);
           		assert($cast(reg_t,obj));
           		reg_t.configure(pblock, pfile, "");
           		reg_t.setconfigUID(f.configUID);
           		reg_t.build();
           		map.add_reg(reg_t, f.offset + array_offset, f.access);
           		out.push_back(reg_t);
		end
	end
	else begin
		`uvm_fatal("UVM_REG", "Configuartion File corrupted or wrongly generated. Please regenerate the configuration file. If you still have issues, contact Cadence Support Team (support@cadence.com).");
	end
     end
endfunction


  typedef uvm_blk_config_t uvm_blk_config_ta[];
  typedef uvm_blk_config_ta uvm_blk_config_tq[string];
  typedef uvm_reg_config_t uvm_reg_config_ta[];
  typedef uvm_reg_config_ta uvm_reg_config_tq[string];
  typedef uvm_reg_field_config_t uvm_reg_field_config_ta[];
  typedef uvm_reg_field_config_ta uvm_reg_field_config_tq[string];

  static bit isInit = read_all_uvm_reg({configuration_base_dir,"/yapp_router_regs_config.dat"});
  static uvm_reg_field_config_tq all_uvm_fld_config ;
  static uvm_reg_config_tq all_uvm_reg_config;
  static uvm_blk_config_tq all_uvm_blk_config;

  function automatic bit read_all_uvm_reg(string fname);
        integer fh = $fopen(fname,"r");
        string rname;
        integer c1;
        string cmd;
        int ele_num;

        int blk_num, mem_num;

        if(fh == 0)
		`uvm_fatal("DAT_ERR", "Unable to locate Configuration dat file.")

        while ($fscanf(fh,"%s %s %d\n",cmd,rname,ele_num)!=-1) begin
                if(cmd=="r") begin
                        uvm_reg_field_config_t c;
                        uvm_reg_field_config_t th[$];
                        repeat(ele_num) begin
                                void'($fscanf(fh,"%s %d %d %s %d %d %d %d %d\n",c.name,c.size,c.lsb_pos,c.access,c.volatile,c.reset,c.has_reset,c.is_rand,c.individually_accessible));
                                th.push_back(c);
                        end
                        all_uvm_fld_config[rname]=th;
                end
                if(cmd=="b") begin
                        uvm_reg_config_t x;
                        uvm_reg_config_t tr[$];
                        uvm_blk_config_t t;
                        uvm_blk_config_t blk[$];
                        void'($fscanf(fh,"%d %d %d %d %d %d\n",blk_num,mem_num,t.base_addr,t.n_bytes,t.endianess,t.byte_addr_t));
                        blk.push_back(t);
                        all_uvm_blk_config[rname]=blk;
                        repeat(ele_num) begin
                                void'($fscanf(fh,"%s %s %s %d %d %s %d %d %d\n",x.reg_type_name,x.configUID,x.name,x.offset,x.size_bytes,x.access,x.is_array,x.range, x.addr_bits));
                                tr.push_back(x);
                        end
                        all_uvm_reg_config[rname]=tr;
                end
        end
        $fclose(fh);
        return 1;
  endfunction

function automatic  uvm_reg_field_config_ta get_field_config(string fname);
	if(all_uvm_fld_config.exists(fname)) begin
		return all_uvm_fld_config[fname];
	end
endfunction

function automatic uvm_reg_config_ta get_reg_config(string fname);
        if(all_uvm_reg_config.exists(fname)) begin
        	return all_uvm_reg_config[fname];
	end
endfunction

function automatic uvm_blk_config_ta get_blk_config(string fname);
        if(all_uvm_blk_config.exists(fname)) begin
	        return all_uvm_blk_config[fname];
	end
endfunction

//Function to split the string with . operator
function automatic int find(int offset, string s);
	int i;
	for (i = offset; i < s.len(); i=i+1) begin
		if (s[i] == ".") begin
			return i;
		end
	end
endfunction
//Function to extract the top level name from hierarchical path seprated by "."
function automatic string extract_top(string full_path);
	int firstdot = find(0,full_path) - 1;
	string top_block = full_path.substr(0, firstdot);
	return top_block;
endfunction

function automatic void apply_hdl_paths(uvm_reg_block block);
        integer hdl_f = $fopen({configuration_base_dir,"/yapp_router_regs_hdlpaths.dat"},"r");
        string cmd;
        string name;
        string fname;
        string hdl_path;
        bit is_first;
        string kind;
	string top_blk= "model";
	uvm_reg fname_old;
	uvm_reg_field lookup_flds[string];
	uvm_reg_field fld_q[$];
        uvm_reg lookup_regs[string];
        uvm_reg reg_q[$];
        uvm_mem lookup_mems[string];
        uvm_mem mem_q[$];
        uvm_reg_block lookup_blks[string];
        uvm_reg_block blk_q[$];

        if(hdl_f == 0)
		`uvm_fatal("DAT_ERR", "Unable to locate HDL paths dat file.")

	//Check Fields
	block.get_fields(fld_q);
        foreach(fld_q[idx])
			lookup_flds[fld_q[idx].get_full_name]=fld_q[idx];

        //Check Registers
        block.get_registers(reg_q);
        foreach(reg_q[idx])
                    lookup_regs[reg_q[idx].get_full_name]=reg_q[idx];

        //Check Memories
        block.get_memories(mem_q);
        foreach(mem_q[idx])
                    lookup_mems[mem_q[idx].get_full_name]=mem_q[idx];

        //Check Blocks
        block.get_blocks(blk_q);
        foreach(blk_q[idx])
                    lookup_blks[blk_q[idx].get_full_name]=blk_q[idx];

	//Extract top level block name
        if(reg_q.size()) begin
                top_blk = extract_top(reg_q[0].get_full_name);
        end
        else if (mem_q.size()) begin
                top_blk = extract_top(mem_q[0].get_full_name);
        end
        else if (blk_q.size()) begin
                top_blk = extract_top(blk_q[0].get_full_name);
        end

        while ($fscanf(hdl_f,"%s %s %s %b %s\n", cmd, name, hdl_path, is_first, kind)!=-1) begin
		fname = {top_blk,".",name};
                if(cmd=="r") begin
                        int lsb, size;
                        if(lookup_regs.exists(fname)) begin
				lsb = 0; 
				size = lookup_regs[fname].get_n_bits();
                                lookup_regs[fname].add_hdl_path_slice(hdl_path, lsb, size, is_first, kind);
			   end
			else 
			  `uvm_warning("UVM_REG", $sformatf("%s register not found in the register model. Cannot set the HDL Path for it.",fname));
                end
		if(cmd=="f") begin
			int lsb, size;
			if(lookup_flds.exists(fname)) begin
				uvm_reg parent_reg = lookup_flds[fname].get_parent();
				lsb = lookup_flds[fname].get_lsb_pos();
				size = lookup_flds[fname].get_n_bits();
				parent_reg.add_hdl_path_slice(hdl_path, lsb, size, is_first, kind);
			end
			else 
			  `uvm_warning("UVM_REG_FIELD", $sformatf("%s field not found in the register model. Cannot set the HDL Path for it.",fname));
		end
                if(cmd=="b") begin
			//void'($fscanf(hdl_f, "%s\n",kind));
                        if(lookup_blks.exists(fname)) begin
                                lookup_blks[fname].clear_hdl_path();
                                lookup_blks[fname].add_hdl_path(hdl_path, .kind(kind));
                        end
			else 
			  `uvm_warning("UVM_REG_BLOCK", $sformatf("%s block not found in the register model. Cannot set the HDL Path for it.",fname));
                end
                if(cmd=="m") begin
                        int lsb, size;
			string kind;
                        if(lookup_mems.exists(fname)) begin
				lsb = 0;
				size = lookup_mems[fname].get_n_bits();
                                lookup_mems[fname].clear_hdl_path();
                                lookup_mems[fname].add_hdl_path_slice(hdl_path, lsb, size, is_first, kind);
                        end
			else 
			  `uvm_warning("UVM_MEM", $sformatf("%s memory not found in the register model. Cannot set the HDL Path for it.",fname));
                end
        end
        $fclose(hdl_f);
endfunction


endpackage

////////////////////////////////   EOF   ///////////////////////////////////////////////////
