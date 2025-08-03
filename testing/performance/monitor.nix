{ config, lib, pkgs, ... }:

let
  performanceMonitor = pkgs.writeShellScriptBin "dots-hyprland-monitor" ''
    #!/usr/bin/env bash
    
    # Performance monitoring script for dots-hyprland
    LOG_FILE="$HOME/.cache/dots-hyprland/performance.log"
    INTERVAL=5
    
    mkdir -p "$(dirname "$LOG_FILE")"
    
    log_metrics() {
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # System metrics
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | tr -d ' ')
        local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
        
        # GPU usage (if available)
        local gpu_usage=""
        if command -v nvidia-smi >/dev/null 2>&1; then
            gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
        fi
        
        # Process-specific metrics
        local quickshell_mem=""
        local quickshell_cpu=""
        local hyprland_mem=""
        local hyprland_cpu=""
        
        if pgrep quickshell >/dev/null; then
            local quickshell_pid=$(pgrep quickshell | head -1)
            quickshell_mem=$(ps -o rss= -p "$quickshell_pid" 2>/dev/null | awk '{print $1/1024}' || echo "0")
            quickshell_cpu=$(ps -o %cpu= -p "$quickshell_pid" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        
        if pgrep Hyprland >/dev/null; then
            local hyprland_pid=$(pgrep Hyprland | head -1)
            hyprland_mem=$(ps -o rss= -p "$hyprland_pid" 2>/dev/null | awk '{print $1/1024}' || echo "0")
            hyprland_cpu=$(ps -o %cpu= -p "$hyprland_pid" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        
        # Disk I/O
        local disk_read=""
        local disk_write=""
        if command -v iostat >/dev/null 2>&1; then
            local disk_stats=$(iostat -d 1 2 | tail -1)
            disk_read=$(echo "$disk_stats" | awk '{print $3}')
            disk_write=$(echo "$disk_stats" | awk '{print $4}')
        fi
        
        # Network I/O
        local net_rx=""
        local net_tx=""
        if [[ -f /proc/net/dev ]]; then
            local net_stats=$(grep -E "(eth|wlan|enp|wlp)" /proc/net/dev | head -1)
            if [[ -n "$net_stats" ]]; then
                net_rx=$(echo "$net_stats" | awk '{print $2}')
                net_tx=$(echo "$net_stats" | awk '{print $10}')
            fi
        fi
        
        # Log to file (CSV format)
        echo "$timestamp,$cpu_usage,$mem_usage,$load_avg,$gpu_usage,$quickshell_mem,$quickshell_cpu,$hyprland_mem,$hyprland_cpu,$disk_read,$disk_write,$net_rx,$net_tx" >> "$LOG_FILE"
    }
    
    # Initialize log file with headers
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "timestamp,cpu_percent,mem_percent,load_avg,gpu_percent,quickshell_mem_mb,quickshell_cpu,hyprland_mem_mb,hyprland_cpu,disk_read_kb,disk_write_kb,net_rx_bytes,net_tx_bytes" > "$LOG_FILE"
    fi
    
    echo "Starting performance monitoring..."
    echo "Logging to: $LOG_FILE"
    echo "Interval: ''${INTERVAL}s"
    echo "Press Ctrl+C to stop"
    
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
    
    echo "=== dots-hyprland Performance Analysis ==="
    echo
    
    # Check if we have bc for calculations
    if ! command -v bc >/dev/null 2>&1; then
        echo "Warning: bc not found, some calculations may be unavailable"
    fi
    
    # Basic statistics
    local total_entries=$(tail -n +2 "$LOG_FILE" | wc -l)
    echo "Total monitoring entries: $total_entries"
    
    if [[ $total_entries -eq 0 ]]; then
        echo "No performance data available"
        exit 1
    fi
    
    # Average CPU usage
    local avg_cpu=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($2!="") {sum+=$2; count++}} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}')
    echo "Average CPU usage: $avg_cpu%"
    
    # Average memory usage
    local avg_mem=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($3!="") {sum+=$3; count++}} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}')
    echo "Average memory usage: $avg_mem%"
    
    # Peak memory usage
    local peak_mem=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($3!="" && $3>max) max=$3} END {if(max) printf "%.1f", max; else print "N/A"}')
    echo "Peak memory usage: $peak_mem%"
    
    # Average load
    local avg_load=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($4!="") {sum+=$4; count++}} END {if(count>0) printf "%.2f", sum/count; else print "N/A"}')
    echo "Average load: $avg_load"
    
    # Quickshell performance
    local avg_quickshell_mem=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($6!="" && $6>0) {sum+=$6; count++}} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}')
    local avg_quickshell_cpu=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($7!="" && $7>0) {sum+=$7; count++}} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}')
    
    if [[ "$avg_quickshell_mem" != "N/A" ]]; then
        echo "Average Quickshell memory: ''${avg_quickshell_mem}MB"
        echo "Average Quickshell CPU: ''${avg_quickshell_cpu}%"
    else
        echo "Quickshell performance: Not running or no data"
    fi
    
    # Hyprland performance
    local avg_hyprland_mem=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($8!="" && $8>0) {sum+=$8; count++}} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}')
    local avg_hyprland_cpu=$(tail -n +2 "$LOG_FILE" | awk -F',' '{if($9!="" && $9>0) {sum+=$9; count++}} END {if(count>0) printf "%.1f", sum/count; else print "N/A"}')
    
    if [[ "$avg_hyprland_mem" != "N/A" ]]; then
        echo "Average Hyprland memory: ''${avg_hyprland_mem}MB"
        echo "Average Hyprland CPU: ''${avg_hyprland_cpu}%"
    else
        echo "Hyprland performance: Not running or no data"
    fi
    
    echo
    echo "=== Performance Assessment ==="
    
    # Performance recommendations
    if command -v bc >/dev/null 2>&1; then
        if [[ "$avg_cpu" != "N/A" ]] && (( $(echo "$avg_cpu > 20" | bc -l) )); then
            echo "⚠️  High CPU usage detected. Consider:"
            echo "   - Disabling animations"
            echo "   - Reducing widget complexity"
            echo "   - Checking for background processes"
        fi
        
        if [[ "$avg_mem" != "N/A" ]] && (( $(echo "$avg_mem > 80" | bc -l) )); then
            echo "⚠️  High memory usage detected. Consider:"
            echo "   - Reducing enabled features"
            echo "   - Checking for memory leaks"
            echo "   - Adding more RAM"
        fi
        
        if [[ "$avg_quickshell_mem" != "N/A" ]] && (( $(echo "$avg_quickshell_mem > 200" | bc -l) )); then
            echo "⚠️  Quickshell using significant memory. Consider:"
            echo "   - Simplifying widget configurations"
            echo "   - Checking for memory leaks in custom widgets"
            echo "   - Restarting Quickshell periodically"
        fi
        
        if [[ "$avg_hyprland_mem" != "N/A" ]] && (( $(echo "$avg_hyprland_mem > 150" | bc -l) )); then
            echo "⚠️  Hyprland using significant memory. Consider:"
            echo "   - Reducing window rules complexity"
            echo "   - Disabling blur effects"
            echo "   - Checking Hyprland configuration"
        fi
    fi
    
    # Check if performance is good
    local performance_good=true
    if [[ "$avg_cpu" != "N/A" ]] && command -v bc >/dev/null 2>&1; then
        if (( $(echo "$avg_cpu > 15" | bc -l) )); then
            performance_good=false
        fi
    fi
    
    if [[ "$avg_mem" != "N/A" ]] && command -v bc >/dev/null 2>&1; then
        if (( $(echo "$avg_mem > 70" | bc -l) )); then
            performance_good=false
        fi
    fi
    
    if [[ $performance_good == true ]]; then
        echo "✅ Overall performance looks good!"
    else
        echo "⚠️  Performance may need optimization"
    fi
    
    echo
    echo "=== Data Collection Period ==="
    local first_entry=$(tail -n +2 "$LOG_FILE" | head -1 | cut -d',' -f1)
    local last_entry=$(tail -1 "$LOG_FILE" | cut -d',' -f1)
    echo "From: $first_entry"
    echo "To: $last_entry"
    echo "Total entries: $total_entries"
    
    echo
    echo "Log file: $LOG_FILE"
    echo "Use 'tail -f $LOG_FILE' to monitor in real-time"
  '';

  startupTimer = pkgs.writeShellScriptBin "startup-timer" ''
    #!/usr/bin/env bash
    
    # Measure startup time for dots-hyprland components
    
    echo "=== dots-hyprland Startup Time Measurement ==="
    echo
    
    # Function to measure command startup time
    measure_startup() {
        local command="$1"
        local description="$2"
        local timeout="''${3:-10}"
        
        echo "Measuring: $description"
        
        local start_time=$(date +%s.%N)
        
        if timeout "$timeout" $command >/dev/null 2>&1; then
            local end_time=$(date +%s.%N)
            local duration=$(echo "$end_time - $start_time" | bc -l)
            printf "  ✅ %s: %.3fs\n" "$description" "$duration"
            return 0
        else
            echo "  ❌ $description: Failed or timeout"
            return 1
        fi
    }
    
    # Test various startup times
    echo "Testing component startup times..."
    echo
    
    # Quickshell startup (dry run)
    if command -v quickshell >/dev/null 2>&1; then
        measure_startup "quickshell --help" "Quickshell help" 5
    else
        echo "  ⚠️  Quickshell not found in PATH"
    fi
    
    # Hyprland startup (version check)
    if command -v Hyprland >/dev/null 2>&1; then
        measure_startup "Hyprland --version" "Hyprland version" 5
    else
        echo "  ⚠️  Hyprland not found in PATH"
    fi
    
    # Terminal startup
    if command -v foot >/dev/null 2>&1; then
        measure_startup "foot --version" "foot terminal" 3
    fi
    
    # Launcher startup
    if command -v fuzzel >/dev/null 2>&1; then
        measure_startup "fuzzel --version" "fuzzel launcher" 3
    fi
    
    echo
    echo "=== System Boot Time ==="
    
    # System boot time (if systemd-analyze is available)
    if command -v systemd-analyze >/dev/null 2>&1; then
        echo "System boot analysis:"
        systemd-analyze time 2>/dev/null || echo "  ⚠️  Boot time analysis not available"
        echo
        
        echo "Slowest services:"
        systemd-analyze blame 2>/dev/null | head -10 || echo "  ⚠️  Service analysis not available"
    else
        echo "  ⚠️  systemd-analyze not available"
    fi
    
    echo
    echo "=== Recommendations ==="
    echo "For optimal startup performance:"
    echo "- Keep Quickshell startup under 2 seconds"
    echo "- Minimize autostart services"
    echo "- Use SSD storage for better I/O performance"
    echo "- Consider disabling heavy animations during startup"
  '';

in
{
  home.packages = [ 
    performanceMonitor 
    performanceAnalyzer 
    startupTimer
    
    # Additional monitoring tools
    pkgs.htop
    pkgs.btop
    pkgs.iotop
    pkgs.nethogs
    pkgs.sysstat
    pkgs.bc
  ];
}
