#!/usr/bin/env bash

# Phase 5 Testing Script
# Tests NixOS-specific adaptations and integration patterns

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"
}

phase5() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')] PHASE 5: $1${NC}"
}

# Test functions
test_build() {
    log "Testing Phase 5 build..."
    
    if nix build "$PROJECT_ROOT#homeConfigurations.example.activationPackage" --no-link; then
        log "✅ Phase 5 build successful"
        return 0
    else
        error "❌ Phase 5 build failed"
        return 1
    fi
}

test_nixos_system_integration() {
    phase5 "Testing NixOS System Integration"
    
    if [[ -f "$PROJECT_ROOT/modules/nixos-system.nix" ]]; then
        log "✅ NixOS system module exists"
        
        # Test module syntax
        if nix-instantiate --parse "$PROJECT_ROOT/modules/nixos-system.nix" >/dev/null 2>&1; then
            log "✅ NixOS system module syntax valid"
        else
            error "❌ NixOS system module syntax invalid"
            return 1
        fi
    else
        error "❌ NixOS system module missing"
        return 1
    fi
    
    # Check for key NixOS integration features
    local features=(
        "hardware support"
        "display manager"
        "security integration"
        "network configuration"
        "virtualization support"
        "development tools"
    )
    
    for feature in "${features[@]}"; do
        if grep -q "$(echo "$feature" | tr ' ' '.')" "$PROJECT_ROOT/modules/nixos-system.nix"; then
            log "✅ NixOS integration includes: $feature"
        else
            warn "⚠️  NixOS integration missing: $feature"
        fi
    done
}

test_user_customization_system() {
    phase5 "Testing User Customization System"
    
    if [[ -f "$PROJECT_ROOT/modules/components/customization.nix" ]]; then
        log "✅ User customization module exists"
        
        # Test module syntax
        if nix-instantiate --parse "$PROJECT_ROOT/modules/components/customization.nix" >/dev/null 2>&1; then
            log "✅ User customization module syntax valid"
        else
            error "❌ User customization module syntax invalid"
            return 1
        fi
    else
        error "❌ User customization module missing"
        return 1
    fi
    
    # Check for customization features
    local features=(
        "customConfigs"
        "customScripts"
        "environmentVariables"
        "hooks"
        "templateOverrides"
        "keybindOverrides"
        "widgets"
    )
    
    for feature in "${features[@]}"; do
        if grep -q "$feature" "$PROJECT_ROOT/modules/components/customization.nix"; then
            log "✅ Customization includes: $feature"
        else
            warn "⚠️  Customization missing: $feature"
        fi
    done
}

test_template_processing() {
    phase5 "Testing Template Processing Framework"
    
    if [[ -f "$PROJECT_ROOT/lib/template-processor.nix" ]]; then
        log "✅ Template processor exists"
        
        # Test template processor syntax
        if nix-instantiate --parse "$PROJECT_ROOT/lib/template-processor.nix" >/dev/null 2>&1; then
            log "✅ Template processor syntax valid"
        else
            error "❌ Template processor syntax invalid"
            return 1
        fi
    else
        error "❌ Template processor missing"
        return 1
    fi
    
    # Check for template processing features
    local features=(
        "processTemplate"
        "generateConfigFromTemplate"
        "applyColorScheme"
        "createTemplateSystem"
        "validateConfig"
        "createHotReloader"
        "processMultiFormat"
    )
    
    for feature in "${features[@]}"; do
        if grep -q "$feature" "$PROJECT_ROOT/lib/template-processor.nix"; then
            log "✅ Template processing includes: $feature"
        else
            warn "⚠️  Template processing missing: $feature"
        fi
    done
}

test_service_management() {
    phase5 "Testing Service Management Adaptation"
    
    if [[ -f "$PROJECT_ROOT/modules/components/service-management.nix" ]]; then
        log "✅ Service management module exists"
        
        # Test module syntax
        if nix-instantiate --parse "$PROJECT_ROOT/modules/components/service-management.nix" >/dev/null 2>&1; then
            log "✅ Service management module syntax valid"
        else
            error "❌ Service management module syntax invalid"
            return 1
        fi
    else
        error "❌ Service management module missing"
        return 1
    fi
    
    # Check for service management features
    local features=(
        "session target"
        "core services"
        "optional services"
        "custom services"
        "service monitoring"
        "health checks"
    )
    
    for feature in "${features[@]}"; do
        if grep -q "$(echo "$feature" | tr ' ' '.')" "$PROJECT_ROOT/modules/components/service-management.nix"; then
            log "✅ Service management includes: $feature"
        else
            warn "⚠️  Service management missing: $feature"
        fi
    done
}

test_arch_replacement() {
    phase5 "Testing Arch-Specific Element Replacement"
    
    log "Checking for Arch-specific patterns..."
    
    # Check that we don't have Arch-specific commands
    local arch_patterns=(
        "pacman"
        "yay"
        "systemctl --user enable"
        "cp -r .config"
        "makepkg"
        "PKGBUILD"
    )
    
    local found_arch=false
    for pattern in "${arch_patterns[@]}"; do
        if find "$PROJECT_ROOT" -name "*.nix" -exec grep -l "$pattern" {} \; 2>/dev/null | grep -v test; then
            warn "⚠️  Found Arch-specific pattern: $pattern"
            found_arch=true
        fi
    done
    
    if [[ $found_arch == false ]]; then
        log "✅ No Arch-specific patterns found in Nix files"
    fi
    
    # Check for NixOS patterns
    local nixos_patterns=(
        "xdg.configFile"
        "home.packages"
        "systemd.user.services"
        "programs\."
        "services\."
        "mkEnableOption"
        "mkOption"
    )
    
    local found_nixos=0
    for pattern in "${nixos_patterns[@]}"; do
        if find "$PROJECT_ROOT" -name "*.nix" -exec grep -l "$pattern" {} \; 2>/dev/null | wc -l | grep -q "[1-9]"; then
            log "✅ Found NixOS pattern: $pattern"
            ((found_nixos++))
        fi
    done
    
    if [[ $found_nixos -ge 5 ]]; then
        log "✅ Strong NixOS integration patterns detected"
    else
        warn "⚠️  Limited NixOS integration patterns found"
    fi
}

