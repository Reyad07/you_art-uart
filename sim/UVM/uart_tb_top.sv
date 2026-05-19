import uvm_pkg::*;

`include "uvm_macros.svh"
`include "test/base_test.sv"

module uart_tb_top;

    localparam int CLK_FREQ = 1000000;
    localparam int BAUD_RATE = 9600;

    logic       clk = 0;
    logic       rst_n;
    logic       tx_new_data;
    logic [7:0] tx_data;
    logic       tx_done;
    logic [7:0] rx_data;
    logic       rx_done;
    logic       rx;
    logic       tx;

    uart_top #(
        .CLK_FREQ   (CLK_FREQ ),  // MHz
        .BAUD_RATE  (BAUD_RATE)
    )u_uart_top (
        .clk_i          ( clk         ),
        .rst_n          ( rst_n       ),
        .tx_new_data_i  ( tx_new_data ),
        .tx_data_i      ( tx_data     ),
        .tx_done_o      ( tx_done     ),
        .rx_data_o      ( rx_data     ),
        .rx_done_o      ( rx_done     ),
        .rx             ( rx          ),
        .tx             ( tx          )
    );

    initial begin
        string test_name;
        if (!$value$plusargs("TEST=%s", test_name)) begin
            test_name = "base_test";
        end

        $dumpfile("uart_tb_top.vcd");
        $dumpvars(0,uart_tb_top);

        // set configuration database for parameters
        uvm_config_db#(int)::set(uvm_root::get(),"parameter","CLK_FREQ",CLK_FREQ   );
        uvm_config_db#(int)::set(uvm_root::get(),"parameter","BAUD_RATE",BAUD_RATE );

        // run the specified uvm test
        run_test(test_name);

    end
    
endmodule
