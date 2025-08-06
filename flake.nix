{
  description = "NixOS adaptation of end-4's dots-hyprland using FHS environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    
    # Official quickshell flake (our breakthrough discovery!)
    quickshell.url = "github:outfoxxed/quickshell";
    
    # Original dots-hyprland source (unchanged)
    dots-hyprland = {
      url = "github:end-4/dots-hyprland";
      flake = false; # Use as source only
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, quickshell, dots-hyprland, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          hyprland.overlays.default
        ];
      };
    in
    {
      # Package overlays
      overlays.default = final: prev: {
        # Make quickshell available
        quickshell = quickshell.packages.${system}.default;
        
        # Our FHS environment
        dots-hyprland-fhs = final.callPackage ./packages/fhs-environment {
          inherit quickshell;
          dots-hyprland-source = dots-hyprland;
        };
        
        # Test utilities
        test-fhs-environment = final.callPackage ./packages/fhs-environment/test.nix { };
      };

      # Packages
      packages.${system} = {
        # FHS environment for dots-hyprland
        fhs-environment = pkgs.dots-hyprland-fhs;
        
        # Test script
        test-fhs = pkgs.test-fhs-environment;
        
        # Default package
        default = pkgs.dots-hyprland-fhs;
      };

      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          nil
          git
          
          # Our packages for testing
          dots-hyprland-fhs
          test-fhs-environment
        ];
        
        shellHook = ''
          echo "🚀 dots-hyprland FHS development environment"
          echo ""
          echo "Available commands:"
          echo "  nix run .#fhs-environment  - Start dots-hyprland in FHS"
          echo "  nix run .#test-fhs         - Test FHS environment"
          echo "  test-fhs-environment       - Test FHS environment (direct)"
          echo ""
          echo "Current branch: $(git branch --show-current)"
        '';
      };

      # Home Manager module (coming next)
      homeManagerModules.default = import ./modules/home-manager.nix;
      homeManagerModules.dots-hyprland = self.homeManagerModules.default;

      # NixOS module (coming next)
      nixosModules.default = import ./modules/nixos.nix;
      nixosModules.dots-hyprland = self.nixosModules.default;
    };
}
