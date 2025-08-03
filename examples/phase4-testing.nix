# Phase 4 Testing Configuration
# This configuration enables all Phase 4 advanced features for testing

{
  programs.dots-hyprland = {
    enable = true;
    style = "illogical-impulse";
    
    # Phase 4: All Advanced Features Enabled
    components = {
      hyprland = true;
      quickshell = true;
      theming = true;  # Material You theming
      ai = true;       # AI integration
      audio = true;
      development = true;
    };
    
    # Phase 4: Advanced Features
    features = {
      overview = true;           # Advanced overview with previews
      sidebar = true;            # AI-powered sidebars
      notifications = true;
      mediaControls = true;
      screenCorners = true;      # Screen corner interactions
      onScreenKeyboard = true;   # Virtual keyboard
      cheatsheet = true;         # Interactive keybind reference
    };
    
    # AI Configuration
    ai = {
      providers = {
        ollama = {
          enable = true;
          models = [ "llama2" "codellama" "mistral" ];
          autoStart = true;
        };
        gemini = {
          enable = false;  # Requires API key
          # apiKeyFile = "/path/to/gemini-key";
        };
      };
      
      features = {
        chat = true;
        codeGeneration = true;
        imageAnalysis = false;  # Requires Gemini
        translation = true;
      };
      
      ui = {
        sidebarIntegration = true;
        floatingWindow = true;
        keybind = "SUPER_SHIFT_A";
      };
    };
    
    # Theming Configuration
    theming = {
      wallpaper = null;  # Will use default
      colorScheme = "dark";
      accentColor = "#bb9af7";  # Material purple
    };
    
    # Keybinds
    keybinds = {
      modifier = "SUPER";
      terminal = "foot";
    };
  };
}
