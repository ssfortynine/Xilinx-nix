{
  lib,
  stdenv,
  verilator,
  rtl,
  enableTrace ? false,
}:

let
  vName = "V${rtl.target}";
in
stdenv.mkDerivation {
  pname = "demo-verilated-sim";
  version = "0.1.0";

  src = ./../../demo; # 包含 sim_main.cpp
  nativeBuildInputs = [ verilator ];

  # Verilator 仿真通常需要链接编译后的代码
  buildPhase = ''
    runHook preBuild

    echo "[nix] Verilating and Building C++ Simulator..."

    verilator \
      --cc \
      -f ${rtl}/filelist.f \
      --top ${rtl.target} \
      --exe sim_main.cpp \
      --build \
      -j $NIX_BUILD_CORES \
      -o ${vName} \
      ${lib.optionalString enableTrace "--trace"} \
      -Wall

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    # Verilator 默认在 obj_dir 下生成二进制文件
    cp obj_dir/${vName} $out/bin/

    runHook postInstall
  '';

  # 禁用安全硬化标志，因为 Verilator 对特定的编译优化比较敏感
  hardeningDisable = [ "fortify" ];

  meta.mainProgram = vName;
}
