# Prerequisites Check

## Procedure

Run each check in order. If a prerequisite is missing, attempt to install it.
If installation fails, stop and report the issue.

### 1. Xcode

```bash
xcode-select -p
```

- **Success:** Path to Xcode (e.g., `/Applications/Xcode.app/Contents/Developer`)
- **Failure:** Xcode is not installed. Tell the user:
  "Xcode is required but not installed. Install it from the Mac App Store, then run
  `xcode-select --install` to install command line tools. Re-run this skill after."
  Stop — do not continue.

### 2. Xcode Command Line Tools

```bash
xcodebuild -version
```

- **Success:** Shows Xcode version and build number
- **Failure:** Run `xcode-select --install` and wait for installation. Retry once.

### 3. Homebrew

```bash
brew --version
```

- **Success:** Shows Homebrew version
- **Failure:** Tell the user:
  "Homebrew is recommended for installing fastlane. Install it from https://brew.sh
  or run: `/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"`"
  After installation, retry once.

### 4. Fastlane

```bash
fastlane --version
```

- **Success:** Shows fastlane version (e.g., `fastlane 2.x.x`)
- **Failure:** Install via Homebrew:

```bash
brew install fastlane
```

Verify after installation:
```bash
fastlane --version
```

If still failing, check PATH and suggest the user restart their terminal.

## Why Homebrew for Fastlane

Fastlane is a Ruby gem, but installing via `gem install fastlane` frequently causes
version conflicts with system Ruby or Bundler. Homebrew manages its own Ruby and
avoids these issues entirely.
