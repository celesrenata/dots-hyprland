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
        
        # Material color utilities (disabled for now - needs proper hash)
        # material-color-utilities = pkgs.callPackage ./packages/material-color-utilities { };
        
        # Default package points to scripts
        default = self.packages.${system}.scripts;
      };

      # Home Manager module
      homeManagerModules.default = import ./modules/home-manager.nix;
      homeManagerModules.dots-hyprland = self.homeManagerModules.default;

      # NixOS module
      nixosModules.default = import ./modules/nixos-system.nix;
      nixosModules.dots-hyprland = self.nixosModules.default;

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
            
            # Enable dots-hyprland with Phase 4 advanced features
            programs.dots-hyprland = {
              enable = true;
              style = "illogical-impulse";
              
              # Phase 4: Advanced Features (testing without AI first)
              components = {
                hyprland = true;
                quickshell = true;
                theming = false;  # Phase 4: Material You theming (testing)
                ai = false;       # Phase 4: AI integration (testing)
                audio = true;
              };
              
              # Phase 4: Advanced features
              features = {
                overview = true;
                sidebar = true;        # Phase 4: Advanced sidebars
                notifications = true;
                mediaControls = true;
                screenCorners = true;  # Phase 4: Screen corner interactions
                onScreenKeyboard = false;
                cheatsheet = true;
              };
              
              keybinds = {
                modifier = "SUPER";
                terminal = "foot";
              };
            };
          }
        ];
      };

      # NixOS configurations for testing
      nixosConfigurations = {
        basic-test = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.default
            ./testing/vm-configs/basic-test-simple.nix
          ];
        };
      };

      # Formatter
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
