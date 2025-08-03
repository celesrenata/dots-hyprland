#!/usr/bin/env bash

# Phase 6: Interactive User Experience Tests
# Guided testing scenarios for validating user interactions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[UX TEST] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[UX WARN] $1${NC}"
}

error() {
    echo -e "${RED}[UX ERROR] $1${NC}"
}

info() {
    echo -e "${BLUE}[UX INFO] $1${NC}"
}

test_header() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Interactive test scenarios
run_interactive_tests() {
    echo "🧪 dots-hyprland User Experience Testing Suite"
    echo "=============================================="
    echo
    echo "This interactive test suite will guide you through testing key user interactions."
    echo "Please follow the prompts and report any issues you encounter."
    echo
    echo "Prerequisites:"
    echo "- dots-hyprland should be running"
    echo "- You should be in a Hyprland session"
    echo "- All core components should be active"
    echo
    read -p "Press Enter to start testing, or Ctrl+C to exit..."
    echo

    # Test results tracking
    local test_results=()
    
    # Test 1: Basic Desktop Functionality
    test_header "Test 1: Basic Desktop Functionality"
    echo
    echo "Please verify the following basic desktop elements:"
    echo "1. Can you see the top bar with system information?"
    echo "2. Are workspaces visible and clickable in the bar?"
    echo "3. Does the system tray show network/audio/battery status?"
    echo "4. Is the current time displayed correctly?"
    echo "5. Are window titles shown in the bar?"
    echo
    read -p "Are all basic desktop elements working correctly? (y/n): " basic_test
    test_results+=("Basic Desktop: $basic_test")
    
    if [[ "$basic_test" != "y" ]]; then
        echo "Please describe what's not working:"
        read -p "> " basic_issues
        test_results+=("Basic Desktop Issues: $basic_issues")
    fi
    echo

    # Test 2: Window Management
    test_header "Test 2: Window Management"
    echo
    echo "Please test window management functionality:"
    echo "1. Open a terminal with Super+Return"
    echo "2. Open another application (e.g., file manager with Super+E)"
    echo "3. Try switching between windows with Alt+Tab"
    echo "4. Try moving windows with Super+Shift+Arrow keys"
    echo "5. Try resizing windows by dragging edges"
    echo "6. Test floating mode with Super+V"
    echo "7. Test fullscreen with Super+F"
    echo
    read -p "Does window management work correctly? (y/n): " window_test
    test_results+=("Window Management: $window_test")
    
    if [[ "$window_test" != "y" ]]; then
        echo "Please describe the window management issues:"
        read -p "> " window_issues
        test_results+=("Window Management Issues: $window_issues")
    fi
    echo

    # Test 3: Workspace Management
    test_header "Test 3: Workspace Management"
    echo
    echo "Please test workspace functionality:"
    echo "1. Switch to workspace 2 with Super+2"
    echo "2. Open an application in workspace 2"
    echo "3. Switch back to workspace 1 with Super+1"
    echo "4. Move a window to workspace 2 with Super+Shift+2"
    echo "5. Try clicking workspace indicators in the bar"
    echo
    read -p "Does workspace management work correctly? (y/n): " workspace_test
    test_results+=("Workspace Management: $workspace_test")
    
    if [[ "$workspace_test" != "y" ]]; then
        echo "Please describe the workspace issues:"
        read -p "> " workspace_issues
        test_results+=("Workspace Management Issues: $workspace_issues")
    fi
    echo

    # Test 4: Application Launcher
    test_header "Test 4: Application Launcher"
    echo
    echo "Please test the application launcher:"
    echo "1. Press Super+Space to open the launcher"
    echo "2. Type 'term' to search for terminal applications"
    echo "3. Press Enter to launch the selected application"
    echo "4. Try launching different applications by name"
    echo "5. Test calculator functionality (type '2+2' in launcher)"
    echo
    read -p "Does the launcher work correctly? (y/n): " launcher_test
    test_results+=("Application Launcher: $launcher_test")
    
    if [[ "$launcher_test" != "y" ]]; then
        echo "Please describe the launcher issues:"
        read -p "> " launcher_issues
        test_results+=("Application Launcher Issues: $launcher_issues")
    fi
    echo

    # Test 5: Theming and Visual Elements
    test_header "Test 5: Theming and Visual Elements"
    echo
    echo "Please evaluate the visual aspects:"
    echo "1. Do all applications use consistent colors?"
    echo "2. Are colors readable and provide good contrast?"
    echo "3. Do animations feel smooth and responsive?"
    echo "4. Are window decorations (borders, shadows) working?"
    echo "5. Does the overall theme look cohesive?"
    echo
    read -p "Is theming working correctly? (y/n): " theme_test
    test_results+=("Theming: $theme_test")
    
    if [[ "$theme_test" != "y" ]]; then
        echo "Please describe the theming issues:"
        read -p "> " theme_issues
        test_results+=("Theming Issues: $theme_issues")
    fi
    echo

    # Test 6: System Integration
    test_header "Test 6: System Integration"
    echo
    echo "Please test system integration features:"
    echo "1. Try adjusting volume (use volume keys or click audio icon)"
    echo "2. Try adjusting brightness (if applicable)"
    echo "3. Test network connectivity (open a web browser)"
    echo "4. Test audio playback (play a video or music)"
    echo "5. Check if notifications appear properly"
    echo
    read -p "Does system integration work correctly? (y/n): " system_test
    test_results+=("System Integration: $system_test")
    
    if [[ "$system_test" != "y" ]]; then
        echo "Please describe the system integration issues:"
        read -p "> " system_issues
        test_results+=("System Integration Issues: $system_issues")
    fi
    echo

    # Test 7: Performance and Responsiveness
    test_header "Test 7: Performance and Responsiveness"
    echo
    echo "Please evaluate system performance:"
    echo "1. Does the desktop feel responsive to input?"
    echo "2. Are there any noticeable delays or stutters?"
    echo "3. Do animations play smoothly without dropping frames?"
    echo "4. Is memory usage reasonable? (check with htop if available)"
    echo "5. Does the system remain stable during normal use?"
    echo
    read -p "Is performance acceptable? (y/n): " performance_test
    test_results+=("Performance: $performance_test")
    
    if [[ "$performance_test" != "y" ]]; then
        echo "Please describe the performance issues:"
        read -p "> " performance_issues
        test_results+=("Performance Issues: $performance_issues")
    fi
    echo

    # Test 8: Accessibility and Usability
    test_header "Test 8: Accessibility and Usability"
    echo
    echo "Please evaluate accessibility and usability:"
    echo "1. Are text and UI elements large enough to read comfortably?"
    echo "2. Is keyboard navigation working for all functions?"
    echo "3. Are there clear visual indicators for interactive elements?"
    echo "4. Can you easily discover and remember key shortcuts?"
    echo "5. Is the overall interface intuitive for new users?"
    echo
    read -p "Is accessibility and usability good? (y/n): " accessibility_test
    test_results+=("Accessibility: $accessibility_test")
    
    if [[ "$accessibility_test" != "y" ]]; then
        echo "Please describe the accessibility issues:"
        read -p "> " accessibility_issues
        test_results+=("Accessibility Issues: $accessibility_issues")
    fi
    echo

    # Results summary
    test_header "Test Results Summary"
    echo
    local passed=0
    local total=8
    
    for result in "${test_results[@]}"; do
        if [[ "$result" =~ ": y" ]]; then
            echo "✅ $result"
            ((passed++))
        elif [[ "$result" =~ ": n" ]]; then
            echo "❌ $result"
        elif [[ "$result" =~ "Issues:" ]]; then
            echo "   └─ $result"
        fi
    done
    
    echo
    echo "Overall Results: $passed/$total tests passed"
    echo
    
    # Overall assessment
    if [[ $passed -eq $total ]]; then
        log "🎉 Excellent! All user experience tests passed!"
        echo "The desktop environment is working very well and provides a great user experience."
    elif [[ $passed -ge 6 ]]; then
        warn "✅ Good! Most tests passed with minor issues."
        echo "The desktop environment is working well with some areas for improvement."
    elif [[ $passed -ge 4 ]]; then
        warn "⚠️  Acceptable with several issues to address."
        echo "The desktop environment is functional but needs attention in several areas."
    else
        error "❌ Multiple critical issues detected."
        echo "The desktop environment needs significant work before it's ready for daily use."
    fi
    
    # Generate detailed report
    local report_file="/tmp/ux-test-report-$(date +%Y%m%d_%H%M%S).txt"
    cat > "$report_file" << EOF
dots-hyprland User Experience Test Report
Generated: $(date)
Tester: $(whoami)
System: $(uname -a)

=== Test Results ===
$(for result in "${test_results[@]}"; do echo "$result"; done)

=== Overall Assessment ===
Tests Passed: $passed/$total
$(if [[ $passed -eq $total ]]; then
    echo "Status: EXCELLENT - Ready for production use"
    echo "All user experience aspects are working correctly."
elif [[ $passed -ge 6 ]]; then
    echo "Status: GOOD - Minor issues to address"
    echo "Most functionality works well with some polish needed."
elif [[ $passed -ge 4 ]]; then
    echo "Status: ACCEPTABLE - Several issues to fix"
    echo "Core functionality works but needs improvement."
else
    echo "Status: NEEDS WORK - Major issues to resolve"
    echo "Significant problems prevent comfortable daily use."
fi)

=== Recommendations ===
$(if [[ $passed -lt $total ]]; then
    echo "Priority areas for improvement:"
    for result in "${test_results[@]}"; do
        if [[ "$result" =~ ": n" ]]; then
            echo "- $(echo "$result" | cut -d':' -f1)"
        fi
    done
    echo
    echo "Next steps:"
    echo "1. Address failing test areas"
    echo "2. Re-run tests after fixes"
    echo "3. Consider user feedback for improvements"
else
    echo "Excellent work! The user experience is very good."
    echo "Consider these optional enhancements:"
    echo "- Performance optimizations"
    echo "- Additional customization options"
    echo "- Advanced features implementation"
fi)

=== System Information ===
Desktop Environment: dots-hyprland
Session Type: $(echo $XDG_SESSION_TYPE)
Display Server: $(echo $WAYLAND_DISPLAY)
Shell: $(echo $SHELL)
Memory: $(free -h | grep Mem | awk '{print "Used: " $3 " / Total: " $2}')
CPU: $(nproc) cores
EOF

    echo
    log "Detailed report saved to: $report_file"
    echo
    echo "Thank you for testing dots-hyprland! Your feedback helps improve the user experience."
}

# Automated UX checks (non-interactive)
run_automated_ux_checks() {
    test_header "Automated UX Checks"
    echo
    
    local checks_passed=0
    local total_checks=0
    
    # Check if Hyprland is running
    ((total_checks++))
    if pgrep -x Hyprland >/dev/null; then
        log "✅ Hyprland is running"
        ((checks_passed++))
    else
        error "❌ Hyprland is not running"
    fi
    
    # Check if Quickshell is running
    ((total_checks++))
    if pgrep -x quickshell >/dev/null; then
        log "✅ Quickshell is running"
        ((checks_passed++))
    else
        error "❌ Quickshell is not running"
    fi
    
    # Check if essential binaries are available
    local essential_binaries=("foot" "fuzzel" "hyprctl")
    for binary in "${essential_binaries[@]}"; do
        ((total_checks++))
        if command -v "$binary" >/dev/null 2>&1; then
            log "✅ $binary is available"
            ((checks_passed++))
        else
            error "❌ $binary is not available"
        fi
    done
    
    # Check if configuration files exist
    local config_files=(
        "$HOME/.config/hypr/hyprland.conf"
        "$HOME/.config/foot/foot.ini"
        "$HOME/.config/fuzzel/fuzzel.ini"
    )
    
    for config_file in "${config_files[@]}"; do
        ((total_checks++))
        if [[ -f "$config_file" ]]; then
            log "✅ Configuration exists: $(basename "$config_file")"
            ((checks_passed++))
        else
            warn "⚠️  Configuration missing: $(basename "$config_file")"
        fi
    done
    
    # Check system resources
    ((total_checks++))
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    if [[ $mem_usage -lt 80 ]]; then
        log "✅ Memory usage acceptable: ${mem_usage}%"
        ((checks_passed++))
    else
        warn "⚠️  High memory usage: ${mem_usage}%"
    fi
    
    echo
    echo "Automated UX Checks: $checks_passed/$total_checks passed"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        log "🎉 All automated checks passed!"
        return 0
    else
        warn "⚠️  Some automated checks failed"
        return 1
    fi
}

# Main function
main() {
    case "${1:-interactive}" in
        "interactive")
            run_interactive_tests
            ;;
        "automated")
            run_automated_ux_checks
            ;;
        "both")
            run_automated_ux_checks
            echo
            echo "Press Enter to continue with interactive tests..."
            read
            run_interactive_tests
            ;;
        *)
            echo "Usage: $0 [interactive|automated|both]"
            echo
            echo "  interactive  - Run interactive user experience tests (default)"
            echo "  automated    - Run automated checks only"
            echo "  both         - Run both automated and interactive tests"
            exit 1
            ;;
    esac
}

main "$@"
