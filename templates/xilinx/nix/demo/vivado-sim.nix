{ lib, writeShellScriptBin, xilinx-fhs-env, vcs-fhs-env }:
let
  sim-run = writeShellScriptBin "sim-run" ''
    set -e
    export XILINX_SIMLIB_PATH="$(readlink -f ./simlib_dir)"
    
    echo "[nix] Generating VCS scripts via Vivado"
    ${xilinx-fhs-env}/bin/xilinx-fhs-env -c "vivado -mode batch -source setup_vcs_verdi.tcl"

    echo "[nix] Locating and Patching simulation scripts"
     SIM_DIR_REL=$(find ./vivado_prj -path "*/sim_1/behav/vcs" -type d | head -n 1)
    
    if [ -z "$SIM_DIR_REL" ]; then
        echo "[Debug] Could not find simulation directory 'sim_1/behav/vcs' under ./vivado_prj"
        echo "[Debug] Found directories named vcs:"
        find ./vivado_prj -name "vcs" -type d
        exit 1
    fi
    
    SIM_DIR_ABS="$(readlink -f "$SIM_DIR_REL")"
    echo "[nix] Correct VCS simulation directory found at: $SIM_DIR_ABS"

    find "$SIM_DIR_ABS" -name "*.sh" -exec sed -i '1s|^.*$|#!/bin/bash|' {} +
    find "$SIM_DIR_ABS" -name "*.sh" -exec chmod +x {} +

    echo "[nix] Running VCS Simulation in vcs-fhs-env"
    
    ${vcs-fhs-env}/bin/vcs-fhs-env -c "cd $SIM_DIR_ABS && ./compile.sh"
    ${vcs-fhs-env}/bin/vcs-fhs-env -c "cd $SIM_DIR_ABS && ./elaborate.sh"
    ${vcs-fhs-env}/bin/vcs-fhs-env -c "cd $SIM_DIR_ABS && ./simulate.sh"

    echo "[nix] Simulation Finished"
    echo "[nix] Waveform file location:"
    find "$SIM_DIR_ABS" -name "*.fsdb"
    '';

  view-waves = writeShellScriptBin "view-waves" ''
    FSDB_PATH=$(find ./vivado_prj -name "*.fsdb" | head -n 1)
    DAI_PATH=$(find ./vivado_prj -name "*.daidir" -type d | head -n 1)
    export QT_SCALE_FACTOR=1.5

    if [ -z "$FSDB_PATH" ]; then
      echo "[Error] No .fsdb file found. Simulation might have failed."
      exit 1
    fi

    FSDB_ABS=$(readlink -f "$FSDB_PATH")
    echo "[nix] Opening FSDB: $FSDB_ABS"

    if [ -n "$DAI_PATH" ]; then
      DAI_ABS=$(readlink -f "$DAI_PATH")
      echo "[nix] Using Design Database: $DAI_ABS"
      ${vcs-fhs-env}/bin/vcs-fhs-env -c "verdi -dbdir \"$DAI_ABS\" -ssf \"$FSDB_ABS\""
    else
      echo "[Warning] No .daidir found. Opening waveform without design tree."
      ${vcs-fhs-env}/bin/vcs-fhs-env -c "verdi -ssf \"$FSDB_ABS\""
    fi
  '';
in
{
  inherit sim-run view-waves;
}
