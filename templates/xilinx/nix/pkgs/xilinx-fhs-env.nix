{ getEnv', fetchFromGitHub }:
let
  nixpkgsSrcs = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "05730f34825134603957864f7fd94101e403d6fb"; # nixos-23.11
    hash = "sha256-SNC879Z986VcaY1H/0vG9yAn87A0G3x5iT9P6434390=";
  };

  lockedPkgs = import nixpkgsSrcs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  xilinxHome = getEnv' "XILINX_FHS_HOME"; 
  
in
lockedPkgs.buildFHSEnv {
  name = "xilinx-vitis-fhs-env";

  profile = ''
    export LC_NUMERIC="en_US.UTF-8"

    if [ -n "${xilinxHome}" ] && [ -d "${xilinxHome}" ]; then
      source ${xilinxHome}/Vitis_HLS/*/settings64.sh
    elif [ -d "$HOME/Xilinx/Vitis_HLS" ]; then
      source ~/Xilinx/Vitis_HLS/*/settings64.sh
    fi
    
    echo "Xilinx FHS Environment Loaded."
    echo "Check 'vitis' or 'vivado' command."
  '';

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
}
