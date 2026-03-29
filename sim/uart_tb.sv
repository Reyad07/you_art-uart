module uart_tb;

    localparam int CLK_FREQ = 50;
    localparam int BAUD_RATE = 9600;

    logic       clk_i = 0    ;
    logic       rst_n        ;
    logic [7:0] tx_data_i    ;
    logic       tx_start_i   ;
    logic       tx_busy_o    ;
    logic       tx_done_o    ;
    logic [7:0] rx_data_o    ;
    logic       rx_done_o    ;
    logic       rx_busy_o    ;
    logic       parity_err_o ;
    logic       framing_err_o;
    logic       uart_wire    ;

    uart_top #(
        .CLK_FREQ   (CLK_FREQ ),  // MHz
        .BAUD_RATE  (BAUD_RATE)
    )u_uart_top (
        .clk_i          (clk_i         ),
        .rst_n          (rst_n         ),
        .tx_data_i      (tx_data_i     ),
        .tx_start_i     (tx_start_i    ),
        .tx_busy_o      (tx_busy_o     ),
        .tx_done_o      (tx_done_o     ),
        .rx_data_o      (rx_data_o     ),
        .rx_done_o      (rx_done_o     ),
        .rx_busy_o      (rx_busy_o     ),
        .parity_err_o   (parity_err_o  ),
        .framing_err_o  (framing_err_o ),
        .uart_rx_i      (uart_wire     ),  
        .uart_tx_o      (uart_wire     )    
    );

    always #5 clk_i = ~clk_i;

    initial begin
        rst_n       <= 1'b0;
        tx_data_i   <= 8'h00;
        tx_start_i  <= 1'b0;
        repeat(5) @ (posedge clk_i);
        rst_n       <= 1'b1;
        tx_data_i   <= 8'hAA;
        tx_start_i  <= 1'b1;
        @(posedge clk_i);
        tx_start_i  <= 1'b0;

        wait(rx_done_o);
        repeat(2) @(posedge clk_i);

    end


endmodule