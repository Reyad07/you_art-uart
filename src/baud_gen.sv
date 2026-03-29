module baud_gen #(
    parameter int CLK_FREQ= 50,     // in MHz
    parameter int BAUD_RATE = 9600  // bps
)(
    input logic sys_clk,
    input logic rst_n,
    output logic tick       // single pulse
);

    localparam int TICK_COUNT = int'((CLK_FREQ*(10**6)/(BAUD_RATE*16.0)) + 0.5); // 0.5 helps with the rounding to nearest
    logic [$clog2(TICK_COUNT)-1:0] count;

    always_ff @ (posedge sys_clk) begin
        if (!rst_n) begin
            count <= '0;
            tick  <= '0;
        end
        else begin
            if (count == (TICK_COUNT-1)) begin
                count <= '0;
                tick  <= 1'b1;
            end
            else begin
                count <= count + 1;
                tick  <= '0;
            end
            
        end
    end

endmodule