# xilinx-nix

[简体中文](#简体中文) | [English](#english)

---

## 简体中文

`xilinx-nix` 是一个基于 Nix 的 FPGA/IC 开发环境模板。它在 [chisel-nix](https://github.com/chipsalliance/chisel-nix) 的基础上，增加了对 Xilinx Vivado 和 Synopsys VCS/Verdi 工具链的深度集成，旨在通过 Nix 的 FHS 环境解决 EDA 工具在现代 Linux 发行版上的依赖问题。

### 特性

- **环境隔离**：通过 Nix FHS 环境运行 Vivado、VCS 和 Verdi，无需担心宿主机系统库版本冲突。
- **自动化 Simlib**：一键编译 Xilinx 仿真库（针对 VCS）并持久化到 Nix Store。
- **自动化联合仿真**：提供从 Vivado IP 生成到 VCS 编译、Verdi 查看波形的全自动化流水线。
- **双仿真器支持**：支持传统的 Verilator 和商业级 VCS 仿真流。
- **确定性**：通过锁定 Nixpkgs 版本及 `buildFHSEnv`，确保 EDA 工具依赖的系统库环境高度稳定。
- **SpinalHDL 支持**：集成了基于 Scala 的 SpinalHDL 开发流，支持自动生成 Verilog 并无缝接入仿真流水线。

### 准备工作

由于 EDA 工具受版权保护且体积巨大，本项目通过 `impure` 模式读取外部安装路径。请确保：

1.  **安装路径**：强烈建议将工具安装在 `/opt` 下，以确保 Nix 构建用户（`nixbld`）具有读取权限。
2.  **环境变量**：在你的 `.bashrc` 或 `.zshrc` 中设置以下变量：
    ```bash
    export XILINX_STATIC_HOME=/opt/Xilinx
    export VC_STATIC_HOME=/opt/synopsys
    export LM_LICENSE_FILE=27000@your-license-server # 或指向您的 license 文件
    ```
3.  **Nix 配置**：由于 VCS 需要连接 License Server，需在 `/etc/nix/nix.conf` 或 NixOS 配置中开启沙盒放松模式：
    ```nix
    nix.settings.sandbox = "relaxed";
    ```

### 快速开始

```bash
mkdir new-fpga-project
cd new-fpga-project
git init
nix flake init -t github:ssfortynine/Xilinx-nix#xilinx
```

### 项目结构

- **`demo/src/`**: 存放 Verilog/SystemVerilog 源代码。
- **`demo/testbench/`**: 存放仿真测试平台文件（含 Verilator 的 C++ main）。
- **`nix/`**: 核心逻辑。包含 FHS 环境定义（`vcs-fhs-env.nix` 等）及仿真封装脚本。
- **`flake.nix`**: 项目入口，定义了所有 packages、devShells 及 Overlay。

### 使用指南

本项目通过 Overlay 机制扩展了 `nixpkgs`。你可以通过 `.#demo.<attr>` 构建不同的组件。

#### 1. 基础 RTL 仿真（不含 Xilinx IP）

| 目标 (Attribute) | 描述 |
| :--- | :--- |
| `.#demo.rtl` | 收集源码并自动生成 `filelist.f` |
| `.#demo.verilated` | 使用 Verilator 编译的仿真器 |
| `.#demo.vcs` | 使用 VCS 编译的仿真器 (Standalone) |
| `.#demo.vcs-trace` | 启用 FSDB 波形生成的 VCS 仿真器 |
| `.#demo.verdi` | 使用 Verdi 自动加载最新波形和设计数据库 |

**构建示例：**
```bash
nix build '.#demo.rtl' --impure  # 运行编译前必须要运行该步骤
nix run '.#demo.vcs-trace' --impure -- +dump-start=0 +dump-end=10000 +wave-path=trace
nix run '.#demo.verdi' --impure 
```
#### 2. Xilinx 自动化仿真流（包含 Xilinx IP）

- **编译 Xilinx 仿真库 (VCS)**：
  ```bash
  nix run '.#xilinx-simlib' --impure # 有bug正在更改
  ```
  ```bash
  nix develop --impure
  xilinx-fhs-env
  vivado -mode batch -notrace -eval "compile_simlib -simulator vcs -family all -library all -directory ./simlib_dir"
  ```
- **一键流水线 (在开发 Shell 中直接运行)**：
  - `sim-run`: 自动调用 Vivado 生成脚本 -> 自动 Patch 脚本路径 -> 调用 VCS 执行编译与仿真。
  - `view-waves`: 自动搜寻生成的 `.fsdb` 和 `.daidir` 并启动交互式 Verdi。

  ```bash
  nix run '.#demo.vivado-sim-run' --impure
  nix run '.#demo.vivado-view-waves' --impure
  ```
#### 3. SpinalHDL 开发流
需要在`default.nix`中修改是使用经典 rtl 仿真还是 spinal-rtl 仿真，其他流程与基础 rtl 仿真相同。

## 维护建议
### 更新依赖

若需更新 Nixpkgs，运行：
```bash
nix flake update
```    
### 格式化代码

本项目集成了 treefmt，支持 Nix 和 Verilog 格式化：
```bash
nix fmt
```

## 许可证
MIT

---

## English

`xilinx-nix` is a Nix-based development environment template for FPGA/IC design. Building upon the foundations of [chisel-nix](https://github.com/chipsalliance/chisel-nix), it introduces deep integration for Xilinx Vivado and Synopsys VCS/Verdi toolchains. It leverages Nix FHS (Filesystem Hierarchy Standard) environments to solve the notorious dependency issues of legacy EDA tools on modern Linux distributions.

### Features

- **Environment Isolation**: Run Vivado, VCS, and Verdi within Nix FHS containers without worrying about host system library conflicts.
- **Automated Simlib**: One-click compilation of Xilinx simulation libraries (optimized for VCS) with persistence in the Nix Store.
- **Automated Joint Simulation**: Provides a full pipeline from Vivado IP generation to VCS compilation and Verdi waveform viewing.
- **Dual Simulator Support**: Supports both open-source Verilator and commercial-grade Synopsys VCS simulation flows.
- **Determinism**: By locking Nixpkgs versions and using `buildFHSEnv`, it ensures highly stable system library environments for brittle EDA tools.
- **SpinalHDL Support**: Integrates a Scala-based SpinalHDL development workflow, supports automatic generation of Verilog and seamless integration into simulation pipelines.

### Prerequisites

As EDA tools are proprietary and massive, this project uses Nix's `impure` mode to reference external installations. Please ensure the following:

1.  **Installation Path**: It is **strongly recommended** to install EDA tools under `/opt` to ensure the Nix build users (`nixbld`) have the necessary read permissions.
2.  **Environment Variables**: Set the following in your `.bashrc` or `.zshrc`:
    ```bash
    export XILINX_STATIC_HOME=/opt/Xilinx
    export VC_STATIC_HOME=/opt/synopsys
    export LM_LICENSE_FILE=27000@your-license-server # Or point to your license file
    ```
3.  **Nix Configuration**: Since VCS needs to connect to a License Server during execution, you must enable "relaxed" sandboxing in `/etc/nix/nix.conf` or your NixOS configuration:
    ```nix
    nix.settings.sandbox = "relaxed";
    ```

### Quick Start

```bash
mkdir new-fpga-project
cd new-fpga-project
git init
nix flake init -t github:ssfortynine/xilinx-nix#xilinx
```

### Project Structure

- **`demo/src/`**: Verilog/SystemVerilog source files.
- **`demo/testbench/`**: Simulation testbenches (including C++ main for Verilator).
- **`nix/`**: Core logic, including FHS environment definitions (`vcs-fhs-env.nix`, etc.) and simulation wrapper scripts.
- **`flake.nix`**: Entry point, defining all packages, devShells, and Overlays.

### Usage Guide

This project extends `nixpkgs` via an Overlay. You can build or run different components using the `.#demo.<attr>` attributes.

#### 1. Basic RTL Simulation (No Xilinx IPs)

| Target (Attribute) | Description |
| :--- | :--- |
| `.#demo.rtl` | Collects sources and generates `filelist.f` automatically |
| `.#demo.verilated` | Simulator compiled using Verilator |
| `.#demo.vcs` | Standalone simulator compiled using VCS |
| `.#demo.vcs-trace` | VCS simulator with FSDB waveform generation enabled |
| `.#demo.verdi` | Wrapper to launch Verdi and auto-load the latest waveform/database |

**Execution Examples:**
```bash
nix build '.#demo.rtl' --impure        # Essential first step before compilation
nix run '.#demo.vcs-trace' --impure -- +dump-start=0 +dump-end=10000 +wave-path=trace
nix run '.#demo.verdi' --impure 
```

#### 2. Automated Xilinx Simulation Flow (With Xilinx IPs)

- **Compile Xilinx Simlibs (VCS)**:
  ```bash
  nix run '.#xilinx-simlib' --impure # There is a bug and it is being fixed 
  ```
  ```bash
  nix develop --impure
  xilinx-fhs-env
  vivado -mode batch -notrace -eval "compile_simlib -simulator vcs -family all -library all -directory ./simlib_dir"
  ```
- **Unified Pipeline (Run directly within the dev shell)**:
  - `sim-run`: Automated workflow: Call Vivado to generate scripts -> Auto-patch script paths -> Execute VCS compilation & simulation.
  - `view-waves`: Automatically search for generated `.fsdb` and `.daidir` files and launch interactive Verdi.

  ```bash
  nix run '.#demo.vivado-sim-run' --impure
  nix run '.#demo.vivado-view-waves' --impure
  ```
#### 3. SpinalHDL Development Flow 
You need to modify `default.nix` to determine whether to use classic RTL simulation or spinal-RTL simulation; the rest of the process is the same as basic RTL simulation.

### Maintenance

#### Update Dependencies
To update Nixpkgs and other flake inputs:
```bash
nix flake update
```

#### Code Formatting
This project integrates `treefmt` to support Nix and Verilog formatting:
```bash
nix fmt
```

### License
MIT
