module uart_rx #(
    parameter int CLK_FREQ = 50,    // MHz
    parameter int BAUD_RATE = 9600
)(
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

    // internal registers for synchronization
    logic rx_sync_1;    // 1st stage
    logic rx_sync;      // 2nd stage

    typedef enum logic [2:0] { IDLE, START, DATA_FRAME, PARITY, STOP } state_t;
    state_t state = IDLE;
    logic [7:0] rx_shift_data;  //internal register to store the tx_data_i temporarily
    logic [3:0] tick_count;     // counter for baud_gen tick
    logic [4:0] stop_count;     // counter for stop count: 2bits
    logic [2:0] bit_indx;       // counter to track 8 bit of data fot the data frame

    logic neg_edge;     //! detect the start bit that goes from high to low
    always_comb neg_edge = (rx_sync_1 == 1'b1 && rx_sync == 1'b0);  //! if the previous(rx_sync_1 was 1) but the new rx_sync is 0
                                                                    //! then it is falling edge

    always_ff @(posedge clk_i) begin
        if (!rst_n) begin
            rx_sync_1   <= 1'b1;    // by default UART is HIGH
            rx_sync     <= 1'b1;    // by default UART is HIGH
        end
        else begin
            rx_sync_1   <= rx_i;        // might go to metastable
            rx_sync     <= rx_sync_1;   // settled data
        end
    end

    always_ff @(posedge clk_i) begin
        if(!rst_n) begin
            rx_data_o       <= '0;
            rx_done_o       <= '0;
            rx_busy_o       <= '0;
            parity_err_o    <= '0;
            framing_err_o   <= '0;
            rx_shift_data   <= '0;
            tick_count      <= '0;
            stop_count      <= '0;
            bit_indx        <= '0;
            state           <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    rx_done_o       <= '0;
                    rx_busy_o       <= '0;
                    tick_count  <= '0;
                    bit_indx    <= '0;
                    if (neg_edge) begin
                        state  <= START;
                    end
                    else begin
                        state  <= IDLE;
                    end
                end

                START: begin
                    rx_busy_o   <= 1'b1;
                    if (tick_i) begin
                        if(tick_count == 7) begin
                            if (!rx_sync) begin
                                tick_count  <= '0;
                                state  <= DATA_FRAME;
                            end
                            else begin
                                state  <= IDLE;        // as it was not a start bit
                            end
                        end
                        else begin
                            tick_count  <= tick_count + 1;
                        end
                    end
                    else begin
                        state  <= START;       //! check whether to stay in this state or go to IDLE
                    end
                end

                DATA_FRAME: begin
                    if (tick_i) begin
                        if (bit_indx == 8) begin
                            bit_indx    <= '0;
                            state  <= PARITY;
                        end
                        else begin
                            bit_indx    <= bit_indx + 1;
                            if (tick_count == 15) begin
                                tick_count      <= '0;
                                rx_shift_data   <= {rx_sync, rx_shift_data[7:1]};   // received data is stored in MSB and rest of them are 
                                                                                    // right shifted by 1 bit
                            end
                            else begin
                                tick_count  <= tick_count + 1;
                            end
                        end
                    end
                    else begin
                        state  <= DATA_FRAME;
                    end
                end

                PARITY: begin
                    if (tick_i) begin
                        if (tick_count == 15) begin
                            parity_err_o    <= (rx_sync != (^rx_shift_data));     // check for parity: whether they match or not
                            tick_count      <= '0;
                        end
                        else begin
                            tick_count  <= tick_count + 1;
                        end
                    end
                    else begin
                        state  <= PARITY;
                    end
                end

                STOP: begin
                    if (tick_i) begin
                        if (stop_count == 15) begin
                            if (!rx_sync) begin
                               framing_err_o    <= 1'b1;
                               state       <= IDLE;        //! check STOP state
                            end
                            else begin 
                                framing_err_o   <= 1'b0;
                            end
                        end
                        else if (stop_count == 31 && !framing_err_o) begin
                            if (!rx_sync) begin 
                                framing_err_o <= 1'b1;
                                state      <= IDLE;
                            end
                            else begin
                                framing_err_o   <= 1'b0;
                            end
                            stop_count  <= '0;
                        end
                        else begin
                            stop_count  <= stop_count + 1;
                        end
                    end
                    else begin
                        state  <= STOP;
                    end
                    rx_busy_o   <= 1'b0;
                    rx_done_o   <= 1'b1;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule