# Phase 6: Testing & Validation

## Overview
This phase establishes comprehensive testing and validation procedures to ensure the NixOS adaptation of dots-hyprland works reliably across different configurations, hardware setups, and use cases. Based on the complexity observed in the original repo, we need robust testing to catch integration issues early.

## Testing Strategy Framework

### 1. Multi-Level Testing Approach

#### Unit Testing (Component Level)
- **Individual packages** - Each custom derivation builds correctly
- **Module options** - Configuration options validate properly  
- **Template generation** - Configuration templates render correctly
- **Service definitions** - Systemd services start/stop properly

#### Integration Testing (System Level)
- **Complete desktop environment** - All components work together
- **Hardware compatibility** - Different GPU/audio/input configurations
- **User scenarios** - Common usage patterns function correctly
- **Performance benchmarks** - Resource usage within acceptable limits

#### End-to-End Testing (User Experience)
- **Installation process** - From fresh NixOS to working desktop
- **Customization workflows** - User modifications work as expected
- **Update procedures** - System updates don't break functionality
- **Recovery scenarios** - Graceful handling of failures

### 2. Test Environment Setup

#### VM-Based Testing Infrastructure
```nix
# testing/vm-configs/basic-test.nix
{ config, lib, pkgs, ... }:

{
  imports = [ ../modules/nixos.nix ];

  # VM-specific configuration
  virtualisation = {
    memorySize = 4096;
    cores = 4;
    qemu.options = [
      "-vga virtio"
      "-display gtk,gl=on"
    ];
  };

  # Enable dots-hyprland
  services.dots-hyprland = {
    enable = true;
    hardware = {
      nvidia = false;
      amd = false;
      intel = true;
    };
  };

  # Test user
  users.users.testuser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" ];
    password = "test";
  };

  # Home Manager configuration for test user
  home-manager.users.testuser = {
    imports = [ ../modules/home-manager.nix ];
    
    programs.dots-hyprland = {
      enable = true;
      style = "illogical-impulse";
      
      components = {
        hyprland = true;
        quickshell = true;
        theming = true;
        ai = false; # Disable for basic testing
      };
      
      features = {
        overview = true;
        sidebar = true;
        notifications = true;
        mediaControls = true;
      };
    };
  };

  # Testing utilities
  environment.systemPackages = with pkgs; [
    htop
    neofetch
    glxinfo
    wayland-utils
  ];
}
```

#### Hardware-Specific Test Configurations
```nix
# testing/vm-configs/nvidia-test.nix
{ config, lib, pkgs, ... }:

{
  imports = [ ./basic-test.nix ];

  # Override for NVIDIA testing
  services.dots-hyprland.hardware = {
    nvidia = true;
    intel = false;
  };

  # NVIDIA-specific VM setup
  virtualisation.qemu.options = [
    "-vga none"
    "-device vfio-pci,host=01:00.0" # Pass through GPU if available
  ];
}
```

### 3. Automated Testing Framework

#### Test Runner Script
```bash
#!/usr/bin/env bash
# testing/run-tests.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Test configurations
TEST_CONFIGS=(
    "basic-test"
    "nvidia-test"
    "amd-test"
    "minimal-test"
    "full-features-test"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Build test
build_test() {
    local config=$1
    log "Building test configuration: $config"
    
    if nix build "$PROJECT_ROOT#nixosConfigurations.$config.config.system.build.vm" --no-link; then
        log "✓ Build successful: $config"
        return 0
    else
        error "✗ Build failed: $config"
        return 1
    fi
}

# VM test
vm_test() {
    local config=$1
    local timeout=${2:-300} # 5 minutes default
    
    log "Starting VM test: $config"
    
    # Build VM
    local vm_path
    vm_path=$(nix build "$PROJECT_ROOT#nixosConfigurations.$config.config.system.build.vm" --no-link --print-out-paths)
    
    # Start VM in background
    timeout "$timeout" "$vm_path/bin/run-$config-vm" &
    local vm_pid=$!
    
    # Wait for VM to boot and test basic functionality
    sleep 60
    
    # Check if VM is still running
    if kill -0 "$vm_pid" 2>/dev/null; then
        log "✓ VM test successful: $config"
        kill "$vm_pid" 2>/dev/null || true
        return 0
    else
        error "✗ VM test failed: $config"
        return 1
    fi
}

# Package test
package_test() {
    log "Testing custom packages"
    
    local packages=(
        "quickshell"
        "material-color-utilities"
        "dots-hyprland-scripts"
    )
    
    for package in "${packages[@]}"; do
        if nix build "$PROJECT_ROOT#packages.x86_64-linux.$package" --no-link; then
            log "✓ Package build successful: $package"
        else
            error "✗ Package build failed: $package"
            return 1
        fi
    done
}

# Home Manager test
home_manager_test() {
    log "Testing Home Manager configuration"
    
    if nix build "$PROJECT_ROOT#homeConfigurations.example.activationPackage" --no-link; then
        log "✓ Home Manager build successful"
        return 0
    else
        error "✗ Home Manager build failed"
        return 1
    fi
}

# Main test runner
main() {
    log "Starting dots-hyprland test suite"
    
    local failed_tests=()
    
    # Package tests
    if ! package_test; then
        failed_tests+=("package_test")
    fi
    
    # Home Manager tests
    if ! home_manager_test; then
        failed_tests+=("home_manager_test")
    fi
    
    # Build tests
    for config in "${TEST_CONFIGS[@]}"; do
        if ! build_test "$config"; then
            failed_tests+=("build_test_$config")
        fi
    done
    
    # VM tests (if requested)
    if [[ "${1:-}" == "--vm-tests" ]]; then
        for config in "${TEST_CONFIGS[@]}"; do
            if ! vm_test "$config"; then
                failed_tests+=("vm_test_$config")
            fi
        done
    fi
    
    # Report results
    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        log "🎉 All tests passed!"
        exit 0
    else
        error "❌ ${#failed_tests[@]} test(s) failed:"
        printf '%s\n' "${failed_tests[@]}"
        exit 1
    fi
}

# Run tests
main "$@"
```

### 4. Performance Testing

