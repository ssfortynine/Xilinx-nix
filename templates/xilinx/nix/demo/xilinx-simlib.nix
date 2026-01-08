{
  lib,
  stdenv,
  xilinx-fhs-env,
}:
stdenv.mkDerivation {
  name = "xilinx-simlib-vcs";
  
  __noChroot = true;
  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR 

    echo "[nix] running xilinx"
    fhsBash=${xilinx-fhs-env}/bin/xilinx-fhs-env

    mkdir -p $out/simlib

    cat > gen_lib.tcl <<EOF
      set_msg_config -id {Vivado 12-7166} -new_severity {WARNING}
      set_msg_config -id {Common 17-39} -new_severity {WARNING}
      set_param project.vcs_vlogan_options "-kdb -cpp /usr/bin/g++ -cc /usr/bin/gcc"
      set_param project.vcs_vhdlan_options "-kdb"
      compile_simlib -simulator vcs -family all -library all -directory ./simlib_dir
      exit
    EOF

    # Using xilinx environment to compile with Xilinx libraries
    "$fhsBash" -c "vivado -mode batch -notrace -source gen_lib.tcl"
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
