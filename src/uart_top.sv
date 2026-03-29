module uart_top #(
    parameter int CLK_FREQ  = 50,    // MHz
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

    logic tick_i;

    baud_gen #(
        .CLK_FREQ (CLK_FREQ ),
        .BAUD_RATE(BAUD_RATE)  
    ) u_baud_gen (
        .sys_clk (clk_i),   
        .rst_n   (rst_n),
        .tick    (tick_i)
    );

    uart_tx #(
        .CLK_FREQ   (CLK_FREQ ),
        .BAUD_RATE  (BAUD_RATE)
    ) u_tx (
        .clk_i      (clk_i     ),
        .rst_n      (rst_n     ),
        .tx_start_i (tx_start_i),
        .tx_data_i  (tx_data_i ),
        .tick_i     (tick_i    ),
        .tx_busy_o  (tx_busy_o ),
        .tx_data_o  (uart_tx_o ),
        .tx_done_o  (tx_done_o )    
    );
    uart_rx #(
        .CLK_FREQ  (CLK_FREQ ),
        .BAUD_RATE (BAUD_RATE)
    )u_rx(
        .clk_i          (clk_i          ),
        .rst_n          (rst_n          ),
        .rx_i           (uart_rx_i      ),      
        .tick_i         (tick_i         ),      
        .rx_data_o      (rx_data_o      ),    
        .rx_done_o      (rx_done_o      ),    
        .rx_busy_o      (rx_busy_o      ),    
        .parity_err_o   (parity_err_o   ) , 
        .framing_err_o  (framing_err_o  )
    );

endmodule