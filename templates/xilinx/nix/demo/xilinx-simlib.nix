{
  lib,
  stdenv,
  vcs-fhs-env,
  xilinx-fhs-env,
}:
stdenv.mkDerivation {
  name = "xilinx-simlib-vcs";
  
  _noChroot = true;

  phase = ["installPhase", "buildPhase"];
  buildPhase = ''
    export HOME=$TMPDIR 
    mkdir -p $out/simlib

    # Using xilinx environment to compile with Xilinx libraries
    ${xilinx-fhs-env}/bin/xilinx-fhs-env -c "
      vivado -mode batch -notrace -source ${
        builtins.toFile "gen_lib.tcl" ''
          compile_simlib -simulator vcs -family all -library all -directory ./simlib
          exit
        ''
      }
    "
  '';

  installPhase = ''
    cp -r simlib/* $out/simlib
  '';
}
