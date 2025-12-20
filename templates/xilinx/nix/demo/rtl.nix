{
  lib,
  stdenvNoCC,
  target, 
}:
let
  fs = lib.fileset;
  
  rtlFiles = fs.fileFilter (file: 
    lib.hasSuffix ".v" file.name || lib.hasSuffix ".sv" file.name
  ) ./../../demo;

in
stdenvNoCC.mkDerivation {
  name = "${target}-rtl";

  src = fs.toSource {
    root = ./../..;
    fileset = rtlFiles;
  };

  # 纯文件处理逻辑
  dontBuild = true;

  passthru = {
    inherit target;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    cp -r ./* $out/

    pushd $out
    find . -type f \( -name "*.v" -o -name "*.sv" \) > ./filelist.f
    popd

    runHook postInstall
  '';
}
