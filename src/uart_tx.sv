/*
Data Packet: 
            start bit + Data frame + parity bit + Stop bit
------------------------------------------------------------
start bit: 1 bit
Data frame: 8 bit
Parity bit: 1 bit
Stop bit: 2 bit
*/

module uart_tx #(
    parameter int CLK_FREQ = 50,    // MHz
    parameter int BAUD_RATE = 9600
)(
    input   logic       clk_i,
    input   logic       rst_n,
    input   logic       tx_start_i,
    input   logic [7:0] tx_data_i,    //TODO: parameterized?
    input   logic       tick_i,
    output  logic       tx_busy_o,
    output  logic       tx_data_o, // output tx wire for RX pin
    output  logic       tx_done_o
);

    typedef enum logic [2:0] { IDLE, START, DATA_FRAME, PARITY, STOP } state_t;
    state_t state, next_state;
    logic [7:0] data;           //internal register to store the tx_data_i temporarily
    logic [3:0] tick_count;     // counter for baud_gen tick
    logic [2:0] bit_indx;       // counter to track 8 bit of data fot the data frame
    logic parity_bit;           // store the parity bit internally

    always_ff @ (posedge clk_i) begin
        if (!rst_n) begin
            tx_busy_o  <= '0;
            tx_data_o  <= 1'b1;  // by default tx line should be high
            tx_done_o  <= '0;
            tick_count <= '0;
            bit_indx   <= '0;
            next_state <= IDLE;
        end
        else if (tick_i) begin          //! no else statement
            case (state)
                IDLE:begin
                    tx_data_o <= 1'b1;
                    if (tx_start_i) begin
                        data <= tx_data_i;
                        parity_bit <= ^data;    //! valid? or use comb block?
                        next_state <= START;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end
                START: begin
                    tx_busy_o <= 1'b1;          // should be low in STOP
                    tx_data_o <= 1'b0;          //! for how long? -- SOLVED!
                    if (tick_count == 15) begin
                        tick_count <= '0;
                        next_state <= DATA_FRAME;
                    end
                    else begin
                        tick_count <= tick_count + 1;
                        next_state <= START;
                    end
                    
                end
                DATA_FRAME:begin
                    if (bit_indx == 8) begin
                        bit_indx    <= '0;
                        next_state  <= PARITY;
                    end
                    else begin                              // if bit_indx < 7
                        if (tick_count == 15) begin
                            tick_count  <= '0;
                            tx_data_o   <= data[bit_indx];
                            bit_indx    <= bit_indx + 1;
                            // next_state  <= DATA_FRAME;
                        end
                        else begin
                            tick_count <= tick_count + 1;
                        end
                        next_state  <= DATA_FRAME;  // ! check next state placement logic
                    end
                end
                PARITY: begin
                    tx_data_o <= parity_bit;
                    if (tick_count == 15) begin
                        tick_count <= '0;
                        next_state <= STOP;
                    end
                    else begin
                        tick_count <= tick_count + 1;
                        next_state <= PARITY;
                    end
                end
                STOP: begin
                    tx_data_o   <= 1'b1;
                    if(tick_count == 31) begin      // stop bit should remain high for atleast 2 bit duration = 16 + 16 = 32
                        tick_count  <= '0;
                        tx_busy_o   <= '0;
                        tx_done_o   <= 1'b1;
                        next_state  <= IDLE;
                    end
                    else begin
                        tick_count  <= tick_count + 1;
                        next_state  <= STOP;
                    end
                end
                default: next_state = IDLE;
            endcase
        end
    end

endmodule