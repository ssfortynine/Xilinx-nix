`timescale 1ns/1ps
module tb_MyTopLevel();
    logic clk = 0;
    logic reset = 1;
    logic io_cond0 = 0;
    logic io_cond1 = 0;
    wire [7:0] io_state;
    wire io_flag;

    MyTopLevel uut (
        .clk(clk),
        .reset(reset),
        .io_cond0(io_cond0),
        .io_cond1(io_cond1),
        .io_state(io_state),
        .io_flag(io_flag)
    );

    always #5 clk = ~clk;

    initial begin
        #20 reset = 0;      
        #20 io_cond0 = 1;   
        #100 io_cond0 = 0;  
        #20 io_cond1 = 1;   
        #50 $finish;        
    end
    initial begin
        string wave_path;
        
        if (!$value$plusargs("wave-path=%s", wave_path)) begin
            wave_path = "vcs_dump"; 
        end

        `ifdef VCS
            $display("VCS Waveform dumping enabled: %s.fsdb", wave_path);
            $fsdbDumpfile({wave_path, ".fsdb"});
            $fsdbDumpvars(0, tb_MyTopLevel);
        `endif
    end


endmodule
