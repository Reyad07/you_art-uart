import uvm_pkg::*;

`include "uvm_macros.svh"

class seq_item extends uvm_sequence_item;

    rand logic       tx_new_data_i,
    rand logic [7:0] tx_data_i,
    rand bit         rx;

    function new (string name = "seq_item")
        super.new(name);
    endfunction

    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(tx_new_data_i, UVM_ALL_ON)
        `uvm_field_int(tx_data_i, UVM_ALL_ON)
        `uvm_field_int(rx, UVM_ALL_ON)
    `uvm_object_utils_end

    // Optional constraints if required

endclass
