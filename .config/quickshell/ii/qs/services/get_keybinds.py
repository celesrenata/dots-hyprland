#!/usr/bin/env python3

import json
import subprocess
import sys
import os

def get_hyprland_keybinds():
    """Get keybinds from Hyprland and return as JSON"""
    try:
        # Get keybinds from hyprctl
        result = subprocess.run(['hyprctl', 'binds', '-j'], 
                              capture_output=True, text=True, check=True)
        
        keybinds_data = json.loads(result.stdout)
        
        # Process and organize keybinds
        organized_keybinds = []
        
        for bind in keybinds_data:
            # Extract relevant information
            keybind = {
                'modmask': bind.get('modmask', 0),
                'key': bind.get('key', ''),
                'keycode': bind.get('keycode', 0),
                'catch_all': bind.get('catch_all', False),
                'release': bind.get('release', False),
                'repeat': bind.get('repeat', False),
                'mouse': bind.get('mouse', False),
                'locked': bind.get('locked', False),
                'description': bind.get('description', ''),
                'dispatcher': bind.get('dispatcher', ''),
                'arg': bind.get('arg', '')
            }
            
            organized_keybinds.append(keybind)
        
        return organized_keybinds
        
    except subprocess.CalledProcessError as e:
        print(f"Error running hyprctl: {e}", file=sys.stderr)
        return []
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        return []

def main():
    """Main function"""
    keybinds = get_hyprland_keybinds()
    
    # Output as JSON
    print(json.dumps(keybinds, indent=2))

if __name__ == "__main__":
    main()
