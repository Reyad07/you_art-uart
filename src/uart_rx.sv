module uart_rx #(
    parameter int CLK_FREQ = 1000000,    // Hz
    parameter int BAUD_RATE = 9600
)(
    input  logic       clk_i,
    input  logic       rst_n,
    input  logic       rx,          // The physical serial input wire

    output logic [7:0] rx_data_o,   // Parallel data byte received
    output logic       rx_done_o    // Pulse high when a full frame is ready
);

    localparam clock_count = (CLK_FREQ/BAUD_RATE); // bit duration

    logic rx_clk = '0;  // receiver clock
    logic [7:0] data;   // temp variable to hold tx_data_i
    int count;
    int rx_count;   // counter for tx to count up to 7 to ensure 8 bits transferred

    typedef enum logic [2:0] { IDLE=0, DATA, DONE } state_t;
    state_t state;

    always_ff @( posedge clk_i ) begin
        if (count < (clock_count/2)) begin
            count <= count + 1;
        end
        else begin
            count <= '0;
            rx_clk <= ~rx_clk;
        end
    end

    always_ff @(posedge rx_clk) begin
        if (~rst_n) begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE:begin
                    data <= '0;
                    rx_count <= '0;
                    rx_done_o <= '0;
                    if (rx == 1'b0) begin
                        state <= DATA;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                DATA:begin
                    if (rx_count <= 7) begin
                        rx_count <= rx_count + 1;
                        data <= {rx, data[7:1]};
                    end
                    else begin
                        rx_count <= '0;
                        state    <= DONE;
                    end
                end
                DONE:begin
                    rx_done_o <= 1'b1;
                    state   <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
