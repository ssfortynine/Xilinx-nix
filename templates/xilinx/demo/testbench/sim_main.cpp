#include <iostream>
#include <verilated.h>
#include "Vdemo.h"  // Verilator 根据顶层模块名 Demo 生成
#include "verilated_vcd_c.h" // 用于波形追踪

int main(int argc, char** argv) {
    // 初始化 Verilator 参数
    Verilated::commandArgs(argc, argv);

    // 实例化顶层模块
    VDemo* top = new VDemo;

    // 波形追踪设置
    VerilatedVcdC* tfp = nullptr;
    const char* wave_file = Verilated::commandArgsPlusMatch("wave=");
    if (wave_file && wave_file[0] != '\0') {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("waveform.vcd");
        std::cout << "Tracing enabled, output: waveform.vcd" << std::endl;
    }

    // 初始化信号
    top->clk = 0;
    top->reset = 1;
    top->enable = 0;

    // 仿真循环
    int main_time = 0;
    while (main_time < 100) {
        // 在第 10 个时间单位释放复位
        if (main_time > 10) {
            top->reset = 0;
            top->enable = 1;
        }

        // 时钟翻转
        if ((main_time % 5) == 0) {
            top->clk = !top->clk;
        }

        // 评估模型
        top->eval();

        // 打印计数器输出（在时钟上升沿）
        if (top->clk && (main_time % 10 == 5)) {
            std::cout << "[Time " << main_time << "] Reset: " << (int)top->reset 
                      << " Enable: " << (int)top->enable 
                      << " Count: " << (int)top->out << std::endl;
        }

        // 导出波形
        if (tfp) tfp->dump(main_time);

        main_time++;
    }

    // 清理
    top->final();
    if (tfp) {
        tfp->close();
        delete tfp;
    }
    delete top;

    return 0;
}
