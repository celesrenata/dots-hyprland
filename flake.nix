{
  description = "NixOS dots-hyprland configuration - end-4's illogical-impulse adapted for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # OFFICIAL QUICKSHELL FLAKE - Critical dependency resolved!
    quickshell.url = "github:outfoxxed/quickshell";
  };

  outputs = { self, nixpkgs, home-manager, quickshell, ... }:
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
        # Quickshell from official flake - no custom derivation needed!
        quickshell = quickshell.packages.${system}.default;
        
        # Custom packages for dots-hyprland
        dots-hyprland-scripts = self.packages.${system}.scripts;
      };

      # Custom packages
      packages.${system} = {
        # Custom scripts package
        scripts = pkgs.callPackage ./packages/scripts { };
        
        # Default package points to scripts
        default = self.packages.${system}.scripts;
      };

      # Home Manager module
      homeManagerModules.default = import ./modules/home-manager.nix;
      homeManagerModules.dots-hyprland = self.homeManagerModules.default;

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Development tools
          nixpkgs-fmt
          nil
          git
          
          # Build tools for custom packages
          cmake
          pkg-config
          python3
        ] ++ [
          # Our custom scripts
          self.packages.${system}.scripts
          
          # Quickshell from the flake input directly
          quickshell.packages.${system}.default
        ];
        
        shellHook = ''
          echo "🚀 dots-hyprland development environment"
          echo "📦 Quickshell available from flake input"
          echo "🔧 Ready for Phase 3 implementation!"
          echo "📋 Available scripts:"
          echo "  - dots-hyprland-info"
          echo "  - dots-hyprland-setup" 
          echo "  - quickshell-reload"
        '';
      };

      # Example Home Manager configuration
      homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.homeManagerModules.default
          {
            home.username = "user";
            home.homeDirectory = "/home/user";
            home.stateVersion = "24.05";
            
            # Enable dots-hyprland with basic configuration
            programs.dots-hyprland = {
              enable = true;
              style = "illogical-impulse";
              
              # Phase 3 Priority 1: Foundation components
              components = {
                hyprland = true;
                quickshell = true;
                theming = false; # Disable for now
                ai = false; # Phase 4: Advanced Features
                audio = true;
              };
              
              # Phase 3 Priority 2: Core features
              features = {
                overview = true;
                sidebar = false; # Disable for now
                notifications = true;
                mediaControls = true;
                # Advanced features for Phase 4
                screenCorners = false;
                onScreenKeyboard = false;
                cheatsheet = true;
              };
            };
          }
        ];
      };

      # Formatter
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
