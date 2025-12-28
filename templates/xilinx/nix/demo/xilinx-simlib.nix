{
  lib,
  stdenv,
  xilinx-fhs-env,
}:
stdenv.mkDerivation {
  name = "xilinx-simlib-vcs";
  
  _noChroot = true;
  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR 
    mkdir -p $out/simlib

    cat > gen_lib.tcl <<EOF
      compile_simlib -simulator vcs -family all -library all -directory ./simlib_dir
      exit
    EOF

    # Using xilinx environment to compile with Xilinx libraries
    ${xilinx-fhs-env}/bin/xilinx-fhs-env -c "vivado -mode batch -notrace -source gen_lib.tcl"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out
    # 将编译好的库拷贝到输出目录
    cp -r simlib_dir/* $out/
    
    runHook postInstall
  '';
}
