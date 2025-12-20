#include <iostream>
#include <verilated.h>
#include "Vdemo.h"          
#include "verilated_vcd_c.h" // 必须包含这个头文件

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vdemo* top = new Vdemo;

    // --- 波形开启逻辑 ---
    Verilated::traceEverOn(true); // 开启追踪功能
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);          // 追踪深度
    tfp->open("waveform.vcd");    // 打开文件
    std::cout << "[SIM] Waveform dumping started: waveform.vcd" << std::endl;

    top->clk = 0;
    top->reset = 1;

    int main_time = 0;
    while (main_time < 500) { // 增加仿真时间确保有足够数据
        if (main_time > 20) top->reset = 0;
        if ((main_time % 5) == 0) top->clk = !top->clk;

        top->eval();

        // --- 核心：每一时刻都要 dump 数据 ---
        tfp->dump(main_time); 
        
        main_time++;
    }

    top->final();
    tfp->close(); // 必须 close，否则文件可能损坏或为空
    delete tfp;
    delete top;
    return 0;
}
