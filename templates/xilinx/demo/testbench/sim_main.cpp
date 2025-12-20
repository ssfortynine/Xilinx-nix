#include <iostream>
#include <verilated.h>
#include "Vdemo.h"

// 注意：这里改为 #if 而不是 #ifdef
#if VM_TRACE
#include "verilated_vcd_c.h"
#endif

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vdemo* top = new Vdemo;

    // 使用 #if VM_TRACE 检查宏的值是否为 1
#if VM_TRACE
    std::cout << "[SIM] Trace support detected. Waveform will be saved to waveform.vcd" << std::endl;
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");
#endif

    top->clk = 0;
    top->reset = 1;
    top->enable = 0;

    int main_time = 0;
    while (main_time < 500) {
        if (main_time > 20) top->reset = 0;
        if (main_time > 30) top->enable = 1;
        if ((main_time % 5) == 0) top->clk = !top->clk;

        top->eval();

#if VM_TRACE
        if (tfp) tfp->dump(main_time);
#endif
        main_time++;
    }

    top->final();

#if VM_TRACE
    if (tfp) {
        tfp->close();
        delete tfp;
        std::cout << "[SIM] Simulation finished. Waveform file closed." << std::endl;
    }
#endif

    delete top;
    return 0;
}
