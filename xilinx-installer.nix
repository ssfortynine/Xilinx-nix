{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "xilinx-install-env";
    targetPkgs = (ps: with ps; 
    let
      # 修复 ncurses5 以提供 libtinfo.so.5，并包含 termlib 支持
      ncurses' = ncurses5.overrideAttrs (old: {
        configureFlags = old.configureFlags ++ [ "--with-termlib" ];
        postFixup = "";
      });
    in 
    [
      bash
      coreutils
      zlib
      lsb-release
      stdenv.cc.cc
      util-linux
      which
      procps
      glibc
      expat
      stdenv.cc.cc.lib      # 提供 libstdc++.so.6 (Vivado 必须)

      # https://github.com/NixOS/nixpkgs/issues/218534
      # postFixup would create symlinks for the non-unicode version but since it breaks
      # in buildFHSEnv, we just install both variants
      ncurses'
      (ncurses'.override { unicodeSupport = false; })
      xorg.libXext
      xorg.libX11
      xorg.libXrender
      xorg.libXtst
      xorg.libXi
      xorg.libXft
      xorg.libxcb
      # common requirements
      freetype
      fontconfig
      glib
      gtk2
      gtk3
      libxcrypt-legacy # required for Vivado
      python3

      (libidn.overrideAttrs (_old: {
        # we need libidn.so.11 but nixpkgs has libidn.so.12
        src = fetchurl {
          url = "mirror://gnu/libidn/libidn-1.34.tar.gz";
          sha256 = "sha256-Nxnil18vsoYF3zR5w4CvLPSrTpGeFQZSfkx2cK//bjw=";
        };
      }))

      # to compile some xilinx examples
      opencl-clhpp
      ocl-icd
      opencl-headers

      # from installLibs.sh
      graphviz
      (lib.hiPrio gcc)
      unzip
      nettools
    ]
  );
  profile = ''
    export LANG=C
    export LC_ALL=C
    export FONTCONFIG_FILE=/etc/fonts/fonts.conf
    export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:$LD_LIBRARY_PATH
  '';

  runScript = "bash";
}).env
