# Project Detection

## Procedure

Detect the Xcode project, platform, schemes, bundle ID, and team ID from the current
directory.

### 1. Find the Xcode Project

```bash
# Prefer .xcworkspace (used when CocoaPods or multiple projects are involved)
find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.build/*" ! -path "*/xcodeproj/*" ! -path "*/Pods/*" -type d 2>/dev/null

# Fall back to .xcodeproj
find . -maxdepth 2 -name "*.xcodeproj" -type d 2>/dev/null
```

- If multiple are found, ask the user to choose
- If none found, stop: "No Xcode project found in the current directory or one level below."
- Store the chosen path as `PROJECT_PATH`

### 2. List Schemes and Determine Platform

```bash
xcodebuild -list -workspace "PROJECT_PATH"
# or if using .xcodeproj:
xcodebuild -list -project "PROJECT_PATH"
```

This outputs available schemes, build configurations, and targets.

To determine the platform, check the scheme's destination:
```bash
xcodebuild -showdestinations -scheme "SCHEME_NAME" -workspace "PROJECT_PATH" 2>/dev/null | head -20
```

- If destinations include `platform:iOS Simulator` → iOS project
- If destinations include `platform:macOS` → macOS project
- If both → multi-platform project (ask user which to configure)

### 3. Extract Bundle Identifier

```bash
# From build settings (most reliable)
xcodebuild -showBuildSettings -scheme "SCHEME_NAME" -workspace "PROJECT_PATH" 2>/dev/null | grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1 | awk '{print $3}'
```

If the result contains `$(...)` variable substitution (common in modern Xcode projects),
fall back to reading the `.pbxproj` file:
```bash
grep -r "PRODUCT_BUNDLE_IDENTIFIER" "PROJECT_PATH" --include="*.pbxproj" | head -1 | sed 's/.*= //' | tr -d '";'
```

If still ambiguous, ask the user for their bundle ID.

### 4. Extract Team ID

```bash
xcodebuild -showBuildSettings -scheme "SCHEME_NAME" -workspace "PROJECT_PATH" 2>/dev/null | grep "DEVELOPMENT_TEAM" | head -1 | awk '{print $3}'
```

If empty or not found, check the `.pbxproj`:
```bash
grep -r "DEVELOPMENT_TEAM" "PROJECT_PATH" --include="*.pbxproj" | head -1 | sed 's/.*= //' | tr -d '";'
```

If still not found, ask the user for their team ID. They can find it at
https://developer.apple.com/account → Membership Details.

### 5. Summary

After detection, confirm with the user:
```
Detected project configuration:
  Project:   MyApp.xcworkspace
  Platform:  iOS
  Scheme:    MyApp
  Bundle ID: com.example.myapp
  Team ID:   ABCD123456

Proceed with these values? (or correct any that are wrong)
```
