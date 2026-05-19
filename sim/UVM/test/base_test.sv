import uvm_pkg::*;

`include "uvm_macros.svh"

class base_test extends uvm_test;

    env env;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = env::type_id::create("env", this);
    endfunction

    

endclass
