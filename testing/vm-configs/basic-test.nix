{ config, lib, pkgs, ... }:

{
  imports = [ ../../modules/nixos-system.nix ];

  # VM-specific configuration
  virtualisation = {
    memorySize = 4096;
    # cores = 4;  # This option doesn't exist in NixOS
    qemu.options = [
      "-vga virtio"
      "-display gtk,gl=on"
      "-device virtio-gpu-pci"
      "-smp 4"  # Set CPU cores this way
    ];
    # Enable KVM if available
    qemu.package = pkgs.qemu_kvm;
  };

  # Enable dots-hyprland system integration
  services.dots-hyprland = {
    enable = true;
    
    # Hardware configuration for VM
    hardware = {
      nvidia = false;
      amd = false;
      intel = true;
      bluetooth = false; # Disable for VM testing
      audio = true;
      printing = false;
    };
    
    # Display manager
    displayManager = "gdm";
    
    # Security
    security = {
      polkit = true;
      keyring = true;
      firewall = true;
      apparmor = false; # Disable for VM testing
    };
    
    # Network
    networking = {
      networkmanager = true;
      wireless = false; # Use wired in VM
      vpn = false;
    };
    
    # Development tools for testing
    development = {
      enable = true;
      languages = [ "python" "nodejs" ];
    };
  };

  # Test user configuration
  users.users.testuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ];
    password = "test123";
    shell = pkgs.bash;
  };

  # Home Manager configuration for test user
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    users.testuser = {
      imports = [ ../../modules/home-manager.nix ];
      
      # Enable dots-hyprland with basic configuration
      programs.dots-hyprland = {
        enable = true;
        style = "illogical-impulse";
        
        # Phase 6: Enable all working components for testing
        components = {
          hyprland = true;
          quickshell = true;
          theming = false;  # Will enable after testing
          ai = false;       # Will enable after testing
          audio = true;
        };
        
        # Core features for testing
        features = {
          overview = true;
          sidebar = false;  # Will enable after testing
          notifications = true;
          mediaControls = true;
          screenCorners = false;
          onScreenKeyboard = false;
          cheatsheet = true;
        };
        
        keybinds = {
          modifier = "SUPER";
          terminal = "foot";
        };
      };
      
      # Test-specific configuration
      home.username = "testuser";
      home.homeDirectory = "/home/testuser";
      home.stateVersion = "24.05";
    };
  };

  # Testing utilities
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    iotop
    nethogs
    
    # Performance testing
    stress
    stress-ng
    sysbench
    
    # Graphics testing
    glxinfo
    vulkan-tools
    wayland-utils
    
    # Network testing
    wget
    curl
    iperf3
    
    # Development tools
    git
    vim
    tmux
    
    # Testing utilities
    xdotool
    imagemagick
    ffmpeg
    
    # System information
    neofetch
    inxi
    lshw
    
    # Benchmarking
    hyperfine
    time
  ];

  # Enable necessary services for testing
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    
    # X11 forwarding for remote testing
    xserver.enable = true;
  };

  # Kernel parameters for VM optimization
  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
    "vm.vfs_cache_pressure" = 50;
  };

  # Enable flakes for testing
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  # System configuration
  system.stateVersion = "24.05";
  
  # Networking
  networking = {
    hostName = "dots-hyprland-test";
    firewall.enable = false; # Disable for testing
  };

  # Boot configuration
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  # File systems
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
}