#### Resource Usage Monitoring
```nix
# testing/performance/monitor.nix
{ config, lib, pkgs, ... }:

let
  performanceMonitor = pkgs.writeShellScriptBin "dots-hyprland-monitor" ''
    #!/usr/bin/env bash
    
    # Performance monitoring script
    LOG_FILE="$HOME/.cache/dots-hyprland/performance.log"
    INTERVAL=5
    
    mkdir -p "$(dirname "$LOG_FILE")"
    
    log_metrics() {
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # System metrics
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        local gpu_usage=""
        
        # GPU usage (if available)
        if command -v nvidia-smi >/dev/null 2>&1; then
            gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
        fi
        
        # Process-specific metrics
        local quickshell_mem=""
        local hyprland_mem=""
        
        if pgrep quickshell >/dev/null; then
            quickshell_mem=$(ps -o pid,vsz,rss,comm -p $(pgrep quickshell) | tail -n +2 | awk '{print $2","$3}')
        fi
        
        if pgrep Hyprland >/dev/null; then
            hyprland_mem=$(ps -o pid,vsz,rss,comm -p $(pgrep Hyprland) | tail -n +2 | awk '{print $2","$3}')
        fi
        
        # Log to file
        echo "$timestamp,$cpu_usage,$mem_usage,$gpu_usage,$quickshell_mem,$hyprland_mem" >> "$LOG_FILE"
    }
    
    # Initialize log file
    echo "timestamp,cpu_percent,mem_percent,gpu_percent,quickshell_vsz_rss,hyprland_vsz_rss" > "$LOG_FILE"
    
    # Monitor loop
    while true; do
        log_metrics
        sleep "$INTERVAL"
    done
  '';

  performanceAnalyzer = pkgs.writeShellScriptBin "analyze-performance" ''
    #!/usr/bin/env bash
    
    LOG_FILE="$HOME/.cache/dots-hyprland/performance.log"
    
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Performance log not found. Run dots-hyprland-monitor first."
        exit 1
    fi
    
    echo "=== Performance Analysis ==="
    echo
    
    # Average CPU usage
    avg_cpu=$(tail -n +2 "$LOG_FILE" | awk -F',' '{sum+=$2; count++} END {printf "%.1f", sum/count}')
    echo "Average CPU usage: $avg_cpu%"
    
    # Average memory usage
    avg_mem=$(tail -n +2 "$LOG_FILE" | awk -F',' '{sum+=$3; count++} END {printf "%.1f", sum/count}')
    echo "Average memory usage: $avg_mem%"
    
    # Peak memory usage
    peak_mem=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($3>max) max=$3} END {printf "%.1f", max}')
    echo "Peak memory usage: $peak_mem%"
    
    # Quickshell memory usage
    if tail -n +2 "$LOG_FILE" | awk -F',' '{print $5}' | grep -q ","; then
        avg_quickshell_rss=$(tail -n +2 "$LOG_FILE" | awk -F',' '{split($5,a,","); if(a[2]!="") {sum+=a[2]; count++}} END {if(count>0) printf "%.1f", sum/count/1024}')
        echo "Average Quickshell RSS: ${avg_quickshell_rss}MB"
    fi
    
    # Hyprland memory usage
    if tail -n +2 "$LOG_FILE" | awk -F',' '{print $6}' | grep -q ","; then
        avg_hyprland_rss=$(tail -n +2 "$LOG_FILE" | awk -F',' '{split($6,a,","); if(a[2]!="") {sum+=a[2]; count++}} END {if(count>0) printf "%.1f", sum/count/1024}')
        echo "Average Hyprland RSS: ${avg_hyprland_rss}MB"
    fi
    
    echo
    echo "=== Recommendations ==="
    
    if (( $(echo "$avg_cpu > 20" | bc -l) )); then
        echo "⚠️  High CPU usage detected. Consider disabling animations or reducing widget complexity."
    fi
    
    if (( $(echo "$avg_mem > 80" | bc -l) )); then
        echo "⚠️  High memory usage detected. Consider reducing the number of enabled features."
    fi
    
    if [[ -n "$avg_quickshell_rss" ]] && (( $(echo "$avg_quickshell_rss > 200" | bc -l) )); then
        echo "⚠️  Quickshell using significant memory. Check for memory leaks in widgets."
    fi
  '';
in
{
  home.packages = [ performanceMonitor performanceAnalyzer ];
}
```

