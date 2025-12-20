{ lib, newScope }:
lib.makeScope newScope (
  scope:
  let 
    tbTarget = "DemoTestBench";
    dpiLibName = "demomu";
  in
  {
    # TestBench
    tb-dpi-lib = scope.callPackage ./dpi-lib.nix { inherit dpiLibName; };

    # Verilator
    verilated = scope.callPackage ./verilated.nix {
      dpi-lib = scope.tb-dpi-lib;    
    };
    verilated-trace = scope.verilated.override {
      dpi-lib = scope.verilated.dpi-lib.override { enable-trace = true; };
    };

    # VCS
    vcs = scope.callPackage ./vcs.nix {
      dpi-lib = scope.tb-dpi-lib.override {
        sv2023 = false;
        vpi = true;
        timescale = 1000;
      };
    };
    vcs-trace = scope.vcs.override {
      dpi-lib = scope.vcs.dpi-lib.override { enable-trace = true; };
    };
    
  }
)
