{
  lib,
  stdenv,
  verilator,
  zlib,
  rtl,
  enableTrace ? false,
  thread-num ? 8,
}:

let
  vName = "V${rtl.target}";
in
stdenv.mkDerivation {
  pname = "demo-verilated-sim";
  version = "0.1.0";

  src = ./../..; 
  nativeBuildInputs = [ verilator ];

  propagateBuildInputs = lib.optionals enableTrace [ zlib ];

  passthru = {
    inherit (rtl) target;
  };

  meta.mainProgram = vName;

  buildPhase = ''
    runHook preBuild

    echo "[nix] running verilator"
    
    verilator \
      ${lib.optionalString enableTrace "--trace"} \
      --timing \
      --threads ${toString thread-num} \
      -O1 \
      --exe sim_main.cpp \
      --cc -f ${rtl}/filelist.f \
      --top ${rtl.target} \
      --Mdir obj_dir \
      -Wall

    echo "[nix] building verilated simulator"

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
