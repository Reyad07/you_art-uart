module uart_fifo_tb;

    logic clk = '0;
    logic arst_n;
    logic en;
    logic push_in;
    logic pop_in; 
    logic [3:0] threshold;
    logic [7:0] data_in;
    logic [7:0] data_out;
    logic empty;   
    logic full;    
    logic underrun;
    logic overrun; 
    logic thrs_trig;

    uart_fifo u_fifo (
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
        
        // write data into the fifo -- DONE
        @(posedge clk);
        for (int i=0; i<20; i++) begin
            threshold <= 4'ha;
            en      <= 1'b1;
            push_in <= 1'b1;
            pop_in  <= 1'b0;
            data_in <= $urandom();
            @(posedge clk);
        end
        // foreach (u_fifo.mem[i]) begin
        //     $display("Contents of the FIFO after writing: mem[%0d]: %0h",i, u_fifo.mem[i]);
        // end
                
        // read data from the fifo -- DONE
        // @(posedge clk);
        for (int i=0; i<20; i++) begin
            threshold <= 4'ha;
            en      <= 1'b1;
            push_in <= 1'b0;
            pop_in  <= 1'b1;
            // data_in <= $urandom();
            @(posedge clk);
            // if (i == 0) $writememh ("../sim/UART16550A/fifo_mem.txt", u_fifo.mem);
        end
        // foreach (u_fifo.mem[i]) begin
        //     $display("Contents of the FIFO after Read: mem[%0d]: %0h",i, u_fifo.mem[i]);
        // end

        @(posedge clk);
        $finish;
        
    end

    initial begin
        $dumpfile("uart_fifo.vcd");
        $dumpvars;
    end

    initial begin
        if ($test$plusargs("UART")) $display("UART16550 Testing.......");

    end


endmodule