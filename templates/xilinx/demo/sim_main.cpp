#include <iostream>
#include <verilated.h>
#include "Vdemo.h"          // 必须与模块名 demo 一致
#include "verilated_vcd_c.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    // 实例化类名 Vdemo
    Vdemo* top = new Vdemo;

    VerilatedVcdC* tfp = nullptr;
    // 这里简单处理：只要运行参数里有 +wave 字符串就开启波形
    bool trace_enable = false;
    for (int i = 1; i < argc; i++) {
        if (std::string(argv[i]).find("+wave") != std::string::npos) {
            trace_enable = true;
            break;
        }
    }

    if (trace_enable) {
        Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("waveform.vcd");
        std::cout << "[SIM] Tracing enabled: waveform.vcd" << std::endl;
    }

    top->clk = 0;
    top->reset = 1;
    top->enable = 0;

    int main_time = 0;
    while (main_time < 200) {
        if (main_time > 20) top->reset = 0;
        if (main_time > 30) top->enable = 1;

        if ((main_time % 5) == 0) top->clk = !top->clk;

        top->eval();

        if (top->clk && (main_time % 10 == 5) && !top->reset) {
            std::cout << "[Time " << main_time << "] Count: " << (int)top->out << std::endl;
        }

        if (tfp) tfp->dump(main_time);
        main_time++;
    }

    top->final();
    if (tfp) { tfp->close(); delete tfp; }
    delete top;
    return 0;
}
