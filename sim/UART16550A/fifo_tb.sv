module fifo_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

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

    task automatic apply_reset();
        arst_n <= 1'b1;
        repeat (5) @(posedge clk);
        arst_n <= 1'b0;
    endtask

    initial begin
        
    end


endmodule