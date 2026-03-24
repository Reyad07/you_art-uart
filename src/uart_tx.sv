module uart_tx #(
    parameter int CLK_FREQ = 50,    // MHz
    parameter int BAUD_RATE = 9600
)(
    input logic clk_i,
    input logic rst_n,
    input logic tx_start_i,
    input logic [7:0] tx_data_i,    //TODO: parameterized?
    input logic tick_i,
    output logic tx_busy_o,
    output logic tx_data_o, // output tx wire for RX pin
    output logic tx_done_o
);

    typedef enum logic [1:0] { IDLE, START, DATA_FRAME, STOP } state_t;
    state_t state, next_state;
    logic [7:0] data;   //internal register to store the tx_data_i temporarily

    baud_gen #(
    .CLK_FREQ (CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
     u_baud_gen (
    .sys_clk (clk_i  ),
    .rst_n   (rst_n  ),
    .tick    (tick_i )
    );

    always_ff @ (posedge clk_i) begin
        if (!rst_n) begin
            tx_busy_o <= '0;
            tx_data_o <= '0;
            tx_done_o <= '0;
            next_state <= IDLE;
        end
        else if (tick_i) begin
            case (state)
                IDLE:begin
                    if (tx_start_i) begin
                        next_state <= START;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end
                START: begin
                    
                end
                DATA_FRAME:begin
                    
                end
                STOP: begin
                    
                end
                default: next_state = IDLE;
            endcase
        end
    end

endmodule