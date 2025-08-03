{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dots-hyprland.ai;
  mainCfg = config.programs.dots-hyprland;
in
{
  options.programs.dots-hyprland.ai = {
    enable = mkEnableOption "AI integration for dots-hyprland";

    providers = {
      gemini = {
        enable = mkEnableOption "Google Gemini AI";
        apiKeyFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to file containing Gemini API key";
          example = "/run/secrets/gemini-api-key";
        };
        model = mkOption {
          type = types.str;
          default = "gemini-pro";
          description = "Gemini model to use";
        };
      };

      ollama = {
        enable = mkEnableOption "Ollama local AI";
        endpoint = mkOption {
          type = types.str;
          default = "http://localhost:11434";
          description = "Ollama API endpoint";
        };
        models = mkOption {
          type = types.listOf types.str;
          default = [ "llama2" "codellama" ];
          description = "Available Ollama models";
        };
        autoStart = mkEnableOption "Auto-start Ollama service" // { default = true; };
      };
    };

    features = {
      chat = mkEnableOption "AI chat interface" // { default = true; };
      codeGeneration = mkEnableOption "Code generation assistance";
      imageAnalysis = mkEnableOption "Image analysis capabilities";
      translation = mkEnableOption "Text translation";
    };

    ui = {
      sidebarIntegration = mkEnableOption "Integrate AI in sidebar" // { default = true; };
      floatingWindow = mkEnableOption "Floating AI chat window";
      keybind = mkOption {
        type = types.str;
        default = "SUPER_SHIFT_A";
        description = "Keybind to open AI interface";
      };
    };
  };

  config = mkIf cfg.enable {
    # Ollama service
    systemd.user.services.ollama = mkIf (cfg.providers.ollama.enable && cfg.providers.ollama.autoStart) {
      Unit = {
        Description = "Ollama local AI service";
        After = [ "network.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.ollama}/bin/ollama serve";
        Environment = [
          "OLLAMA_HOST=127.0.0.1:11434"
          "OLLAMA_MODELS=${config.xdg.dataHome}/ollama/models"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # AI configuration for Quickshell
    home.file.".config/quickshell/ii/defaults/ai/config.json".text = builtins.toJSON {
      providers = {
        gemini = {
          enabled = cfg.providers.gemini.enable;
          model = cfg.providers.gemini.model;
          apiKeyFile = cfg.providers.gemini.apiKeyFile;
        };
        ollama = {
          enabled = cfg.providers.ollama.enable;
          endpoint = cfg.providers.ollama.endpoint;
          models = cfg.providers.ollama.models;
        };
      };
      features = cfg.features;
      ui = cfg.ui;
    };

    # Required packages
    home.packages = with pkgs; [
      curl # For API calls
      jq   # For JSON processing
    ] ++ optionals cfg.providers.ollama.enable [
      ollama
    ];

    # Hyprland keybind for AI
    programs.dots-hyprland.hyprland.customKeybinds = mkIf (cfg.ui.keybind != null) ''
      bind = ${cfg.ui.keybind}, exec, ai-chat
    '';

    # AI helper scripts
    home.file."${mainCfg.dataDir}/bin/ai-chat" = {
      text = ''
        #!/usr/bin/env bash
        
        CONFIG_FILE="$HOME/.config/quickshell/ii/defaults/ai/config.json"
        
        if [[ ! -f "$CONFIG_FILE" ]]; then
          echo "AI configuration not found"
          exit 1
        fi
        
        # Read configuration
        GEMINI_ENABLED=$(${pkgs.jq}/bin/jq -r '.providers.gemini.enabled // false' "$CONFIG_FILE")
        OLLAMA_ENABLED=$(${pkgs.jq}/bin/jq -r '.providers.ollama.enabled // false' "$CONFIG_FILE")
        
        if [[ "$GEMINI_ENABLED" == "true" ]]; then
          API_KEY_FILE=$(${pkgs.jq}/bin/jq -r '.providers.gemini.apiKeyFile' "$CONFIG_FILE")
          if [[ -f "$API_KEY_FILE" ]]; then
            export GEMINI_API_KEY=$(cat "$API_KEY_FILE")
          fi
        fi
        
        # Launch AI interface
        ${pkgs.quickshell}/bin/quickshell -c ai-interface
      '';
      executable = true;
    };

    home.file."${mainCfg.dataDir}/bin/ollama-health" = {
      text = ''
        #!/usr/bin/env bash
        
        ENDPOINT="''${1:-http://localhost:11434}"
        
        ${pkgs.curl}/bin/curl -s "$ENDPOINT/api/tags" > /dev/null
        echo $?
      '';
      executable = true;
    };
  };
}
