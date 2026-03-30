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

    typedef enum logic [2:0] { IDLE=0, START, DATA_FRAME, PARITY, STOP } state_t;
    state_t state = IDLE;
    logic [7:0] data;           //internal register to store the tx_data_i temporarily
    logic [3:0] tick_count;     // counter for baud_gen tick
    logic [4:0] stop_count;     // counter for 2 stop bits
    logic [2:0] bit_indx;       // counter to track 8 bit of data fot the data frame
    logic parity_bit;           // store the parity bit internally
    logic tx_out;               // internal tx output
    
    always_comb parity_bit = ^data;
    always_comb tx_data_o = tx_out;
    
//    always_ff @(posedge clk_i) begin
//        if (!rst_n) begin
            
//        end
//        else if (tick_i) begin
//        end 
//    end 
    
    always_ff @ (posedge clk_i) begin
        if (!rst_n) begin
            tx_busy_o  <= '0;
            tx_out  <= 1'b1;  // by default tx line should be high
            tx_done_o  <= '0;
            tick_count <= '0;
            stop_count <= '0;
            bit_indx   <= '0;
            state      <= IDLE;
        end
        else if (tick_i) begin          //! no else statement
            case (state)
                IDLE:begin
                    tx_out <= 1'b1;
                    if (tx_start_i) begin
                        data <= tx_data_i;
//                        parity_bit <= ^data;    //! valid? or use comb block?
                        state <= START;
                        $display("State: %s",state.name);
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                START: begin
                    $display("State: %s",state.name);
                    tx_busy_o <= 1'b1;          // should be low in STOP
                    tx_out <= 1'b0;          //! for how long? -- SOLVED!
                    if (tick_count == 15) begin
                        tick_count <= '0;
                        state <= DATA_FRAME;
                    end
                    else begin
                        tick_count <= tick_count + 1;
                        state <= START;
                    end
                    
                end
                DATA_FRAME:begin
                    $display("State: %s",state.name);
                    if (bit_indx == 7) begin
                        $display("Bit Index 8");
                        bit_indx    <= '0;
                        state       <= PARITY;
                    end
                    else begin                              // if bit_indx < 7
                        if (tick_count == 15) begin
                            $display("=================================");
                            $display("Tick count 15 = %0d && bit_index = %0d",tick_count, bit_indx);
                            tick_count  <= '0;
                            tx_out   <= data[bit_indx];
                            bit_indx    <= bit_indx + 1;
//                            state  <= DATA_FRAME;
                        end
                        else begin
                            $display("tick_count = %0d",tick_count);
                            tick_count <= tick_count + 1;
                        end
                        state  <= DATA_FRAME;  // ! check next state placement logic
                    end
                end
                PARITY: begin
                    $display("State: %s",state.name);
                    tx_out <= parity_bit;
                    if (tick_count == 15) begin
                        tick_count <= '0;
                        state <= STOP;
                    end
                    else begin
                        tick_count <= tick_count + 1;
                        state <= PARITY;
                    end
                end
                STOP: begin
                    tx_out   <= 1'b1;
                    if(stop_count == 31) begin      // stop bit should remain high for atleast 2 bit duration = 16 + 16 = 32
                        $display("State: %s",state.name);
                        stop_count  <= '0;
                        tx_busy_o   <= '0;
                        tx_done_o   <= 1'b1;
                        state  <= IDLE;
                    end
                    else begin
                        stop_count  <= stop_count + 1;
                        state  <= STOP;
                    end
                end
                default: state = IDLE;
            endcase
        end
    end

endmodule