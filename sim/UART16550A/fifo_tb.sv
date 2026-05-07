module fifo_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 10;

    logic clk = '0;
    logic arst_n;
    logic en;
    logic push_in;
    logic pop_in; 
    logic [$clog2(DEPTH)-1:0] threshold;
    logic [WIDTH-1:0] data_in;
    logic [WIDTH-1:0] data_out;
    logic empty;   
    logic full;    
    logic underrun;
    logic overrun; 
    logic thrs_trig;

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_fifo (
        .clk       ( clk       ),
        .arst_n    ( arst_n    ),
        .en        ( en        ),
        .push_in   ( push_in   ),
        .pop_in    ( pop_in    ),
        .threshold ( threshold ),
        .data_in   ( data_in   ),
        .data_out  ( data_out  ),
        .empty     ( empty     ),
        .full      ( full      ),
        .underrun  ( underrun  ),
        .overrun   ( overrun   ),
        .thrs_trig ( thrs_trig )
    );

    always #5 clk = ~clk;

    initial begin
        en        <= '0;
        push_in   <= '0;
        pop_in    <= '0;
        threshold <= '0;
        data_in   <= '0;       
    end

    task automatic apply_reset();
        arst_n <= 1'b0;
        repeat (5) @(posedge clk);
        arst_n <= 1'b1;
    endtask

    task automatic initialize_values();
        en        <= '0;
        push_in   <= '0;
        pop_in    <= '0;
        threshold <= '0;
        data_in   <= '0;
    endtask


    initial begin

        apply_reset();
        initialize_values();

        // threshold configuration
        threshold <= 4'hb;
        
        // write data into the fifo
        @(posedge clk);
        for (int i=0; i<20; i++) begin
            en      <= 1'b1;
            push_in <= 1'b1;
            pop_in  <= 1'b0;
            data_in <= $urandom();
            @(posedge clk);
        end
        $display("After write loop:\n\t empty: %0d \n\t full: %0d \n\t underrun: %0d \n\t overrun: %0d \n\t thrs_trig: %0d \n\t",empty,full,underrun,overrun,thrs_trig);

        @(posedge clk);
        $finish;
        
    end


endmodule