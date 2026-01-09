{
  description = "Xilinx Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = 
    inputs@{
      self, 
      nixpkgs,
      flake-parts,
      ...
    }:
    let 
      overlay = import ./nix/overlay.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [ 
          "x86_64-linux" 
          "aarch64-linux"
          "aarch64-darwin"
        ];
        
        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        flake.overlays.default = overlay;
        perSystem = 
        { system, pkgs, lib, ... }:
        let
          clean-script = pkgs.writeShellScriptBin "clean" ''
            echo "Cleaning build artifacts..."
            ${lib.getBin pkgs.git}/bin/git clean -fdX .
            echo "Clean complete."
          '';
        in
        {
          _module.args.pkgs = import nixpkgs {
              inherit system;
              overlays = [ overlay ];
              config.allowUnfree = true; 
          };

          packages.default = clean-script;
          apps.clean = {
            type = "app";
            program = lib.getExe clean-script;
          };

          legacyPackages = pkgs;

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.verible-verilog-format.enable = true;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # 开发辅助
              nixd
              verible
              gtkwave  
              pkgs.git
              clean-script
              xilinx-fhs-env
              vcs-fhs-env
            ];

            shellHook = ''
            # 1. Define ANSI Color Codes inside the shell script
            C='\033[0;36m'
            Y='\033[1;33m'
            R='\033[0;31m'
            NC='\033[0m' # No Color
          
            echo -e "''${C}======================================================"
            echo -e "      Welcome to xilinx-nix Development Shell"
            echo -e "======================================================''${NC}"
          
            # 2. Environment Status Check
            echo -e "''${Y}[Environment Status]''${NC}"
            check_env() {
              # Indirect expansion in Bash: eval to get the value of variable named $1
              local var_name=$1
              local var_val=$(eval echo "\$$var_name")
              
              if [ -z "$var_val" ]; then
                echo -e "  ❌ $var_name: ''${R}NOT SET''${NC}"
              else
                echo -e "  ✅ $var_name: ''${G}$var_val''${NC}"
              fi
            }
          
            check_env XILINX_STATIC_HOME
            check_env VC_STATIC_HOME
            check_env LM_LICENSE_FILE
          
            echo -e "\n''${Y}[Nix Command Examples (No Xilinx IP)]''${NC}"
            echo -e "  - ''${G}nix run '.#demo.rtl' --impure''${NC}"
            echo -e "  - ''${G}nix run '.#demo.vcs-trace' --impure -- +dump-start=0 +dump-end=10000''${NC}"
            echo -e "  - ''${G}nix run '.#demo.verdi' --impure''${NC}"
          
            echo -e "\n''${Y}[Xilinx Workflow Scripts]''${NC}"
            echo -e "  - ''${G}nix run '.#xilinx-simlib' --impure''${NC}"
            echo -e "  - ''${G}nix run '.#demo.vivado-sim-run' --impure''${NC}"
            echo -e "  - ''${G}nix run '.#demo.vivado-view-waves' --impure''${NC}"
          
            echo -e "\n''${Y}[Interactive FHS Envs]''${NC}"
            echo -e "  - ''${G}xilinx-fhs-env''${NC}"
            echo -e "  - ''${G}vcs-fhs-env''${NC}"
          
            echo -e "\n''${Y}[Other Commands]''${NC}"
            echo -e "  - ''${G}nix fmt''${NC}"
            echo -e "  - ''${G}nix run '.#clean''${NC}"
            echo ""
          '';
            
          };
        };
    };
}

