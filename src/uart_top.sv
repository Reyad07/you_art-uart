module uart_top #(
    parameter int CLK_FREQ = 50,    // MHz
    parameter int BAUD_RATE = 9600    
)(
    // System Signals
    input  logic       clk_i,
    input  logic       rst_n,

    // Transmitter Interface
    input  logic [7:0] tx_data_i,
    input  logic       tx_start_i,
    output logic       tx_busy_o,
    output logic       tx_done_o,

    // Receiver Interface
    output logic [7:0] rx_data_o,
    output logic       rx_done_o,
    output logic       rx_busy_o,
    output logic       parity_err_o,
    output logic       framing_err_o,

    // Physical UART Pins (External World)
    input  logic       uart_rx_i,  // Connects to external TX
    output logic       uart_tx_o   // Connects to external RX
);

    baud_gen #(
        parameter int CLK_FREQ= 50,     // in MHz
        parameter int BAUD_RATE = 9600  // bps
    ) u_baud_gen (
        input logic sys_clk,
        input logic rst_n,
        output logic tick       // single pulse
    );

    uart_tx #(
        parameter int CLK_FREQ = 50,    // MHz
        parameter int BAUD_RATE = 9600
    ) u_tx (
        .clk_i      ,
        .rst_n      ,
        .tx_start_i     ,
        .tx_data_i      ,    //TODO: parameterized?
        .tick_i     ,
        .tx_busy_o      ,
        .tx_data_o      , // output tx wire for RX pin
        .tx_done_o      
    );
    uart_rx #(
        parameter int CLK_FREQ = 50,    // MHz
        parameter int BAUD_RATE = 9600
    )u_rx(
        input  logic       clk_i,
        input  logic       rst_n,
        input  logic       rx_i,          // The physical serial input wire
        input  logic       tick_i,        // 16x oversampling pulse from baud_gen
        
        output logic [7:0] rx_data_o,     // Parallel data byte received
        output logic       rx_done_o,     // Pulse high when a full frame is ready
        output logic       rx_busy_o,     // High while a frame is being sampled
        
        // Status Flags
        output logic       parity_err_o,  // High if calculated parity != received parity
        output logic       framing_err_o  // High if stop bits are not '1'
    );

endmodule