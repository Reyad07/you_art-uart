module uart_top #(
    parameter int CLK_FREQ  = 1000000,    // Hz
    parameter int BAUD_RATE = 9600    
)(
    // System Signals
    input  logic       clk_i,
    input  logic       rst_n,

    // Transmitter Interface
    input   logic       tx_new_data_i,
    input   logic [7:0] tx_data_i,
    output  logic       tx_done_o,

    // Receiver Interface
    output logic [7:0] rx_data_o,
    output logic       rx_done_o,

    // Physical UART Pins (External World)
    input  logic       rx,  // Connects to external TX
    output logic       tx   // Connects to external RX
);

    uart_tx #(
        .CLK_FREQ   (CLK_FREQ ),
        .BAUD_RATE  (BAUD_RATE)
    ) u_tx (
        .clk_i          ( clk_i          ),
        .rst_n          ( rst_n          ),
        .tx_new_data_i  ( tx_new_data_i  ),
        .tx_data_i      ( tx_data_i      ),
        .tx             ( tx             ),
        .tx_done_o      ( tx_done_o      )    
    );

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ ),
        .BAUD_RATE (BAUD_RATE)
    ) u_rx (
        .clk_i          ( clk_i     ),
        .rst_n          ( rst_n     ),
        .rx            ( rx        ),      
        .rx_data_o      ( rx_data_o ),      
        .rx_done_o      ( rx_done_o )
    );

endmodule
