#!@shell@

_EXTRA_ARGS="$@"

# TODO:Disable Synopsys's built-in stack tracing tool to prevent it from attempting to call GDB
export SNPS_NO_STACK_TRACE=1
export VCS_RUNTIME_OFF=1

if ((${VERBOSE:-0})); then
  set -x
fi

_LIB=@lib@
_DATE_BIN=@dateBin@
_VCS_SIM_BIN=@vcsSimBin@
_VCS_SIM_DAIDIR=@vcsSimDaidir@
_VCS_FHS_ENV=@vcsFhsEnv@
_VCS_COV_DIR=@vcsCovDir@

_NOW=$("$_DATE_BIN" "+%Y-%m-%d-%H-%M-%S")
_DEMO_SIM_RESULT_DIR=${DEMO_SIM_RESULT_DIR:-"demo-sim-result"}
_CURRENT="$_DEMO_SIM_RESULT_DIR"/all/"$_NOW"
mkdir -p "$_CURRENT"
ln -sfn "all/$_NOW" "$_DEMO_SIM_RESULT_DIR/result"

cp "$_VCS_SIM_BIN" "$_CURRENT/"
cp -r "$_VCS_SIM_DAIDIR" "$_CURRENT/"

if [ -n "$_VCS_COV_DIR" ]; then
  cp -vr "$_LIB/$_VCS_COV_DIR" "$_CURRENT/"
  _CM_ARG="-cm assert -cm_dir ./$_VCS_COV_DIR" 
fi

chmod -R +w "$_CURRENT"
pushd "$_CURRENT" >/dev/null

_emu_name=$(basename "$_VCS_SIM_BIN")
_daidir=$(basename "$_VCS_SIM_DAIDIR")

export LD_LIBRARY_PATH="$PWD/$_daidir:$LD_LIBRARY_PATH"

# Start the simulation, keeping `setarch -R` enabled to disable ASLR and improve simulation stability
echo "[wrapper] Starting VCS simulation..."
"$_VCS_FHS_ENV" -c "setarch $(uname -m) -R ./$_emu_name $_CM_ARG $_EXTRA_ARGS" &> >(tee ./vcs-emu-journal.log)

# If coverage is enabled, generate a text report.
if [ -n "$_VCS_COV_DIR" ]; then
  echo "[wrapper] Generating coverage report..."
  "$_VCS_FHS_ENV" -c "urg -dir ./$_VCS_COV_DIR -format text" &>> ./vcs-emu-journal.log
fi

if ((${DATA_ONLY:-0})); then
  rm -f "./$_emu_name"
fi

set -e _emu_name _daidir

echo "VCS emulator finished, result saved in $_DEMO_SIM_RESULT_DIR/result"