#### Startup Time Testing
```bash
#!/usr/bin/env bash
# testing/performance/startup-test.sh

# Test startup time from login to usable desktop
test_startup_time() {
    local config=$1
    local iterations=${2:-5}
    local results=()
    
    echo "Testing startup time for $config ($iterations iterations)"
    
    for i in $(seq 1 $iterations); do
        echo "Iteration $i/$iterations"
        
        # Start VM
        local start_time=$(date +%s.%N)
        
        # Build and start VM
        local vm_path
        vm_path=$(nix build ".#nixosConfigurations.$config.config.system.build.vm" --no-link --print-out-paths)
        
        # Start VM and wait for desktop to be ready
        timeout 120 "$vm_path/bin/run-$config-vm" &
        local vm_pid=$!
        
        # Wait for Hyprland to start (check for socket)
        local ready=false
        local timeout_count=0
        
        while [[ $ready == false && $timeout_count -lt 60 ]]; do
            if pgrep -f "Hyprland" >/dev/null 2>&1; then
                # Check if Quickshell is also running
                if pgrep -f "quickshell" >/dev/null 2>&1; then
                    ready=true
                    break
                fi
            fi
            sleep 1
            ((timeout_count++))
        done
        
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)
        
        if [[ $ready == true ]]; then
            results+=("$duration")
            echo "  ✓ Startup time: ${duration}s"
        else
            echo "  ✗ Timeout waiting for desktop"
        fi
        
        # Clean up
        kill $vm_pid 2>/dev/null || true
        sleep 2
    done
    
    # Calculate statistics
    if [[ ${#results[@]} -gt 0 ]]; then
        local sum=0
        local min=${results[0]}
        local max=${results[0]}
        
        for time in "${results[@]}"; do
            sum=$(echo "$sum + $time" | bc)
            if (( $(echo "$time < $min" | bc -l) )); then
                min=$time
            fi
            if (( $(echo "$time > $max" | bc -l) )); then
                max=$time
            fi
        done
        
        local avg=$(echo "scale=2; $sum / ${#results[@]}" | bc)
        
        echo
        echo "=== Startup Time Results for $config ==="
        echo "Successful runs: ${#results[@]}/$iterations"
        echo "Average: ${avg}s"
        echo "Min: ${min}s"
        echo "Max: ${max}s"
        echo
        
        # Performance assessment
        if (( $(echo "$avg < 15" | bc -l) )); then
            echo "✅ Excellent startup performance"
        elif (( $(echo "$avg < 30" | bc -l) )); then
            echo "✅ Good startup performance"
        elif (( $(echo "$avg < 60" | bc -l) )); then
            echo "⚠️  Acceptable startup performance"
        else
            echo "❌ Poor startup performance - optimization needed"
        fi
    else
        echo "❌ All startup tests failed for $config"
        return 1
    fi
}

# Run startup tests for all configurations
main() {
    local configs=("basic-test" "full-features-test" "minimal-test")
    
    for config in "${configs[@]}"; do
        test_startup_time "$config" 3
        echo "----------------------------------------"
    done
}

main "$@"
```

### 5. User Experience Testing

