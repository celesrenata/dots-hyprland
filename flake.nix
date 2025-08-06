{
  description = "NixOS adaptation of end-4's dots-hyprland using installer replication";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Official quickshell flake (our breakthrough discovery!)
    quickshell.url = "github:outfoxxed/quickshell";
    
    # Original dots-hyprland source (unchanged) - THE KEY INSIGHT
    dots-hyprland = {
      url = "github:end-4/dots-hyprland";
      flake = false; # Use as source only, don't build
    };
  };

  outputs = { self, nixpkgs, home-manager, quickshell, dots-hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      # Package overlays
      overlays.default = final: prev: {
        # Make quickshell available from official flake
        quickshell = quickshell.packages.${system}.default;
      };

      # Packages
      packages.${system} = {
        # Test utilities
        test-python-env = pkgs.writeShellScriptBin "test-python-env" ''
          #!/usr/bin/env bash
          echo "🧪 Testing dots-hyprland Python environment..."
          
          VENV_PATH="$HOME/.local/state/quickshell/.venv"
          
          if [[ ! -d "$VENV_PATH" ]]; then
            echo "❌ Virtual environment not found at $VENV_PATH"
            echo "💡 Run: home-manager switch"
            exit 1
          fi
          
          source "$VENV_PATH/bin/activate"
          python -c "
import sys
print(f'✅ Python {sys.version}')

try:
    import material_color_utilities
    print('✅ material-color-utilities')
except ImportError:
    print('❌ material-color-utilities')

try:
    import materialyoucolor
    print('✅ materialyoucolor')
except ImportError:
    print('❌ materialyoucolor')

try:
    import pywayland
    print('✅ pywayland')
except ImportError:
    print('❌ pywayland')
"
          deactivate
        '';
        
        # Test quickshell with clean config
        test-quickshell = pkgs.writeShellScriptBin "test-quickshell" ''
          #!/usr/bin/env bash
          echo "🧪 Testing quickshell with dots-hyprland config..."
          
          if [[ ! -d "$HOME/.config/quickshell" ]]; then
            echo "❌ No quickshell configuration found"
            echo "💡 Run: home-manager switch"
            exit 1
          fi
          
          cd "$HOME/.config/quickshell"
          echo "🚀 Starting quickshell (timeout 10s)..."
          timeout 10 ${pkgs.quickshell}/bin/quickshell 2>&1 | head -20
        '';
        
        # Default package for easy testing
        default = self.packages.${system}.test-python-env;
      };

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          nil
          git
          
          # Our test utilities
          self.packages.${system}.test-python-env
          self.packages.${system}.test-quickshell
        ];
        
        shellHook = ''
          echo "🚀 dots-hyprland installer replication development environment"
          echo ""
          echo "📋 Available commands:"
          echo "  test-python-env    - Test Python virtual environment"
          echo "  test-quickshell    - Test quickshell with config"
          echo "  home-manager switch - Apply configuration"
          echo ""
          echo "🎯 Current approach: Direct installer replication"
          echo "📁 Branch: $(git branch --show-current)"
          echo ""
          echo "🔑 Key insight: Python venv is critical, not FHS!"
        '';
      };

      # Home Manager module
      homeManagerModules.default = import ./modules/home-manager.nix;
      homeManagerModules.dots-hyprland = self.homeManagerModules.default;

      # Example Home Manager configuration
      homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.homeManagerModules.default
          {
            home.username = "user";
            home.homeDirectory = "/home/user";
            home.stateVersion = "24.05";
            
            programs.dots-hyprland = {
              enable = true;
              source = dots-hyprland; # Clean upstream source
              packageSet = "essential"; # or "minimal" or "all"
            };
          }
        ];
      };
    };
}
