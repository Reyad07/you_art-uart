/*
This module implements the slower clock logic

Data Packet: 
            start bit + Data frame + parity bit + Stop bit
------------------------------------------------------------
start bit: 1 bit
Data frame: 8 bit
Parity bit: TODO
Stop bit: 1 bit

CLK_FREQ = System Clock
Assuming it to be 1MHZ which means 1us time period

BAUD_RATE = 9600
Doing inverse gives: 0.1ms -> single bit duration of UART
this is very slow compare to system clock

ratio = bit duration = clock_count = CLK_FREQ/BAUD_RATE
half period = clock_count/2
*/

module uart_tx #(
    parameter int CLK_FREQ = 1000000,    // Hz
    parameter int BAUD_RATE = 9600
)(
    input   logic       clk_i,
    input   logic       rst_n,
    input   logic       tx_new_data_i, // 1: start sampling data that is present in tx_data_i
    input   logic [7:0] tx_data_i,    //TODO: parameterized?
    output  logic       tx, // output tx wire for RX pin
    output  logic       tx_done_o   // after transmission is done it will be high for single clk
);

    localparam clock_count = CLK_FREQ(/BAUD_RATE); // bit duration

    logic tx_clk = '0;  // transmitter clock
    logic [7:0] data;   // temp variable to hold tx_data_i
    int count;
    int tx_count;   // counter for tx to count up to 7 to ensure 8 bits transferred

    typedef enum logic [2:0] { IDLE=0, DATA, DONE } state_t;
    state_t state;

    always_ff @( poseedge clk_i ) begin
        if (count < (clock_count/2) begin
            count <= count + 1;
        end
        else begin
            count <= '0;
            tx_clk <= ~tx_clk;
        end
    end
    
    always_ff (poseedge tx_clk) begin
        if (~rst_n) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_done_o <= '0;
                    if (tx_new_data_i) begin
                        tx <= '0;
                        data <= tx_data_i;
                        state <= DATA;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                DATA: begin
                    if (tx_count <= 7) begin
                        tx_count <= tx_count + 1;
                        tx <= data[tx_count];
                        state <= DATA;
                    end
                    else begin
                        tx_count <= '0;
                        state <= DONE;
                    end 
                end
                DONE: begin
                    tx <= 1'b1; // send single stop bit
                    tx_done_o <= 1'b1;
                    state <= IDLE;
                end
            default: state <= IDLE
            endcase
        end
    end

endmodule