export const keybindList = [[
    {
        "icon": "pin_drop",
        "name": "Workspaces: navigation",
        "binds": [
            { "keys": ["󰘳", "+", "#"], "action": "Go to workspace #" },
            { "keys": ["Ctrl", "󰘳", "+", "S"], "action": "Toggle special workspace" },
            { "keys": ["󰘳", "+", "(Scroll ↑↓)"], "action": "Go to workspace -1/+1" },
            { "keys": ["Ctrl", "󰘳", "+", "←"], "action": "Go to workspace on the left" },
            { "keys": ["Ctrl", "󰘳", "+", "→"], "action": "Go to workspace on the right" },
            { "keys": ["󰘳", "+", "PageUp"], "action": "Go to workspace on the left" },
            { "keys": ["󰘳", "+", "PageDown"], "action": "Go to workspace on the right" }
        ],
        "id": 1
    },
    {
        "icon": "overview_key",
        "name": "Workspaces: management",
        "binds": [
            { "keys": ["󰘳", "⌥", "+", "#"], "action": "Move window to workspace #" },
            { "keys": ["󰘳", "⌥", "+", "S"], "action": "Move window to special workspace" },
            { "keys": ["󰘳", "⌥", "+", "PageUp"], "action": "Move window to workspace on the left" },
            { "keys": ["󰘳", "⌥", "+", "PageDown"], "action": "Move window to workspace on the right" }
        ],
        "id": 2
    },
    {
        "icon": "move_group",
        "name": "Windows",
        "binds": [
            { "keys": ["󰘳", "+", "←↑→↓"], "action": "Focus window in direction" },
            { "keys": ["󰘳", "Shift", "+", "←↑→↓"], "action": "Swap window in direction" },
            { "keys": ["󰘳", "+", ";"], "action": "Split ratio -" },
            { "keys": ["󰘳", "+", "'"], "action": "Split ratio +" },
            { "keys": ["󰘳", "+", "Lmb"], "action": "Move window" },
            { "keys": ["󰘳", "+", "Rmb"], "action": "Resize window" },
            { "keys": ["󰘳", "+", "F"], "action": "Fullscreen" },
            { "keys": ["󰘳", "⌥", "+", "F"], "action": "Fake fullscreen" }
        ],
        "id": 3
    }
],
[
    {
        "icon": "widgets",
        "name": "Widgets (AGS)",
        "binds": [
            { "keys": ["󰘳", "OR", "󰘳", "+", "Tab"], "action": "Toggle overview/launcher" },
            { "keys": ["Ctrl", "󰘳", "+", "R"], "action": "Restart AGS" },
            { "keys": ["󰘳", "+", "/"], "action": "Toggle this cheatsheet" },
            { "keys": ["󰘳", "+", "N"], "action": "Toggle system sidebar" },
            { "keys": ["󰘳", "+", "B", "OR", "󰘳", "+", "O"], "action": "Toggle utilities sidebar" },
            { "keys": ["󰘳", "+", "K"], "action": "Toggle virtual keyboard" },
            { "keys": ["Ctrl", "⌥", "+", "Del"], "action": "Power/Session menu" },
            { "keys": ["󰘳", "⌥", "+", "Del"], "action": "Open btop" },

            { "keys": ["Esc"], "action": "Exit a window" },
            { "keys": ["󰘳", "⌥", "+", "Q"], "action": "Kill a window" },
            { "keys": ["rightCtrl"], "action": "Dismiss/close sidebar" },

            { "keys": ["Ctrl", "󰘳", "+", "T"], "action": "Change wallpaper+colorscheme" },

            // { "keys": ["󰘳", "+", "B"], "action": "Toggle left sidebar" },
            // { "keys": ["󰘳", "+", "N"], "action": "Toggle right sidebar" },
            // { "keys": ["󰘳", "+", "G"], "action": "Toggle volume mixer" },
            // { "keys": ["󰘳", "+", "M"], "action": "Toggle useless audio visualizer" },
            // { "keys": ["(right)Ctrl"], "action": "Dismiss notification & close menus" }
        ],
        "id": 4
    },
    {
        "icon": "construction",
        "name": "Utilities",
        "binds": [ 
	    { "keys": ["󰘳", "Shift", "+", "4"], "action": "Screen snip  >>  clipboard" },
            { "keys": ["󰘳", "Shift", "+", "T"], "action": "Image to text  >>  clipboard" },
            { "keys": ["󰘳", "Shift", "+", "C"], "action": "Color picker" },
            { "keys": ["󰘳", "Shift", "+", "5"], "action": "Record region without sound" },
            { "keys": ["󰘳", "⌥", "+", "5"], "action": "Record region with sound" },
            { "keys": ["󰘳", "Shift", "⌥", "+", "5"], "action": "Record screen with sound" },
            { "keys": ["󰘳", "Ctrl", "+", "3"], "action": "Calculator" },
            { "keys": ["󰘳", "Ctrl", "+", "N"], "action": "Daylight Filter Increase" },
            { "keys": ["󰘳", "Ctrl", "⌥", "+", "N"], "action": "Daylight Filter Decrease" },
            { "keys": ["󰘳", "Ctrl", "+", "L"], "action": "Lock desktop" },
        ],
        "id": 5
    },
],
[
    {
        "icon": "apps",
        "name": "Apps",
        "binds": [
            { "keys": ["󰘳", "Ctrl", "+", "H"], "action": "Launch terminal: Foot" },
            { "keys": ["󰘳", "Ctrl", "+", "B"], "action": "Launch browser: Firefox" },
	    { "keys": ["󰘳", "Ctrl", "Shift", "+", "B"], "action": "Launch browser: Chromium" },
            { "keys": ["󰘳", "Ctrl", "+", "C"], "action": "Launch editor: vscode" },
            { "keys": ["󰘳", "Ctrl", "Shift", "+", "C"], "action": "Launch media: JetBrains ToolBox" },
            { "keys": ["󰘳", "Ctrl", "+", "X"], "action": "Launch editor: Sublime" },
            { "keys": ["󰘳", "Ctrl", "+", "I"], "action": "Launch settings: GNOME Control center" }
        ],
        "id": 6
    },
    {
        "icon": "keyboard",
        "name": "Typing",
        "binds": [
            { "keys": ["󰘳", "󰘵", "+", "."], "action": "Emoji picker  >>  clipboard" },
            { "keys": ["󰘳", "+", "V"], "action": "Clipboard history  >>  clipboard" },
	    { "keys": ["󰘳", "+", "󰘵", "+", "V"], "action": "Flycut  >> clipboard" },
	    { "keys": ["Ctrl", "+", "󰍜"], "action": "Snippets Menu" }, 
	    { "keys": ["󰘵", "+", "󰍜"], "action": "Add to Snippets Menu" }, 
	    { "keys": ["Ctrl", "󰘵", "+", "󰍜"], "action": "Delete from Snippets Menu" }, 
            { "keys": ["󰘳", "+", "."], "action": "Emoji picker  >>  clipboard" },
        ],
        "id": 7
    },
    {
        "icon": "terminal",
        "name": "Launcher actions",
        "binds": [
            { "keys": [">raw"], "action": "Toggle mouse acceleration" },
            { "keys": [">img"], "action": "Select wallpaper and generate colorscheme" },
            { "keys": [">light"], "action": "Switch to light theme" },
            { "keys": [">dark"], "action": "Switch to dark theme" },
            { "keys": [">color"], "action": "Pick acccent color" },
            { "keys": [">todo"], "action": "Type something after that to add a To-do item" },
        ],
        "appeartick": 3
    },
    {
	"icon": "gesture",
	"name": "Gestures",
	"binds": [
	    { "keys": ["󰪿", ">three fingers"], "action": "Change desktop" },
	    { "keys": ["󰝁", ">three fingers"], "action": "Move window" },
	    { "keys": ["󰜽", ">four fingers"], "action": "Open Spotlight" },
	    // { "keys": ["󰝀", ">four fingers"], "action": "Open App Wheel" },
	    { "keys": ["󰜿", ">four fingers"], "action": "Open Left Sidebar" },
	    { "keys": ["󰜾", ">four fingers"], "action": "Open Right Sidebar" },
	    { "keys": ["󰪽", ">four fingers"], "action": "Fullscreen/Minimize" },
	    { "keys": ["󰪾", ">four fingers"], "action": "Maximize/Minimize" },
	],
	"appeartick": 2
    }

]];
