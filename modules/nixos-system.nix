{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dots-hyprland;
in
{
  options.services.dots-hyprland = {
    enable = mkEnableOption "dots-hyprland system integration";

    # Hardware support configuration
    hardware = {
      nvidia = mkEnableOption "NVIDIA GPU support";
      amd = mkEnableOption "AMD GPU support";
      intel = mkEnableOption "Intel GPU support" // { default = true; };
      bluetooth = mkEnableOption "Bluetooth support" // { default = true; };
      audio = mkEnableOption "Audio support" // { default = true; };
      printing = mkEnableOption "Printing support";
      scanner = mkEnableOption "Scanner support";
    };

    # Display manager configuration
    displayManager = mkOption {
      type = types.enum [ "gdm" "sddm" "lightdm" "greetd" ];
      default = "gdm";
      description = "Display manager to use";
    };

    # Security configuration
    security = {
      polkit = mkEnableOption "PolicyKit support" // { default = true; };
      keyring = mkEnableOption "GNOME Keyring support" // { default = true; };
      firewall = mkEnableOption "Firewall configuration" // { default = true; };
      apparmor = mkEnableOption "AppArmor security profiles";
    };

    # Network configuration
    networking = {
      networkmanager = mkEnableOption "NetworkManager support" // { default = true; };
      wireless = mkEnableOption "Wireless support" // { default = true; };
      vpn = mkEnableOption "VPN support";
    };

    # Virtualization support
    virtualization = {
      docker = mkEnableOption "Docker support";
      podman = mkEnableOption "Podman support";
      libvirt = mkEnableOption "libvirt/QEMU support";
    };

    # Development tools
    development = {
      enable = mkEnableOption "Development tools";
      languages = mkOption {
        type = types.listOf (types.enum [ "python" "nodejs" "rust" "go" "java" "cpp" ]);
        default = [ "python" "nodejs" ];
        description = "Programming languages to support";
      };
    };
  };

  config = mkIf cfg.enable {
    # Display manager configuration
    services.xserver = {
      enable = true;
      displayManager = {
        gdm = mkIf (cfg.displayManager == "gdm") {
          enable = true;
          wayland = true;
        };
        sddm = mkIf (cfg.displayManager == "sddm") {
          enable = true;
          wayland.enable = true;
        };
        lightdm = mkIf (cfg.displayManager == "lightdm") {
          enable = true;
        };
      };
    };

    # Greetd configuration (modern alternative)
    services.greetd = mkIf (cfg.displayManager == "greetd") {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    # Hyprland configuration
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Audio system - PipeWire (modern replacement for PulseAudio)
    security.rtkit.enable = mkIf cfg.hardware.audio true;
    services.pipewire = mkIf cfg.hardware.audio {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      
      # Low latency configuration
      extraConfig.pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 32;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 32;
        };
      };
    };

    # Bluetooth support
    hardware.bluetooth = mkIf cfg.hardware.bluetooth {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
    services.blueman.enable = mkIf cfg.hardware.bluetooth true;

    # Network configuration
    networking.networkmanager = mkIf cfg.networking.networkmanager {
      enable = true;
      wifi.powersave = false;
    };

    networking.wireless = mkIf (cfg.networking.wireless && !cfg.networking.networkmanager) {
      enable = true;
    };

    # VPN support
    services.openvpn.servers = mkIf cfg.networking.vpn {};
    
    # GPU support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      
      extraPackages = with pkgs; [
        intel-media-driver # For Intel GPUs
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ] ++ optionals cfg.hardware.amd [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
    };

    # NVIDIA specific configuration
    services.xserver.videoDrivers = mkIf cfg.hardware.nvidia [ "nvidia" ];
    hardware.nvidia = mkIf cfg.hardware.nvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # Security configuration
    security.polkit.enable = mkIf cfg.security.polkit true;
    services.gnome.gnome-keyring.enable = mkIf cfg.security.keyring true;
    
    # Firewall
    networking.firewall = mkIf cfg.security.firewall {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };

    # AppArmor
    security.apparmor = mkIf cfg.security.apparmor {
      enable = true;
      killUnconfinedConfinables = true;
    };

    # XDG Portal configuration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    # Fonts - comprehensive font support
    fonts = {
      packages = with pkgs; [
        # Base fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        
        # Programming fonts
        (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" "SourceCodePro" ]; })
        
        # System fonts
        dejavu_fonts
        liberation_ttf
        
        # Icon fonts
        font-awesome
        material-design-icons
        
        # Additional fonts
        inter
        roboto
        ubuntu_font_family
      ];
      
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" "DejaVu Serif" ];
          sansSerif = [ "Inter" "Noto Sans" "DejaVu Sans" ];
          monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" "DejaVu Sans Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    # Printing support
    services.printing = mkIf cfg.hardware.printing {
      enable = true;
      drivers = with pkgs; [ hplip epson-escpr ];
    };
    services.avahi = mkIf cfg.hardware.printing {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Scanner support
    hardware.sane = mkIf cfg.hardware.scanner {
      enable = true;
      extraBackends = with pkgs; [ hplipWithPlugin ];
    };

    # Virtualization
    virtualisation.docker = mkIf cfg.virtualization.docker {
      enable = true;
      enableOnBoot = true;
    };
    
    virtualisation.podman = mkIf cfg.virtualization.podman {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    virtualisation.libvirtd = mkIf cfg.virtualization.libvirt {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
    };

    # Development tools
    environment.systemPackages = with pkgs; mkIf cfg.development.enable ([
      # Version control
      git
      git-lfs
      
      # Build tools
      gnumake
      cmake
      pkg-config
      
      # Text editors
      vim
      nano
      
      # System tools
      htop
      tree
      wget
      curl
      unzip
      zip
    ] ++ optionals (elem "python" cfg.development.languages) [
      python3
      python3Packages.pip
      python3Packages.virtualenv
    ] ++ optionals (elem "nodejs" cfg.development.languages) [
      nodejs
      npm
      yarn
    ] ++ optionals (elem "rust" cfg.development.languages) [
      rustc
      cargo
      rustfmt
      clippy
    ] ++ optionals (elem "go" cfg.development.languages) [
      go
      gopls
    ] ++ optionals (elem "java" cfg.development.languages) [
      openjdk
      maven
      gradle
    ] ++ optionals (elem "cpp" cfg.development.languages) [
      gcc
      clang
      gdb
      valgrind
    ]);

    # System services
    services.dbus.enable = true;
    services.udev.enable = true;
    services.udisks2.enable = true;
    services.power-profiles-daemon.enable = true;
    
    # Firmware updates
    services.fwupd.enable = true;
    
    # Locate database
    services.locate = {
      enable = true;
      package = pkgs.mlocate;
      localuser = null;
    };

    # Zram swap
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    # Kernel parameters for better desktop performance
    boot.kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 15;
      "vm.dirty_background_ratio" = 5;
    };

    # User groups for hardware access
    users.groups = {
      plugdev = {};
      dialout = {};
    };

    # Udev rules for hardware access
    services.udev.extraRules = ''
      # Allow users in plugdev group to access USB devices
      SUBSYSTEM=="usb", MODE="0664", GROUP="plugdev"
      
      # Allow users in dialout group to access serial devices
      KERNEL=="ttyUSB[0-9]*", MODE="0664", GROUP="dialout"
      KERNEL=="ttyACM[0-9]*", MODE="0664", GROUP="dialout"
    '';

    # Environment variables
    environment.sessionVariables = {
      # Wayland
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      
      # XDG
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };

    # System-wide configuration
    system.stateVersion = "24.05";
    
    # Nix configuration
    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  };
}
