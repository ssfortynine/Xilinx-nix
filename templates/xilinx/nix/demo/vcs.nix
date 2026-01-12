{
  lib,
  bash,
  stdenv,
  rtl,
  vcs-fhs-env,
  runCommand,
  target,
  enableTrace ? false,
  enableCover ? true,
}:
let 
  binName = "demo-vcs-simulator";
  coverageName = "coverage.vdb";
in
stdenv.mkDerivation (finalAttr: {
  name = "vcs";

  __noChroot = true;
  dontPatchELF = true;

  src = rtl;

  meta.mainProgram = binName;

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR 

    echo "[nix] running VCS"
    fhsBash=${vcs-fhs-env}/bin/vcs-fhs-env
    echo "[nix] Checking environment inside FHS..."
    "$fhsBash" -c "ls -d $VC_STATIC_HOME" || (echo "Error: VC_STATIC_HOME not accessible"; exit 1)

    VERDI_HOME=$("$fhsBash" -c "printenv VERDI_HOME")

    "$fhsBash" vcs \
      -sverilog \
      -full64 \
      -timescale=1ns/1ps \
      -P $VERDI_HOME/share/PLI/VCS/LINUX64/novas.tab $VERDI_HOME/share/PLI/VCS/LINUX64/pli.a \
    ${lib.optionalString enableTrace ''
      -debug_access+pp+dmptf+thread \
      -kdb=common_elab,hgldd_all \
      -assert enable_diag ''} \
    ${lib.optionalString enableCover ''
      -cm line+cond+fsm+tgl+branch+assert \
      -cm_dir ${coverageName} ''} \
      -top tb_${target} \
      -file filelist.f \
      -o ${binName}

    runHook postBuild
  '';

  passthru = {
    inherit vcs-fhs-env;
    inherit rtl;
    inherit enableTrace;

    tests.simple-sim = runCommand "${binName}-test" { __noChroot = true; }''
      export DEMO_SIM_RESULT_DIR="$(mktemp -d)"
      export DATA_ONLY=1
      ${finalAttr.finalPackage}/bin/${binName}

      mkdir -p "$out"
      cp -vr "$DEMO_SIM_RESULT_DIR"/result/* "$out/"
    '';
  };


  shellHook = ''
    echo "[nix] entering vcd fhs env"
    ${vcs-fhs-env}/bin/vcs-fhs-env
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp ${binName} $out/lib
    cp -r ${binName}.daidir $out/lib

    ${lib.optionalString enableCover ''cp -r ${coverageName} $out/lib''}

    substitute ${./scripts/vcs-wrapper.sh} $out/bin/${binName} \
      --subst-var-by lib "$out/lib" \
      --subst-var-by shell "${bash}/bin/bash" \
      --subst-var-by dateBin "$(command -v date)" \
      --subst-var-by vcsSimBin "$out/lib/${binName}" \
      --subst-var-by vcsSimDaidir "$out/lib/${binName}.daidir" \
      --subst-var-by vcsCovDir "${lib.optionalString enableCover "${coverageName}"}" \
      --subst-var-by vcsFhsEnv "${vcs-fhs-env}/bin/vcs-fhs-env"
    
    chmod +x $out/bin/${binName}

    runHook postInstall
  '';
})
