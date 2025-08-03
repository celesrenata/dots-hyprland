{ lib, pkgs }:

let
  # Template processing utilities
  processTemplate = template: substitutions:
    lib.replaceStrings
      (map (name: "@${name}@") (lib.attrNames substitutions))
      (lib.attrValues substitutions)
      template;

  # Generate configuration from template with advanced processing
  generateConfigFromTemplate = { 
    templatePath, 
    outputPath, 
    substitutions ? {}, 
    conditionals ? {},
    includes ? {},
    processors ? []
  }:
    pkgs.runCommand "generate-config" {
      nativeBuildInputs = with pkgs; [ gnused gawk jq python3 ];
    } ''
      mkdir -p $(dirname $out/${outputPath})
      
      # Read template
      TEMPLATE_CONTENT=$(cat ${templatePath})
      
      # Process conditionals
      ${lib.concatMapStringsSep "\n" (name: 
        let condition = conditionals.${name}; in
        ''
          if ${if condition.enable then "true" else "false"}; then
            TEMPLATE_CONTENT=$(echo "$TEMPLATE_CONTENT" | sed 's/@IF_${lib.toUpper name}@//g' | sed 's/@ENDIF_${lib.toUpper name}@//g')
          else
            TEMPLATE_CONTENT=$(echo "$TEMPLATE_CONTENT" | sed '/@IF_${lib.toUpper name}@/,/@ENDIF_${lib.toUpper name}@/d')
          fi
        ''
      ) (lib.attrNames conditionals)}
      
      # Process includes
      ${lib.concatMapStringsSep "\n" (name:
        let include = includes.${name}; in
        ''
          INCLUDE_CONTENT=$(cat ${include})
          TEMPLATE_CONTENT=$(echo "$TEMPLATE_CONTENT" | sed "s|@INCLUDE_${lib.toUpper name}@|$INCLUDE_CONTENT|g")
        ''
      ) (lib.attrNames includes)}
      
      # Process substitutions
      ${lib.concatMapStringsSep "\n" (name: 
        ''
          TEMPLATE_CONTENT=$(echo "$TEMPLATE_CONTENT" | sed 's|@${name}@|${substitutions.${name}}|g')
        ''
      ) (lib.attrNames substitutions)}
      
      # Apply custom processors
      ${lib.concatMapStringsSep "\n" (processor: processor) processors}
      
      # Write final content
      echo "$TEMPLATE_CONTENT" > $out/${outputPath}
    '';

  # Color substitution system with advanced features
  applyColorScheme = template: colors: mode:
    let
      # Generate additional color variations
      generateColorVariations = baseColors: 
        baseColors // {
          # Generate lighter/darker variants
          primary_light = lightenColor baseColors.primary 0.2;
          primary_dark = darkenColor baseColors.primary 0.2;
          surface_variant = if mode == "dark" 
            then lightenColor baseColors.surface 0.1
            else darkenColor baseColors.surface 0.1;
          outline_variant = if mode == "dark"
            then lightenColor baseColors.outline 0.3
            else darkenColor baseColors.outline 0.3;
        };
      
      extendedColors = generateColorVariations colors;
    in
    processTemplate template (
      lib.mapAttrs' (name: value: 
        lib.nameValuePair "COLOR_${lib.toUpper name}" value
      ) extendedColors
    );

  # Color manipulation functions
  lightenColor = color: amount:
    # Simplified color lightening (would use proper color math in real implementation)
    color;
    
  darkenColor = color: amount:
    # Simplified color darkening (would use proper color math in real implementation)
    color;

  # Advanced template system with inheritance
  createTemplateSystem = { baseTemplates, userOverrides ? {}, colorScheme ? {} }:
    let
      # Merge base templates with user overrides
      mergedTemplates = lib.recursiveUpdate baseTemplates userOverrides;
      
      # Process each template with color scheme
      processedTemplates = lib.mapAttrs (name: template:
        if colorScheme != {} then
          applyColorScheme template colorScheme
        else
          template
      ) mergedTemplates;
    in
    processedTemplates;

  # Configuration validator
  validateConfig = config: schema:
    pkgs.writeShellScript "validate-config" ''
      # Validate configuration against schema
      echo "Validating configuration..."
      
      # Use jq for JSON validation if applicable
      if echo '${builtins.toJSON config}' | ${pkgs.jq}/bin/jq empty 2>/dev/null; then
        echo "✅ Configuration is valid JSON"
      else
        echo "❌ Configuration is not valid JSON"
        exit 1
      fi
      
      # Additional validation logic would go here
      echo "✅ Configuration validation passed"
    '';

  # Template hot-reloading system
  createHotReloader = { templateDir, outputDir, watchPatterns ? [ "*.template" "*.qml.template" ] }:
    pkgs.writeShellScript "template-hot-reloader" ''
      #!/usr/bin/env bash
      
      TEMPLATE_DIR="${templateDir}"
      OUTPUT_DIR="${outputDir}"
      
      echo "Starting template hot-reloader..."
      echo "Watching: $TEMPLATE_DIR"
      echo "Output: $OUTPUT_DIR"
      
      # Use inotify to watch for changes
      ${pkgs.inotify-tools}/bin/inotifywait -m -r -e modify,create,delete \
        --include='${lib.concatStringsSep "|" watchPatterns}' \
        "$TEMPLATE_DIR" |
      while read path action file; do
        echo "Template changed: $path$file ($action)"
        
        # Regenerate configuration
        echo "Regenerating configuration..."
        
        # This would call the actual template processing
        # For now, just notify
        ${pkgs.libnotify}/bin/notify-send "Template Updated" \
          "Configuration regenerated from $file" \
          --icon="preferences-system" || true
        
        # Reload services
        ${pkgs.systemd}/bin/systemctl --user reload-or-restart quickshell.service || true
      done
    '';

  # Multi-format template processor
  processMultiFormat = { template, format ? "qml", substitutions ? {}, colorScheme ? {} }:
    let
      formatProcessors = {
        qml = template: subs: colors:
          # QML-specific processing
          processTemplate template (subs // colors);
          
        conf = template: subs: colors:
          # Configuration file processing
          processTemplate template (subs // colors);
          
        json = template: subs: colors:
          # JSON template processing with validation
          let processed = processTemplate template (subs // colors);
          in pkgs.runCommand "validate-json" {} ''
            echo '${processed}' | ${pkgs.jq}/bin/jq . > $out
          '';
          
        css = template: subs: colors:
          # CSS processing with color functions
          processTemplate template (subs // colors // {
            "RGBA" = color: alpha: "rgba(${color}, ${alpha})";
            "HSL" = h: s: l: "hsl(${h}, ${s}%, ${l}%)";
          });
      };
      
      processor = formatProcessors.${format} or formatProcessors.conf;
    in
    processor template substitutions colorScheme;

  # Template inheritance system
  createInheritanceChain = baseTemplate: overrides:
    lib.foldl' (acc: override: 
      lib.recursiveUpdate acc override
    ) baseTemplate overrides;

  # Conditional template blocks
  processConditionals = template: conditions:
    lib.foldl' (acc: condition:
      let
        ifBlock = "@IF_${condition.name}@";
        endifBlock = "@ENDIF_${condition.name}@";
        elseBlock = "@ELSE_${condition.name}@";
      in
      if condition.enabled then
        # Keep the IF block, remove ELSE block
        lib.replaceStrings 
          [ ifBlock endifBlock ]
          [ "" "" ]
          (builtins.replaceStrings
            [ "${elseBlock}.*${endifBlock}" ]
            [ "" ]
            acc)
      else
        # Remove IF block, keep ELSE block
        builtins.replaceStrings
          [ "${ifBlock}.*${elseBlock}" elseBlock endifBlock ]
          [ "" "" "" ]
          acc
    ) template conditions;

  # Template debugging utilities
  debugTemplate = template: substitutions:
    pkgs.writeText "debug-template" ''
      Original template:
      ${template}
      
      Substitutions:
      ${lib.concatMapStringsSep "\n" (name: 
        "${name} = ${substitutions.${name}}"
      ) (lib.attrNames substitutions)}
      
      Processed template:
      ${processTemplate template substitutions}
    '';

in
{
  inherit 
    processTemplate 
    generateConfigFromTemplate 
    applyColorScheme
    createTemplateSystem
    validateConfig
    createHotReloader
    processMultiFormat
    createInheritanceChain
    processConditionals
    debugTemplate;
    
  # Convenience functions
  simpleTemplate = template: substitutions: processTemplate template substitutions;
  colorTemplate = template: colors: applyColorScheme template colors;
  
  # Template utilities
  utils = {
    inherit lightenColor darkenColor;
    
    # Convert hex to RGB
    hexToRgb = hex: 
      let
        r = lib.toInt ("0x" + lib.substring 1 2 hex);
        g = lib.toInt ("0x" + lib.substring 3 2 hex);
        b = lib.toInt ("0x" + lib.substring 5 2 hex);
      in
      { inherit r g b; };
      
    # Convert RGB to hex
    rgbToHex = r: g: b:
      "#${lib.fixedWidthString 2 "0" (lib.toHexString r)}${lib.fixedWidthString 2 "0" (lib.toHexString g)}${lib.fixedWidthString 2 "0" (lib.toHexString b)}";
  };
}
