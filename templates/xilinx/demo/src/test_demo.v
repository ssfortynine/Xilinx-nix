module vivado_demo (
    input  wire       clk,      
    input  wire       reset,    
    input  wire       enable,
    output wire [7:0] out
);

    wire clk_inner;
    wire locked;
    reg [7:0] counter;

    clk_wiz_0 ip_clk_gen (
        .clk_in1  (clk),        
        .reset    (reset),      
        .clk_out1 (clk_inner),  
        .locked   (locked)      
    );

    always @(posedge clk_inner or posedge reset) begin
        if (reset) begin
            counter <= 8'h0;
        end else if (enable && locked) begin
            counter <= counter + 1'b1;
        end
    end

    assign out = counter;

endmodule
