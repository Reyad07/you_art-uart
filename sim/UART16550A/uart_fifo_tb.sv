module uart_fifo_tb;

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

    uart_fifo #(
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
        
        // write data into the fifo -- DONE
        @(posedge clk);
        for (int i=0; i<20; i++) begin
            en      <= 1'b1;
            push_in <= 1'b1;
            pop_in  <= 1'b0;
            data_in <= $urandom();
            @(posedge clk);
        end
        foreach (u_fifo.mem[i]) begin
            $display("Contents of the FIFO after writing: mem[%0d]: %0h",i, u_fifo.mem[i]);
        end
                
        // read data from the fifo -- DONE
        // @(posedge clk);
        for (int i=0; i<20; i++) begin
            en      <= 1'b1;
            push_in <= 1'b0;
            pop_in  <= 1'b1;
            // data_in <= $urandom();
            @(posedge clk);
        end
        foreach (u_fifo.mem[i]) begin
            $display("Contents of the FIFO after Read: mem[%0d]: %0h",i, u_fifo.mem[i]);
        end

        @(posedge clk);
        $finish;
        
    end


endmodule