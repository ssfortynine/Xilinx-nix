#!@shell@

# default result directory
_RESULT_DIR="demo-sim-result/result"

if [ ! -d "$_RESULT_DIR" ]; then
    echo "Error: Result directory $_RESULT_DIR not found. Run simulation first."
    exit 1
fi

# find the first .daidir and .fsdb file in the result directory
_DAIDIR=$(ls -d $_RESULT_DIR/*.daidir 2>/dev/null | head -n 1)
_FSDB=$(ls $_RESULT_DIR/*.fsdb 2>/dev/null | head -n 1)
_VCD=$(ls $_RESULT_DIR/*.vcd 2>/dev/null | head -n 1)

if [ -z "$_DAIDIR" ]; then
    echo "Error: No .daidir found in $_RESULT_DIR"
    exit 1
fi

# create the Verdi command
_VERDI_CMD="verdi -dbdir $_DAIDIR"
if [ -n "$_FSDB" ]; then
    _VERDI_CMD="$_VERDI_CMD -ssf $_FSDB"
fi
if [ -n "$_VCD" ]; then
    _VERDI_CMD="$_VERDI_CMD -ssf $_VCD"
fi

echo "[nix-verdi] Opening: $_VERDI_CMD"

# enter FHS environment to execute
exec "@vcsFhsEnv@" -c "$_VERDI_CMD $@"