#### Interactive Test Scenarios
```bash
#!/usr/bin/env bash
# testing/ux/interactive-tests.sh

# Interactive test scenarios for user experience validation
run_interactive_tests() {
    echo "=== Interactive User Experience Tests ==="
    echo
    echo "This script will guide you through testing key user interactions."
    echo "Please follow the prompts and report any issues."
    echo
    
    read -p "Press Enter to start testing..."
    
    # Test 1: Basic desktop functionality
    echo
    echo "Test 1: Basic Desktop Functionality"
    echo "1. Can you see the top bar with system information?"
    echo "2. Are workspaces visible and clickable?"
    echo "3. Does the system tray show network/audio/battery status?"
    echo
    read -p "Are all basic desktop elements working? (y/n): " basic_test
    
    # Test 2: Launcher/Overview
    echo
    echo "Test 2: Launcher and Overview"
    echo "1. Press Super key to open overview"
    echo "2. Try typing an application name"
    echo "3. Try a calculation (e.g., '2+2')"
    echo "4. Try a command (e.g., 'ls')"
    echo
    read -p "Does the launcher work correctly? (y/n): " launcher_test
    
    # Test 3: Window management
    echo
    echo "Test 3: Window Management"
    echo "1. Open a terminal (Super+Enter)"
    echo "2. Open another application"
    echo "3. Try switching workspaces (Super+1, Super+2, etc.)"
    echo "4. Try moving windows between workspaces (Super+Shift+1, etc.)"
    echo
    read -p "Does window management work correctly? (y/n): " window_test
    
    # Test 4: Theming
    echo
    echo "Test 4: Theming and Colors"
    echo "1. Do all applications use consistent colors?"
    echo "2. Are colors readable and accessible?"
    echo "3. Do animations feel smooth?"
    echo
    read -p "Is theming working correctly? (y/n): " theme_test
    
    # Test 5: System integration
    echo
    echo "Test 5: System Integration"
    echo "1. Try adjusting volume (scroll on top-right corner)"
    echo "2. Try adjusting brightness (if applicable)"
    echo "3. Test network connectivity"
    echo "4. Test audio playback"
    echo
    read -p "Does system integration work correctly? (y/n): " system_test
    
    # Test 6: Performance
    echo
    echo "Test 6: Performance"
    echo "1. Does the desktop feel responsive?"
    echo "2. Are there any noticeable delays or stutters?"
    echo "3. Is memory usage reasonable (check htop)?"
    echo
    read -p "Is performance acceptable? (y/n): " performance_test
    
    # Results summary
    echo
    echo "=== Test Results Summary ==="
    echo "Basic desktop functionality: $basic_test"
    echo "Launcher and overview: $launcher_test"
    echo "Window management: $window_test"
    echo "Theming and colors: $theme_test"
    echo "System integration: $system_test"
    echo "Performance: $performance_test"
    echo
    
    # Overall assessment
    local passed=0
    local total=6
    
    [[ "$basic_test" == "y" ]] && ((passed++))
    [[ "$launcher_test" == "y" ]] && ((passed++))
    [[ "$window_test" == "y" ]] && ((passed++))
    [[ "$theme_test" == "y" ]] && ((passed++))
    [[ "$system_test" == "y" ]] && ((passed++))
    [[ "$performance_test" == "y" ]] && ((passed++))
    
    echo "Overall: $passed/$total tests passed"
    
    if [[ $passed -eq $total ]]; then
        echo "🎉 All tests passed! The desktop environment is working well."
    elif [[ $passed -ge 4 ]]; then
        echo "✅ Most tests passed. Minor issues may need attention."
    else
        echo "❌ Multiple issues detected. Significant work needed."
    fi
    
    # Generate report
    cat > "/tmp/ux-test-report.txt" << EOF
dots-hyprland User Experience Test Report
Generated: $(date)

Test Results:
- Basic desktop functionality: $basic_test
- Launcher and overview: $launcher_test  
- Window management: $window_test
- Theming and colors: $theme_test
- System integration: $system_test
- Performance: $performance_test

Overall Score: $passed/$total

$(if [[ $passed -eq $total ]]; then
    echo "Status: PASS - Ready for production use"
elif [[ $passed -ge 4 ]]; then
    echo "Status: MOSTLY PASS - Minor issues to address"
else
    echo "Status: FAIL - Significant issues need resolution"
fi)
EOF
    
    echo
    echo "Report saved to /tmp/ux-test-report.txt"
}

run_interactive_tests
```

### 6. Regression Testing

#### Configuration Compatibility Testing
```nix
# testing/regression/compatibility-matrix.nix
{ lib, pkgs }:

let
  # Test matrix of different configuration combinations
  testMatrix = {
    # Basic configurations
    minimal = {
      components = {
        hyprland = true;
        quickshell = true;
        theming = false;
        ai = false;
        audio = false;
      };
      features = {
        overview = true;
        sidebar = false;
        notifications = false;
      };
    };
    
    standard = {
      components = {
        hyprland = true;
        quickshell = true;
        theming = true;
        ai = false;
        audio = true;
      };
      features = {
        overview = true;
        sidebar = true;
        notifications = true;
        mediaControls = true;
      };
    };
    
    full = {
      components = {
        hyprland = true;
        quickshell = true;
        theming = true;
        ai = true;
        audio = true;
      };
      features = {
        overview = true;
        sidebar = true;
        notifications = true;
        mediaControls = true;
        screenCorners = true;
        onScreenKeyboard = true;
        cheatsheet = true;
      };
    };
  };

  # Generate test configurations
  generateTestConfig = name: config: {
    name = "compatibility-test-${name}";
    value = { config, lib, pkgs, ... }: {
      imports = [ ../../modules/home-manager.nix ];
      
      programs.dots-hyprland = {
        enable = true;
        style = "illogical-impulse";
      } // config;
      
      # Test-specific settings
      home.username = "testuser";
      home.homeDirectory = "/home/testuser";
      home.stateVersion = "24.05";
    };
  };

  testConfigurations = lib.mapAttrs generateTestConfig testMatrix;
in
{
  inherit testConfigurations testMatrix;
}
```

