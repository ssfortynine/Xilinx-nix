{
  lib,
  writeShellScriptBin,
  xilinx-fhs-env,
}:
writeShellScriptBin "sim-flow" ''
  LOCAL_SIMLIB="$(readlink -f ./simlib_dir)"

  if [ -d "$LOCAL_SIMLIB" ]; then
    export XILINX_SIMLIB_PATH="$LOCAL_SIMLIB"
    echo "Using LOCAL simlib: $XILINX_SIMLIB_PATH"
  else
    echo "Error: Directory $LOCAL_SIMLIB not found!"
    echo "Please run your simlib generation script first."
    exit 1
  fi
  
  if [ ! -f "setup_vcs_verdi.tcl" ]; then
    echo "Error: setup_vcs_verdi.tcl not found!"
    exit 1
  fi

  ${xilinx-fhs-env}/bin/xilinx-fhs-env -c "vivado -mode batch -source setup_vcs_verdi.tcl"
''
