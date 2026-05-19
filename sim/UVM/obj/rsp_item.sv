import uvm_pkg::*;

`include "uvm_macros.svh"

class rsp_item extends seq_item;

    // rand logic       tx_new_data_i,
    // rand logic [7:0] tx_data_i,
    // rand bit       rx;
    logic       tx_done_o
    logic [7:0] rx_data_o
    logic       rx_done_o
    bit         tx

    function new (string name = "rsp_item")
        super.new(name);
    endfunction

    `uvm_object_utils_begin(rsp_item)
        `uvm_field_int(tx_new_data_i, UVM_ALL_ON)
        `uvm_field_int(tx_data_i, UVM_ALL_ON)
        `uvm_field_int(rx, UVM_ALL_ON)
        `uvm_field_int(tx_done_o, UVM_ALL_ON)
        `uvm_field_int(rx_data_o, UVM_ALL_ON)
        `uvm_field_int(rx_done_o, UVM_ALL_ON)
        `uvm_field_int(tx, UVM_ALL_ON)
    `uvm_object_utils_end


endclass
