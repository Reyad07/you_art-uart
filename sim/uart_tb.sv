module uart_tb;
    import LogColors::*;

    localparam int CLK_FREQ = 1000000;
    localparam int BAUD_RATE = 9600;

    logic       clk = 0;
    logic       rst_n;
    logic       tx_new_data;
    logic [7:0] tx_data;
    logic       tx_done;
    logic [7:0] rx_data;
    logic       rx_done;
    logic       rx;
    logic       tx;
    int         txpass = 0;
    int         rxpass = 0;
    localparam  LOOP =10;

    logic [7:0] txdata;    // for comparing data with RTL
    logic [7:0] rxdata;    // for comparing data with RTL

    uart_top #(
        .CLK_FREQ   (CLK_FREQ ),  // MHz
        .BAUD_RATE  (BAUD_RATE)
    )u_uart_top (
        .clk_i          ( clk         ),
        .rst_n          ( rst_n       ),
        .tx_new_data_i  ( tx_new_data ),
        .tx_data_i      ( tx_data     ),
        .tx_done_o      ( tx_done     ),
        .rx_data_o      ( rx_data     ),
        .rx_done_o      ( rx_done     ),
        .rx             ( rx          ),
        .tx             ( tx          )
    );

    always #5 clk = ~clk;

    task automatic apply_reset();
        $display ("%s::::::::::::::::APPLYING RESET::::::::::::::::%s",YELLOW,RESET);
        rst_n         <= '0;
        repeat(5) @(posedge clk);
        rst_n         <= 1'b1;
        $display ("%s::::::::::::::::REMOVING RESET::::::::::::::::%s",GREEN,RESET);
        tx_new_data   <= '0;
        tx_data       <= '0;
        rx            <= '0;
        @(posedge clk);

        $display("%sAFTER REMOVING RESET: tx_new_data:%0d tx_data:%0d rx:%0d%s\n",GREEN, tx_new_data, tx_data, rx, RESET);
    endtask

    task automatic compare (logic [7:0] RTL, logic [7:0] TB, bit type_);     // type_: 0 -> tx, type_:1 -> rx
        if (RTL!= TB) begin
            if (type_) begin 
                $display("%sRx did not match: RX_DATA = 0x%h     Expected RXDATA: 0x%h%s",RED, RTL, TB, RESET);
            end
            else begin
                $display("%sTX did not match: TX_DATA = 0x%h     Expected TXDATA: 0x%h%s",RED, RTL, TB, RESET);
            end
        end
        else
            if (type_) begin 
                rxpass++;
            end
            else begin
                txpass++;
            end
    endtask


    initial begin
        apply_reset();
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////// TRANMITTER   ////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        $display("%s||||||||||  UART Transmitter  ||||||||||%s",BLUE,RESET);
        for (int i = 0; i< LOOP; i++) begin
            tx_new_data <= 1'b1;        // indicate the start of transmitter transmission
            tx_data     <= $urandom;

            wait (tx == 0);             // wait for tx line to go low to indicate the start of transaction
            @(posedge u_uart_top.u_tx.tx_clk);

            for (int j = 0; j<8; j++) begin
                @(posedge u_uart_top.u_tx.tx_clk);
                txdata <= {tx,txdata[7:1]};
            end
            
            @(posedge tx_done);
            compare(tx_data,txdata,0);
        end
        $display("%s UART TX Passed: %0d/%0d %s\n",BLUE, txpass, LOOP, RESET);

        ///////////////////////////////////////////////////////////////////////////////////////////////////
        /// //////////////////////////// RECEIVER  ////////////////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////////////////////////////////////
        $display("\n%s||||||||||  UART Receiver  ||||||||||%s",MAGENTA,RESET);
        for (int i = 0; i< LOOP; i++) begin
            tx_new_data <= 1'b0;    // making sure the transmitter is turned off
            rx <= '0;               // at the start rx should be 0
            
            for (int j = 0; j < 8; j++) begin
                @(posedge u_uart_top.u_rx.rx_clk);
                rx = $urandom;
                rxdata <= {rx,rxdata[7:1]};
            end
            
            @(posedge rx_done);
            compare(rx_data,rxdata,1);
        end
        $display("%s UART RX Passed: %0d/%0d %s\n",MAGENTA, rxpass, LOOP, RESET);
        
        $finish;
    end
    
endmodule