`timescale 1ns/1ps

module tb_demo();
    logic       clk;
    logic       reset;
    logic       enable;
    logic [7:0] out;

    demo uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        reset = 1;
        enable = 0;

        #50;
        reset = 0;
        $display("[%0t] Reset released, waiting for IP Lock...", $time);

        #100;
        enable = 1;
        
        #2000; 
        $display("[%0t] Simulation finished", $time);
        $finish;
    end

endmodule
