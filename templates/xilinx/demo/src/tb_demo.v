`timescale 1ns/1ps

module tb_demo();

    // --- 信号定义 ---
    reg clk;
    reg reset;
    reg enable;
    wire [7:0] out;

    // --- 实例化设计单元 (UUT) ---
    demo uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .out(out)
    );

    // --- 时钟生成 (100MHz) ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // --- 激励逻辑 ---
    initial begin
        // 初始化信号
        reset = 1;
        enable = 0;

        // 等待几个时钟周期后释放复位
        #20;
        reset = 0;
        $display("[%0t] Reset released", $time);

        // 开启计数使能
        #10;
        enable = 1;
        $display("[%0t] Enable set to 1", $time);

        // 让仿真运行一段时间
        // 注意：这里必须有延迟，否则仿真会在 0ps 结束
        #1000; 

        $display("[%0t] Simulation reaches 1000ns, finishing...", $time);
        $finish;
    end

    // --- 自动结束逻辑 (防止死循环) ---
    initial begin
        #10000; // 即使上面的逻辑没跑完，10000ns 后强制退出
        $display("Simulation Timeout");
        $finish;
    end

    // --- 波形导出 (关键：适配 VCS 和 Verilator) ---
    initial begin
        string wave_path;
        // 尝试从命令行获取 +wave-path 参数
        if (!$value$plusargs("wave-path=%s", wave_path)) begin
            wave_path = "vcs_dump"; // 默认文件名
        end

        // 如果是 VCS 环境 (定义了 FSDB)
        `ifdef VCS
            $display("VCS Waveform dumping enabled: %s.fsdb", wave_path);
            $fsdbDumpfile({wave_path, ".fsdb"});
            $fsdbDumpvars(0, tb_demo);
        `endif

        // 如果是通用的 VCD 导出
        `ifndef VCS
            $display("Standard VCD dumping enabled: %s.vcd", wave_path);
            $dumpfile({wave_path, ".vcd"});
            $dumpvars(0, tb_demo);
        `endif
    end

    // 监控输出结果
    initial begin
        $monitor("[%0t] out = %d, enable = %b", $time, out, enable);
    end

endmodule