## Validation Criteria

### 1. Functional Requirements
- [ ] **Desktop Environment Boots** - System starts to usable desktop
- [ ] **Core Widgets Function** - Bar, overview, essential widgets work
- [ ] **Window Management** - Hyprland window management operational
- [ ] **Application Integration** - Applications launch and integrate properly
- [ ] **System Services** - Audio, network, bluetooth function correctly
- [ ] **Theming Applied** - Material You theming works across applications
- [ ] **User Input Responsive** - Keyboard/mouse input handled correctly

### 2. Performance Requirements
- [ ] **Startup Time** - Desktop ready within 30 seconds
- [ ] **Memory Usage** - Total system memory < 2GB at idle
- [ ] **CPU Usage** - Average CPU usage < 10% at idle
- [ ] **Responsiveness** - UI interactions respond within 100ms
- [ ] **Stability** - No crashes during 1-hour usage session

### 3. Compatibility Requirements
- [ ] **Hardware Support** - Works on Intel/AMD/NVIDIA systems
- [ ] **NixOS Versions** - Compatible with stable and unstable channels
- [ ] **Home Manager** - Integrates properly with Home Manager
- [ ] **Multi-User** - Works correctly with multiple user accounts
- [ ] **Updates** - System updates don't break functionality

### 4. User Experience Requirements
- [ ] **Intuitive Interface** - New users can navigate basic functions
- [ ] **Customization** - Users can modify configuration easily
- [ ] **Documentation** - Clear setup and usage instructions
- [ ] **Error Handling** - Graceful failure modes with helpful messages
- [ ] **Accessibility** - Meets basic accessibility standards

## Action Items for Phase 6

### Week 1: Test Infrastructure
1. **Set up VM testing environment** - Multiple hardware configurations
2. **Create automated test suite** - Build, integration, and performance tests
3. **Implement monitoring tools** - Resource usage and performance tracking
4. **Design test scenarios** - Cover common usage patterns

### Week 2: Comprehensive Testing
1. **Run automated test suite** - All configurations and scenarios
2. **Perform manual testing** - User experience and edge cases
3. **Conduct performance testing** - Startup time, resource usage, responsiveness
4. **Test hardware compatibility** - Different GPU/audio/input configurations

### Week 3: Issue Resolution
1. **Identify and fix critical issues** - Blocking problems for basic functionality
2. **Optimize performance** - Address resource usage and responsiveness issues
3. **Improve error handling** - Better failure modes and user feedback
4. **Update documentation** - Reflect testing results and known issues

### Week 4: Validation & Sign-off
1. **Final validation testing** - Confirm all requirements met
2. **Performance benchmarking** - Document performance characteristics
3. **Compatibility verification** - Test across different NixOS configurations
4. **User acceptance testing** - Get feedback from potential users

## Expected Outcomes

### Deliverables
1. **Comprehensive test suite** - Automated testing for all components
2. **Performance benchmarks** - Documented performance characteristics
3. **Compatibility matrix** - Supported configurations and hardware
4. **User testing results** - Feedback from real-world usage scenarios
5. **Issue tracking** - Documented known issues and workarounds
6. **Validation report** - Formal assessment of readiness

### Success Criteria
- [ ] All automated tests pass consistently
- [ ] Performance meets established benchmarks
- [ ] Compatible with target NixOS configurations
- [ ] User experience meets quality standards
- [ ] Critical issues resolved or documented
- [ ] Ready for Phase 7 (Community & Maintenance)

### Quality Gates
- **95% test pass rate** - Automated tests must pass consistently
- **<30s startup time** - Desktop environment ready quickly
- **<2GB memory usage** - Reasonable resource consumption
- **Zero critical bugs** - No blocking issues for basic functionality
- **Positive user feedback** - Users can accomplish basic tasks easily

This comprehensive testing and validation phase ensures that the NixOS adaptation of dots-hyprland meets quality standards and provides a reliable, performant desktop environment for users.