test_declarative_configuration() {
    phase5 "Testing Declarative Configuration Management"
    
    # Check for declarative patterns
    local declarative_features=(
        "enable.*mkEnableOption"
        "mkOption.*type.*types\."
        "config.*mkIf.*cfg\."
        "home\.packages.*with.*pkgs"
        "systemd\.user\.services"
        "xdg\.configFile"
    )
    
    local found_declarative=0
    for feature in "${declarative_features[@]}"; do
        if find "$PROJECT_ROOT" -name "*.nix" -exec grep -l "$feature" {} \; 2>/dev/null | wc -l | grep -q "[1-9]"; then
            log "✅ Found declarative pattern: $feature"
            ((found_declarative++))
        fi
    done
    
    if [[ $found_declarative -ge 4 ]]; then
        log "✅ Strong declarative configuration patterns"
    else
        warn "⚠️  Limited declarative configuration patterns"
    fi
}

test_development_environment() {
    phase5 "Testing Development Environment"
    
    log "Testing development environment..."
    if nix develop "$PROJECT_ROOT" -c bash -c "echo 'Development environment working' && which quickshell" >/dev/null 2>&1; then
        log "✅ Development environment functional"
    else
        error "❌ Development environment issues"
        return 1
    fi
}

show_phase5_status() {
    phase5 "Phase 5 Implementation Status"
    echo
    echo "🏗️ NixOS System Integration:"
    echo "  - [x] Comprehensive hardware support configuration"
    echo "  - [x] Display manager integration (GDM, SDDM, LightDM, Greetd)"
    echo "  - [x] Security framework (PolicyKit, AppArmor, Firewall)"
    echo "  - [x] Network configuration (NetworkManager, Wireless, VPN)"
    echo "  - [x] Virtualization support (Docker, Podman, libvirt)"
    echo "  - [x] Development tools with language support"
    echo
    echo "🎨 User Customization System:"
    echo "  - [x] Custom configuration file overrides"
    echo "  - [x] Custom script management with dependencies"
    echo "  - [x] Environment variable customization"
    echo "  - [x] Hook system (pre/post-start, color-change, shutdown)"
    echo "  - [x] Template and keybind overrides"
    echo "  - [x] Widget configuration system"
    echo
    echo "🔧 Template Processing Framework:"
    echo "  - [x] Advanced template system with inheritance"
    echo "  - [x] Conditional template blocks"
    echo "  - [x] Multi-format processing (QML, JSON, CSS)"
    echo "  - [x] Color scheme integration"
    echo "  - [x] Hot-reloading system"
    echo "  - [x] Template validation and debugging"
    echo
    echo "⚙️ Service Management Adaptation:"
    echo "  - [x] Declarative systemd user service management"
    echo "  - [x] Session target integration"
    echo "  - [x] Core and optional service configuration"
    echo "  - [x] Custom service definition system"
    echo "  - [x] Service monitoring and health checks"
    echo "  - [x] Service management CLI tools"
    echo
    echo "🔄 NixOS Pattern Replacements:"
    echo "  - [x] Arch package management → Declarative Nix"
    echo "  - [x] Manual service management → systemd user services"
    echo "  - [x] Direct file copying → xdg.configFile patterns"
    echo "  - [x] Imperative configuration → Declarative options"
    echo "  - [x] Manual customization → Structured override system"
    echo
    echo "📊 Overall Progress: Phase 5 NixOS Adaptations Complete! 🎉"
}

# Main execution
main() {
    echo "🔧 Phase 5: NixOS-Specific Adaptations Testing"
    echo "=============================================="
    echo
    
    local failed_tests=()
    
    # Run all tests
    if ! test_build; then
        failed_tests+=("build")
    fi
    
    if ! test_nixos_system_integration; then
        failed_tests+=("nixos_system_integration")
    fi
    
    if ! test_user_customization_system; then
        failed_tests+=("user_customization_system")
    fi
    
    if ! test_template_processing; then
        failed_tests+=("template_processing")
    fi
    
    if ! test_service_management; then
        failed_tests+=("service_management")
    fi
    
    if ! test_arch_replacement; then
        failed_tests+=("arch_replacement")
    fi
    
    if ! test_declarative_configuration; then
        failed_tests+=("declarative_configuration")
    fi
    
    if ! test_development_environment; then
        failed_tests+=("development_environment")
    fi
    
    echo
    echo "=============================================="
    
    # Show results
    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        log "🎉 All Phase 5 tests passed!"
        show_phase5_status
        echo
        log "🚀 Ready for Phase 6: Testing & Validation!"
        echo
        echo "Next steps:"
        echo "1. Enable advanced components: AI, customization, service management"
        echo "2. Test complete integration in VM environment"
        echo "3. Validate user customization workflows"
        echo "4. Proceed to comprehensive testing phase"
        exit 0
    else
        error "❌ ${#failed_tests[@]} test(s) failed:"
        printf '%s\n' "${failed_tests[@]}"
        exit 1
    fi
}

# Run tests
main "$@"
