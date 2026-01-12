{ mkSbtDerivation, openjdk17, sbt, lib, target }:

let
  sbtFlags = [
    "-Dsbt.boot.directory=.sbt/boot"
    "-Dsbt.ivy.home=.ivy2"
    "-Dcoursier.cache=.cache/coursier"
    "-Dsbt.global.base=.sbt"
    "-Dsbt.rootdir=true"
  ];
in
mkSbtDerivation {
  pname = "${target}-rtl";
  version = "0.1.0";

  src = ./../../demo/spinalsrc;

  depsWarmupCommand = ''
    export HOME=$(pwd)
    sbt ${lib.concatStringsSep " " sbtFlags} compile
  '';

  depsSha256 = "sha256-S8fXt/FDbkLy6M102WWKOr4WnZF8N/e5sY80tpeK/0M=";

  nativeBuildInputs = [ openjdk17 sbt ];

  buildPhase = ''
    export HOME=$(pwd)
    echo "[nix] Generating Verilog for ${target}..."
    sbt ${lib.concatStringsSep " " sbtFlags} \
        -Dsbt.offline=true \
        "set fork := false; runMain ${target}.MyTopLevelVerilog"
  '';

  installPhase = ''
    mkdir -p $out
    
    find hw/gen \( -name "*.v" -o -name "*.sv" \) -exec cp -v {} $out/ \;
    cp -v tb_${target}.sv $out/
    find $out -maxdepth 1 -type f \( -name "*.v" -o -name "*.sv" \) -printf "%f\n" > $out/filelist.f

    echo "[nix] Successfully installed RTL files and filelist.f to $out"
  '';
}
