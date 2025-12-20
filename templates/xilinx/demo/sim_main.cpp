#include <iostream>
#include <verilated.h>
#include "Vdemo.h"

// 只有在 Nix 传入了 --trace 时，VM_TRACE 宏才会被定义
#ifdef VM_TRACE
#include "verilated_vcd_c.h"
#endif

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vdemo* top = new Vdemo;

#ifdef VM_TRACE
    // 只要开启了 Trace 编译选项，就自动初始化波形
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");
    std::cout << "[SIM] Trace support detected. Waveform will be saved to waveform.vcd" << std::endl;
#endif

    top->clk = 0;
    top->reset = 1;

    int main_time = 0;
    while (main_time < 500) {
        if (main_time > 20) top->reset = 0;
        if ((main_time % 5) == 0) top->clk = !top->clk;

        top->eval();

#ifdef VM_TRACE
        // 自动 dump 波形
        tfp->dump(main_time);
#endif
        main_time++;
    }

    top->final();

#ifdef VM_TRACE
    tfp->close();
    delete tfp;
    std::cout << "[SIM] Simulation finished. Waveform file closed." << std::endl;
#endif

    delete top;
    return 0;
}
