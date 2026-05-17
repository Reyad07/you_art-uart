module fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
) (
    //global signals
    input logic clk,
    input logic arst_n,

    //control signals
    input logic en,             // fifo enable
    input logic push_in,        // used to handle overrun
    input logic pop_in,         // used to handle underrun
    input logic [$clog2(DEPTH)-1:0] threshold, // unique to 16550A
    
    input logic [WIDTH-1:0] data_in,    // fifo data in
    output logic [WIDTH-1:0] data_out,  // fifo data out
    
    // status signals
    output logic empty,     // to indicate: fifo is full
    output logic full,      // to indicate: fifo is empty
    output logic underrun,  // indicates the consumer is too fast: fifo empty but trying to pop_in
    output logic overrun,   // indicates that producer is too fast: fifo is full but trying to push_in
    output logic thrs_trig  // unique to 16550A
);

    // internal logic signals
    logic pop_f;
    logic push_f;
    logic empty_f;
    logic full_f;
    logic underrun_f;
    logic overrun_f;
    logic thrs_trig_f;
    logic [$clog2(DEPTH)-1:0] ptr = '0;  // coutner for write address
    logic [WIDTH-1:0] mem [DEPTH];  // declaring memory

    // empty flag handling
    always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            empty_f <= 1'b0;
        end
        else begin
            case ({push_f,pop_f})       //! not all cases included
            2'b01: empty_f <= (~|(ptr) | ~en) ? 1'b1: 1'b0;
            2'b10: empty_f <= 1'b0;     // push_f means that we are trying to write so empty_f should be 0
            default: ;
            endcase
        end
    end

    // full flag handling
    always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            full_f <= 1'b0;
        end
        else begin
            case ({push_f,pop_f})         //! not all cases included
            2'b01: full_f <= 1'b0;
            2'b10: full_f <= ((ptr==DEPTH) | ~en ) ? 1'b1 : 1'b0;   // fifo full when ptr is equal to DEPTH
            default: ;
            endcase
        end
    end

    // write counter update
        always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            ptr <= '0;
        end
        else begin
            case ({push_f,pop_f})       //! not all cases included
            2'b01: begin
                if ((empty_f == 0) && (ptr != 0)) begin
                    ptr <= ptr - 1;
                end
                else begin
                    ptr <= ptr;
                end
            end
            2'b10: begin
                if ((full_f == 0) && (ptr != '1)) begin     // ! ptr should not be all 1
                    ptr <= ptr + 1;
                end
                else begin
                    ptr <= ptr;
                end
            end
            default: ;
            endcase
        end
    end

        // memory update
    always_ff @(posedge clk) begin
        case ({push_f,pop_f})
        2'b00: ;
        2'b01: begin
            for (int i = 0; i < (DEPTH-2); i++) begin       // condition: i<14 -> for DEPTH=16
                mem[i] <= mem[i+1];     // mem[0] <= mem[1], mem[1] <= mem[2],...
            end
            mem[DEPTH-1] <= '0;     // mem[15] in case of DEPTH=16
        end

        2'b10: begin
            mem[ptr] <= data_in;
        end
        2'b11: begin
            for (int i = 0; i < (DEPTH-2); i++) begin       // condition: i<14 -> for DEPTH=16
                mem[i] <= mem[i+1];     // mem[0] <= mem[1], mem[1] <= mem[2],...
            end
            mem[DEPTH-1] <= '0;     // mem[15] in case of DEPTH=16
            mem[ptr - 1] <= data_in;
        end
        default: ;
        endcase
    end

    // underrun handling
    always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            underrun_f <= '0;
        end
        else begin
            if ((empty_f==1'b1) && (pop_in==1'b1)) begin
                underrun_f <= 1'b1;
            end
            else begin
                underrun_f <= 1'b0;
            end
        end
    end

    // overrun handling
    always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            overrun_f <= '0;
        end
        else begin
            if ((full_f==1'b1) && (push_in==1'b1)) begin
                overrun_f <= 1'b1;
            end
            else begin
                overrun_f <= 1'b0;
            end
        end
    end

    // threshold handling
    always_ff @(posedge clk or negedge arst_n) begin
        if (~arst_n) begin
            thrs_trig_f <= '0;
        end
        else begin
            case ({push_f,pop_f})       //! not all cases included
                2'b10,2'b01: begin
                    thrs_trig_f <= (ptr >= threshold) ? 1'b1: 1'b0;
                end
                default: thrs_trig_f <= '0;
            endcase
        end
    end

    always_comb push_f = push_in && ~full;  // TODO: test with push_f = push_in && empty    
    always_comb pop_f = pop_in && ~empty;
    always_comb data_out = mem[0];      // always read from the 0th location
    always_comb thrs_trig = thrs_trig_f;
    always_comb full = full_f;
    always_comb empty = empty_f;
    always_comb overrun = overrun_f;
    always_comb underrun = underrun_f;

endmodule
