`timescale 1ns/1ps

module tb_demo();

    reg clk;
    reg reset;
    reg enable;
    wire [7:0] out;

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

        #20;
        reset = 0;
        $display("[%0t] Reset released", $time);

        #10;
        enable = 1;
        $display("[%0t] Enable set to 1", $time);

        #1000; 
        $display("[%0t] Simulation reaches 1000ns, finishing...", $time);
        $finish;
    end

    initial begin
        #10000; 
        $display("Simulation Timeout");
        $finish;
    end

    initial begin
        string wave_path;
        if (!$value$plusargs("wave-path=%s", wave_path)) begin
            wave_path = "vcs_dump"; 
        end

        `ifdef VCS
            $display("VCS Waveform dumping enabled: %s.fsdb", wave_path);
            $fsdbDumpfile({wave_path, ".fsdb"});
            $fsdbDumpvars(0, tb_demo);
        `endif

    end

endmodule
