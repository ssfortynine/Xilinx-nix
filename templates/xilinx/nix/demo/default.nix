{ lib, newScope }:
lib.makeScope newScope (
  scope:
  let
    designTarget = "demo";
  in
  {
    # RTL
    rtl = scope.callPackage ./rtl.nix { target = designTarget; };

    # Verilator
    verilated = scope.callPackage ./verilated.nix { 
      enableTrace = false; 
    };
    verilated-trace = scope.verilated.override { enableTrace = true; };

    # VCS
    vcs = scope.callPackage ./vcs.nix { 
      enableTrace = false; 
    };
    vcs-trace = scope.vcs.override { enableTrace = true; };

    # vivado simulation flow
    vivado-scripts = scope.callPackage ./vivado-sim.nix { };
    vivado-sim-run = scope.vivado-scripts.sim-run;
    vivado-view-waves = scope.vivado-scripts.view-waves;

    # Verdi
    verdi = scope.callPackage ./verdi.nix { };
  }
)
