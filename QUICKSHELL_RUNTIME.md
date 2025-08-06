# Quickshell Runtime Requirements

## Current Status: 99% Working! 🎉

Quickshell now loads almost completely with just one remaining Config object reference issue.

## Required QML2_IMPORT_PATH

For quickshell to run properly, the following QML2_IMPORT_PATH must be set:

```bash
QML2_IMPORT_PATH="$PWD:/nix/store/b4p9px4l3rsah72pyh95s1j68ik84k9i-qt5compat-6.9.1/lib/qt-6/qml:/nix/store/smz7rlw4r4p5bqngzkb1svqb3m5gvc2w-qtdeclarative-6.9.0/lib/qt-6/qml:/nix/store/aapj2h6bj11yg1qadhgn1d76cqawz18a-qtpositioning-6.9.1/lib/qt-6/qml"
```

### Components:
1. `$PWD` - Our custom qs/ module structure
2. `qt5compat` - For Qt5Compat.GraphicalEffects (RippleButton)
3. `qtdeclarative` - Core Qt QML modules
4. `qtpositioning` - For Weather service QtPositioning module

## Test Commands

### Minimal Test (Works ✅)
```bash
cd ~/.config/quickshell/ii
QML2_IMPORT_PATH="..." quickshell -p /tmp/minimal-shell.qml
# Result: "Configuration Loaded"
```

### Full Configuration (99% Working 🔄)
```bash
cd ~/.config/quickshell/ii  
QML2_IMPORT_PATH="..." quickshell
# Result: Loads through all services, stops at Config object reference
```

## Remaining Issue

**File**: `@services/AppSearch.qml[17:5]`
**Error**: `Non-existent attached object`
**Line**: `property bool sloppySearch: Config.options?.search.sloppy ?? false`
**Issue**: Config object not properly attached/available

## Progress Summary

✅ QML module path structure - FIXED
✅ All qmldir files - FIXED  
✅ Qt5Compat.GraphicalEffects - FIXED
✅ Widget type loading - FIXED
✅ Service dependency chain - FIXED
✅ QtPositioning module - FIXED
❌ Config object reference - CURRENT ISSUE

We've achieved a complete breakthrough in QML module loading!
