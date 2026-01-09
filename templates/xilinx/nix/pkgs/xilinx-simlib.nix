{ lib, stdenv, xilinx-fhs-env }:

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

    mkdir -p simlib_dir
    mkdir -p $TMPDIR/logs

    cat > gen_lib.tcl <<'EOF'
      set_msg_config -id {Vivado 12-7166} -new_severity {WARNING}
      set_msg_config -id {Common 17-39} -new_severity {WARNING}
      compile_simlib -simulator vcs -family all -library all -directory ./simlib_dir
      exit
    EOF

    set +e
    "$fhsBash" -c "vivado -mode batch -notrace -source gen_lib.tcl" \
      > $TMPDIR/logs/vivado_compile_simlib.stdout 2> $TMPDIR/logs/vivado_compile_simlib.stderr
    vivado_rc=$?
    set -e

    echo "[nix] vivado exit code: $vivado_rc"
    echo "$vivado_rc" > $TMPDIR/logs/vivado_exit_code.txt

    mkdir -p simlib_dir

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    mkdir -p $out/logs
    cp -f $TMPDIR/logs/* $out/logs/ || true

    cp -r simlib_dir/. $out/ || true

    if [ -f "$out/logs/vivado_exit_code.txt" ] && [ "$(cat $out/logs/vivado_exit_code.txt)" != "0" ]; then
      echo "WARNING: compile_simlib exited non-zero; simlib may be partial." > $out/PARTIAL_SIMLIB
    fi

    runHook postInstall
  '';
}
