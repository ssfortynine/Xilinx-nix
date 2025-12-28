{
  lib,
  stdenv,
  bash,
  rtl,
  vcs-fhs-env,
  xilinx-simlib,
  enableTrace ? false,
}:
let 
  binName = "demo-vcs-xilinx-sim";
in
stdenv.mkDerivation {
    name = "vcs-xilinx";
    _noChroot = true;

    src = rtl;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      fhs="${vcs-fhs-env}/bin/vcs-fhs-env"

      # Prepare setup to xilinx libraries
      cp ${xilinx-simlib}/simlib/synopsys_sim.setup .
      chmod +x synopsys_sim.setup
      
      # Run vcs compilation
      "$fhs" vcs \
        -sverilog -full64 \
        -timescale=1ns/1ps \
        -ntb_opts dtm \
        -LMG_CORE_LIB \
        ${lib.optionalString enableTrace "-debug_access+all -kdb"} \
        -top tb_demo \
        -file filelist.f \
        -o ${binName}

      runHook postBuild
    '';

    installPhase = ''
      mkdir -p $out/bin $out/lib
      cp ${binName} $out/lib/
      cp -r ${binName}.daidir $out/lib/
      cp synopsys_sim.setup $out/lib/

      # Wrapper script
      cat > $out/bin/${binName} << EOF
      #!${bash}/bin/bash
      export VC_STATIC_HOME="$\VC_STATIC_HOME"
      cd \$(pwd)
      ln -sf $out/lib/synopsys_sim.setup .
      ${vcs-fhs-env}/bin/vcs-fhs-env -c "$out/lib/${binName} \$@"
      EOF

      chmod +x $out/bin/${binName}
    '';
  }
