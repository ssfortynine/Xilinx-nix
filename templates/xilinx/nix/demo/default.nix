{ lib, newScope }:
lib.makeScope newScope (
  scope:
  {
    # Verilator
    verilated = scope.callPackage ./verilated.nix;
    verilated-trace = scope.verilated.override { enable-trace = true; };

    # VCS
    vcs = scope.callPackage ./vcs.nix {
      sv2023 = false;
      vpi = true;
      timescale = 1000;
    };
    vcs-trace = scope.vcs.override { enable-trace = true; };
    
  }
)
