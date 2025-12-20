{
  lib,
  stdenv,
  rtl,
  verilator,
  zlib,
  python3,
  thread-num ? 8,
  enableTrace ? false,
}:
let
  vName = "V${rtl.target}";
in
stdenv.mkDerivation {
  name = "verilated";

  src = rtl;

  nativeBuildInputs = [
    verilator
    python3
  ];

  # if tracing is enabled(especially in FST format), Verilator usually requires zlib
  propagatedBuildInputs = lib.optionals enableTrace [ zlib ];

  passthru = {
    inherit (rtl) target;
    inherit enableTrace;
  };

  meta.mainProgram = vName;

  buildPhase = ''
    runHook preBuild

    echo "[nix] running verilator"
    verilator \
      ${lib.optionalString enableTrace "--trace-fst"} \
      --timing \
      --threads ${toString thread-num} \
      -O1 \
      --main \
      --exe \
      --cc -f filelist.f --top ${rtl.target}

    echo "[nix] building verilated C lib"

    mkdir -p $out/share
    cp -r obj_dir $out/share/verilated_src

    cd obj_dir
    make -j "$NIX_BUILD_CORES" -f ${vName}.mk ${vName}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{include,lib,bin}
    cp *.h $out/include
    cp *.a $out/lib
    cp ${vName} $out/bin

    runHook postInstall
  '';

  hardeningDisable = [ "fortify" ];
}
