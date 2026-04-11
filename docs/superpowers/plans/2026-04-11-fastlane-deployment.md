# Fastlane Deployment Skills — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two fastlane skills (`fastlane-setup` and `fastlane-deploy`) to the aigent-skills plugin for automating iOS/macOS App Store and TestFlight deployment.

**Architecture:** Each skill is a `SKILL.md` with YAML frontmatter and a `references/` subdirectory for detailed procedures. The main SKILL.md defines the workflow and decision points; reference files contain templates, error tables, and step-by-step procedures loaded on demand.

**Tech Stack:** Claude Code plugin skills (Markdown with YAML frontmatter), fastlane (Ruby-based iOS/macOS automation)

**Spec:** `docs/superpowers/specs/2026-04-11-fastlane-deployment-design.md`

---

## File Structure

```
skills/
├── fastlane-setup/
│   ├── SKILL.md                     # Main workflow (create)
│   └── references/
│       ├── prerequisites.md         # Prerequisite detection + install (create)
│       ├── project-detection.md     # Platform/scheme/bundle ID detection (create)
│       ├── fastfile-templates.md    # iOS + macOS Fastfile templates (create)
│       └── signing-setup.md         # Match configuration guide (create)
│
├── fastlane-deploy/
│   ├── SKILL.md                     # Main workflow (create)
│   └── references/
│       ├── preflight-checks.md      # Pre-deploy validation (create)
│       ├── error-diagnosis.md       # Error → cause → fix table (create)
│       └── deploy-steps.md          # gym/pilot/deliver parameters (create)
│
.claude-plugin/
├── plugin.json                      # Update description (modify)
└── marketplace.json                 # No change needed (source is ./)
```

---

## Task 1: Create `fastlane-setup` directory structure

**Files:**
- Create: `skills/fastlane-setup/SKILL.md`
- Create: `skills/fastlane-setup/references/` (directory)

- [ ] **Step 1: Create the SKILL.md file**

```markdown
---
name: Fastlane Setup
description: >
  This skill should be used when the user asks to "set up fastlane",
  "configure fastlane", "initialize fastlane for deployment",
  "set up code signing", "configure TestFlight",
  "prepare for App Store deployment", or wants to initialize
  fastlane for an iOS or macOS project. Handles fastlane
  installation, project detection, code signing via match,
  and Fastfile generation.
allowed-tools: Bash, Read, Write, Edit, Glob
---

# Fastlane Setup

One-time initialization of fastlane for an iOS or macOS project. After this skill
completes, the project will have a working fastlane configuration with beta (TestFlight)
and release (App Store) lanes, and code signing managed by match.

## What This Skill Does NOT Do

- Does not build or deploy the app — use `fastlane-deploy` for that
- Does not manage App Store metadata (screenshots, descriptions)
- Does not set up CI/CD pipelines
- Does not handle Android projects
- Does not support Swift Package Manager-only projects (requires .xcodeproj or .xcworkspace)

## Workflow

Follow these steps in order. If any step fails after 2 retry attempts, stop and explain
the issue with actionable next steps for the user.

### Step 1: Check Prerequisites

Read `references/prerequisites.md` and follow its procedures.

Check for:
1. Xcode and xcodebuild CLI tools
2. Homebrew
3. fastlane (install via `brew install fastlane` if missing)

If Xcode is not installed, stop — it cannot be installed automatically.

### Step 2: Detect Project

Read `references/project-detection.md` and follow its procedures.

Detect:
1. Find `.xcworkspace` or `.xcodeproj` in the current directory (prefer workspace)
2. Determine platform: iOS, macOS, or both (from `xcodebuild -list`)
3. Extract available schemes
4. Extract bundle identifier and team ID from the project
5. If multiple schemes or ambiguous values, ask the user to choose

### Step 3: Check Apple Credentials

Check for authentication in this order (prefer API Key):

1. **API Key:** Check for `APP_STORE_CONNECT_API_KEY_PATH` env var, or `APP_STORE_CONNECT_API_KEY_KEY_ID` + `APP_STORE_CONNECT_API_KEY_ISSUER_ID` + `APP_STORE_CONNECT_API_KEY_KEY` env vars
2. **Apple ID:** Check for `FASTLANE_USER` and `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` env vars

If neither is configured, guide the user:
- **Preferred:** Create an App Store Connect API Key
  - Go to App Store Connect → Users and Access → Integrations → App Store Connect API
  - Generate a key with "App Manager" or "Developer" role
  - Download the `.p8` file (only available once)
  - Set env vars: `APP_STORE_CONNECT_API_KEY_KEY_ID`, `APP_STORE_CONNECT_API_KEY_ISSUER_ID`, `APP_STORE_CONNECT_API_KEY_KEY_FILEPATH`
- **Fallback:** Use Apple ID + App-Specific Password
  - Go to account.apple.com → Sign-In and Security → App-Specific Passwords
  - Set: `FASTLANE_USER` and `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD`

Do not proceed until credentials are configured.

### Step 4: Initialize Fastlane

Read `references/fastfile-templates.md` for the Fastfile content.

1. Create the `fastlane/` directory if it does not exist
   - If it already exists, check for existing Appfile/Fastfile. Ask the user whether to
     reconfigure (overwrite) or skip this step.
2. Generate `fastlane/Appfile` with the detected values (bundle ID, team ID, credentials)
3. Generate `fastlane/Fastfile` using the appropriate platform template (iOS or macOS)
   with the detected scheme name

### Step 5: Configure Code Signing (match)

Read `references/signing-setup.md` for detailed match configuration procedures.

1. Ask the user for a private Git repository URL to store certificates
   - Explain: match encrypts and stores signing certificates in a Git repo so they're
     shared across machines and team members
   - If the user doesn't have one, suggest creating a new private repo (e.g., on GitHub)
2. Run `fastlane match init` to create the Matchfile
3. Run `fastlane match appstore` to generate/download App Store distribution certificates and profiles
4. Run `fastlane match development` to generate/download development certificates and profiles

### Step 6: Verify Setup

1. Run `fastlane lanes` to verify the lanes are recognized
2. Run a dry-run build: `fastlane run build_app scheme:"SCHEME" skip_archive:true` to verify
   signing is configured correctly
3. Report to the user:
   - What was configured (Appfile, Fastfile, Matchfile)
   - Available lanes (beta, release)
   - Next step: "Use fastlane-deploy to build and upload your app"
```

- [ ] **Step 2: Verify file was created**

Run: `ls -la skills/fastlane-setup/SKILL.md`
Expected: File exists

- [ ] **Step 3: Create the references directory**

Run: `mkdir -p skills/fastlane-setup/references`

- [ ] **Step 4: Commit**

```bash
git add skills/fastlane-setup/SKILL.md
git commit -m "feat: add fastlane-setup skill with main workflow"
```

---

## Task 2: Create `fastlane-setup` reference files

**Files:**
- Create: `skills/fastlane-setup/references/prerequisites.md`
- Create: `skills/fastlane-setup/references/project-detection.md`
- Create: `skills/fastlane-setup/references/fastfile-templates.md`
- Create: `skills/fastlane-setup/references/signing-setup.md`

- [ ] **Step 1: Create prerequisites.md**

```markdown
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
```

- [ ] **Step 2: Create project-detection.md**

```markdown
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
```

- [ ] **Step 3: Create fastfile-templates.md**

```markdown
# Fastfile Templates

## Appfile Template

Generate this file at `fastlane/Appfile` with detected values:

### With API Key Authentication

```ruby
app_identifier("{BUNDLE_ID}")
team_id("{TEAM_ID}")

# API Key authentication is configured via environment variables:
# APP_STORE_CONNECT_API_KEY_KEY_ID
# APP_STORE_CONNECT_API_KEY_ISSUER_ID
# APP_STORE_CONNECT_API_KEY_KEY_FILEPATH (or APP_STORE_CONNECT_API_KEY_KEY)
```

### With Apple ID Authentication

```ruby
app_identifier("{BUNDLE_ID}")
apple_id("{APPLE_ID}")
team_id("{TEAM_ID}")
```

## iOS Fastfile Template

Generate this file at `fastlane/Fastfile`:

```ruby
default_platform(:ios)

platform :ios do
  before_all do
    setup_ci if ENV['CI']
  end

  desc "Sync code signing certificates"
  private_lane :sync_certs do |options|
    type = options[:type] || "appstore"
    match(type: type, readonly: is_ci)
  end

  desc "Build and upload to TestFlight"
  lane :beta do |options|
    sync_certs(type: "appstore")

    current = latest_testflight_build_number(
      app_identifier: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
    )
    increment_build_number(build_number: current + 1)

    build_app(
      scheme: "{SCHEME}",
      export_method: "app-store",
      clean: true
    )

    changelog = options[:changelog] || changelog_from_git_commits(
      commits_count: 10,
      pretty: "- %s"
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: false,
      changelog: changelog,
      distribute_external: false
    )
  end

  desc "Build and submit to App Store"
  lane :release do |options|
    sync_certs(type: "appstore")

    current = app_store_build_number(
      app_identifier: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
    )
    increment_build_number(build_number: current + 1)

    build_app(
      scheme: "{SCHEME}",
      export_method: "app-store",
      clean: true
    )

    upload_to_app_store(
      force: true,
      submit_for_review: options[:submit] || false,
      automatic_release: false,
      skip_metadata: options[:skip_metadata] || false,
      skip_screenshots: true
    )
  end

  error do |lane, exception|
    # Error handling — the skill's error diagnosis will handle this
    UI.error("Lane #{lane} failed: #{exception.message}")
  end
end
```

## macOS Fastfile Template

Generate this file at `fastlane/Fastfile`:

```ruby
default_platform(:mac)

platform :mac do
  before_all do
    setup_ci if ENV['CI']
  end

  desc "Sync code signing certificates"
  private_lane :sync_certs do |options|
    type = options[:type] || "appstore"
    match(type: type, platform: "macos", readonly: is_ci)
  end

  desc "Build and upload to TestFlight"
  lane :beta do |options|
    sync_certs(type: "appstore")

    current = latest_testflight_build_number(
      app_identifier: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
      platform: "osx"
    )
    increment_build_number(build_number: current + 1)

    build_app(
      scheme: "{SCHEME}",
      export_method: "app-store",
      clean: true
    )

    changelog = options[:changelog] || changelog_from_git_commits(
      commits_count: 10,
      pretty: "- %s"
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: false,
      changelog: changelog,
      distribute_external: false,
      app_platform: "osx"
    )
  end

  desc "Build and submit to App Store"
  lane :release do |options|
    sync_certs(type: "appstore")

    current = app_store_build_number(
      app_identifier: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
      platform: "osx"
    )
    increment_build_number(build_number: current + 1)

    build_app(
      scheme: "{SCHEME}",
      export_method: "app-store",
      clean: true
    )

    upload_to_app_store(
      force: true,
      submit_for_review: options[:submit] || false,
      automatic_release: false,
      skip_metadata: options[:skip_metadata] || false,
      skip_screenshots: true
    )
  end

  error do |lane, exception|
    UI.error("Lane #{lane} failed: #{exception.message}")
  end
end
```

## Key Differences Between iOS and macOS Templates

| Parameter | iOS | macOS |
|-----------|-----|-------|
| `default_platform` | `:ios` | `:mac` |
| `match platform` | (default, iOS) | `"macos"` |
| `testflight_build_number platform` | (default) | `"osx"` |
| `upload_to_testflight app_platform` | (default) | `"osx"` |
| `app_store_build_number platform` | (default) | `"osx"` |

All other parameters are identical. The templates use `{SCHEME}` and `{BUNDLE_ID}`
as placeholders — replace these with the auto-detected values during generation.
Do NOT leave placeholders in the generated files.
```

- [ ] **Step 4: Create signing-setup.md**

```markdown
# Code Signing Setup with Match

## Overview

Match (sync_code_signing) is fastlane's approach to iOS/macOS code signing. It stores
certificates and provisioning profiles in a shared Git repository (encrypted), so all
team members and CI systems use the same signing identity.

## Procedure

### 1. Get Certificate Repository URL

Ask the user: "Match stores encrypted certificates in a private Git repository.
Do you have one, or should I help you set one up?"

- **User has a repo:** Use their URL (HTTPS or SSH)
- **User needs one:** Suggest creating a private GitHub repo:
  - Name suggestion: `{project-name}-certificates` or `ios-certificates`
  - Must be private — it will contain encrypted signing material
  - The user must create this manually (GitHub/GitLab/Bitbucket)
  - Wait for the URL before continuing

### 2. Initialize Match

```bash
fastlane match init
```

This creates `fastlane/Matchfile`. If it asks for the Git URL interactively,
provide it. Alternatively, write the Matchfile directly:

```ruby
git_url("{CERTIFICATE_REPO_URL}")
storage_mode("git")
type("appstore")
app_identifier(["{BUNDLE_ID}"])
```

### 3. Generate App Store Distribution Certificates

```bash
fastlane match appstore
```

This will:
- Connect to Apple Developer Portal
- Create (or download existing) distribution certificate
- Create (or download existing) App Store provisioning profile
- Encrypt and push to the Git repository
- Install locally in the keychain

**First run:** Match will ask for a passphrase to encrypt the repo. The user
should choose a strong passphrase and store it securely. This passphrase is
needed on every new machine or CI system.

Set the passphrase as env var for non-interactive use:
`MATCH_PASSWORD="passphrase"`

### 4. Generate Development Certificates

```bash
fastlane match development
```

Same process, but for development signing (local testing on devices).

### 5. Verify Signing

After match completes, verify the certificates are installed:

```bash
security find-identity -v -p codesigning
```

This should show the distribution and development certificates.

## Error Handling

| Error | Cause | Fix |
|-------|-------|-----|
| `Could not create another Distribution certificate` | Max certificates reached (Apple limits to 3) | Run `fastlane match nuke distribution` (with user confirmation!) then re-run match |
| `Authentication failed` | Wrong credentials | Check API key or Apple ID credentials |
| `Could not clone Git repo` | Wrong URL or no access | Verify URL, check SSH keys or HTTPS credentials |
| `Passphrase did not match` | Wrong MATCH_PASSWORD | Ask user for correct passphrase |
| `Provisioning profile not found` | Bundle ID mismatch | Verify bundle ID matches Apple Developer Portal |

## Readonly Mode

After initial setup, match should run in readonly mode during builds to avoid
accidentally creating new certificates:

```ruby
match(type: "appstore", readonly: true)
```

The Fastfile templates already include `readonly: is_ci` which enables readonly
mode in CI environments. For local builds via the deploy skill, match runs in
read-write mode to ensure profiles are current.
```

- [ ] **Step 5: Verify all reference files exist**

Run: `ls -la skills/fastlane-setup/references/`
Expected: Four files — `prerequisites.md`, `project-detection.md`, `fastfile-templates.md`, `signing-setup.md`

- [ ] **Step 6: Commit**

```bash
git add skills/fastlane-setup/references/
git commit -m "feat: add fastlane-setup reference files (prerequisites, detection, templates, signing)"
```

---

## Task 3: Create `fastlane-deploy` SKILL.md

**Files:**
- Create: `skills/fastlane-deploy/SKILL.md`
- Create: `skills/fastlane-deploy/references/` (directory)

- [ ] **Step 1: Create the SKILL.md file**

```markdown
---
name: Fastlane Deploy
description: >
  This skill should be used when the user asks to "deploy to TestFlight",
  "upload to TestFlight", "submit to App Store", "release the app",
  "push a beta build", "ship a build", "deploy with fastlane", or
  wants to build and upload an iOS or macOS app. Builds the app,
  auto-increments the build number, and uploads to TestFlight (beta)
  or App Store (release) using fastlane.
allowed-tools: Bash, Read, Glob
---

# Fastlane Deploy

Build and deploy an iOS or macOS app to TestFlight (beta testing) or the App Store
(production release). This skill runs the full pipeline: preflight checks, build number
increment, code signing sync, build, and upload.

## What This Skill Does NOT Do

- Does not set up fastlane — if fastlane is not configured, directs user to `fastlane-setup`
- Does not automate screenshots
- Does not handle Android builds
- Does not configure CI/CD pipelines

## Workflow

Follow these steps in order. On failure, read `references/error-diagnosis.md` for
diagnosis and retry procedures.

### Step 1: Preflight Checks

Read `references/preflight-checks.md` and follow its procedures.

Verify:
1. fastlane is installed
2. `fastlane/` directory exists with Appfile and Fastfile
3. Code signing is configured (Matchfile exists, or manual profiles present)
4. Apple credentials are available (API key or Apple ID env vars)

If any check fails, stop and guide the user. If fastlane is not set up at all,
tell them: "Fastlane is not configured for this project. Use the fastlane-setup
skill to initialize it first."

### Step 2: Determine Deploy Target

Check if the user specified a target in their prompt:
- Words like "TestFlight", "beta", "test build" → TestFlight
- Words like "App Store", "release", "production", "submit for review" → App Store

If unclear, ask: "Where should this build go?"
- **TestFlight** — Upload for beta testing (internal testers notified automatically)
- **App Store** — Submit for production release (review required)

### Step 3: Run the Deploy

Read `references/deploy-steps.md` for detailed parameter guidance.

Run the appropriate fastlane lane:

**For TestFlight:**
```bash
fastlane beta
```

Or with a custom changelog:
```bash
fastlane beta changelog:"CHANGELOG_TEXT"
```

If the user hasn't provided changelog text, ask if they want to:
- Use recent git commits as the changelog (default)
- Provide custom text
- Skip the changelog

**For App Store:**
```bash
fastlane release
```

Before running the release lane, confirm with the user:
"This will upload a new build to App Store Connect. The Fastfile is configured NOT to
auto-submit for review — you can do that manually in App Store Connect, or I can run
with `submit:true` if you want. Proceed?"

### Step 4: Handle Errors

If the fastlane command fails:

1. Read `references/error-diagnosis.md`
2. Match the error output against known patterns
3. Apply the recommended fix
4. Retry (up to 2 times for transient errors, once for fixable errors)
5. If still failing, stop and report:
   - What command was run
   - What error occurred
   - What was tried to fix it
   - Actionable next steps for the user

### Step 5: Report Results

On success, report:
- Deploy target (TestFlight or App Store)
- App version (CFBundleShortVersionString)
- Build number (CFBundleVersion, after increment)
- Upload status

For TestFlight: "Build uploaded and processing. Internal testers will be notified
automatically once processing completes (usually 5-30 minutes)."

For App Store: "Build uploaded to App Store Connect. You can submit for review
from App Store Connect, or re-run this skill with submit enabled."
```

- [ ] **Step 2: Create the references directory**

Run: `mkdir -p skills/fastlane-deploy/references`

- [ ] **Step 3: Commit**

```bash
git add skills/fastlane-deploy/SKILL.md
git commit -m "feat: add fastlane-deploy skill with main workflow"
```

---

## Task 4: Create `fastlane-deploy` reference files

**Files:**
- Create: `skills/fastlane-deploy/references/preflight-checks.md`
- Create: `skills/fastlane-deploy/references/error-diagnosis.md`
- Create: `skills/fastlane-deploy/references/deploy-steps.md`

- [ ] **Step 1: Create preflight-checks.md**

```markdown
# Preflight Checks

## Procedure

Run each check before attempting a deploy. All must pass.

### 1. Fastlane Installed

```bash
fastlane --version
```

- **Success:** Shows version number
- **Failure:** "Fastlane is not installed. Run `brew install fastlane` or use the
  fastlane-setup skill."

### 2. Fastlane Directory Exists

```bash
ls fastlane/Appfile fastlane/Fastfile
```

- **Success:** Both files exist
- **Failure:** "Fastlane is not configured for this project. Use the fastlane-setup
  skill to initialize it."

### 3. Lanes Available

```bash
fastlane lanes
```

- **Success:** Shows `beta` and `release` lanes
- **Failure:** The Fastfile may be malformed or missing the expected lanes. Check
  `fastlane/Fastfile` and verify it contains `lane :beta` and `lane :release`.

### 4. Code Signing

Check for match configuration:
```bash
ls fastlane/Matchfile 2>/dev/null
```

- **Present:** Match is configured — the lane will handle cert syncing
- **Missing:** Check if manual signing profiles are available:
  ```bash
  security find-identity -v -p codesigning | head -5
  ```
  If no valid identities, warn: "No code signing is configured. Use fastlane-setup
  to set up match, or configure signing manually in Xcode."

### 5. Apple Credentials

Check in order of preference:

```bash
# API Key (preferred)
echo "API Key path: ${APP_STORE_CONNECT_API_KEY_KEY_FILEPATH:-not set}"
echo "API Key ID: ${APP_STORE_CONNECT_API_KEY_KEY_ID:-not set}"
echo "API Issuer: ${APP_STORE_CONNECT_API_KEY_ISSUER_ID:-not set}"
```

```bash
# Apple ID (fallback)
echo "Apple ID: ${FASTLANE_USER:-not set}"
echo "App-specific password: ${FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD:+set}"
```

- **API Key configured:** Proceed (best path)
- **Apple ID configured:** Proceed with warning about potential 2FA prompts
- **Neither:** Stop. Guide user to set up credentials (see fastlane-setup Step 3)
```

- [ ] **Step 2: Create error-diagnosis.md**

```markdown
# Error Diagnosis and Recovery

## How to Use This File

When a fastlane command fails, read the error output and match it against the patterns
below. Apply the recommended fix and retry according to the retry rules.

## Retry Rules

- **Transient errors** (network, Apple API delays): auto-retry up to 2 times with 30s delay
- **Fixable errors** (stale profiles, duplicate build number): apply fix, retry once
- **Code/config errors** (build failure, missing icons): stop immediately, explain to user
- **Destructive fixes** (`match nuke`): always confirm with user before running

## Error Patterns

### Code Signing Errors

| Error Pattern | Cause | Fix | Retry? |
|---|---|---|---|
| `No matching provisioning profiles found` | Profiles not installed or expired | Run `fastlane match appstore --force` | Yes, once |
| `No signing certificate .* is found` | Certificate not in keychain | Run `fastlane match appstore` to re-download | Yes, once |
| `Code signing is required for product type` | Signing not configured at all | Stop — user needs to run fastlane-setup | No |
| `Provisioning profile .* doesn't match` | Bundle ID mismatch between project and profile | Check Appfile bundle ID matches Xcode project | No (needs input) |
| `Could not create another .* certificate` | Apple's certificate limit reached | Offer `fastlane match nuke distribution` then `fastlane match appstore` — **confirm with user first** | Yes, after confirm |
| `Your certificate .* has been revoked` | Certificate was revoked in Apple Developer Portal | Run `fastlane match appstore --force` to generate new | Yes, once |

### Build Errors

| Error Pattern | Cause | Fix | Retry? |
|---|---|---|---|
| `xcodebuild: error:` followed by compilation errors | Code does not compile | Stop — show the build errors. This is a code problem, not a deployment problem | No |
| `Could not find a scheme named` | Wrong scheme name in Fastfile | Run `xcodebuild -list` to show available schemes, ask user to pick | No (needs input) |
| `Signing for .* requires a development team` | Team ID not set | Check Appfile for `team_id`, ask user if missing | No (needs input) |
| `error: Signing requires a provisioning profile` | Export method mismatch | Verify `export_method: "app-store"` in Fastfile | No (needs input) |

### Upload Errors

| Error Pattern | Cause | Fix | Retry? |
|---|---|---|---|
| `The build number has already been used` or `ERROR ITMS-4238` | Duplicate CFBundleVersion | Fetch latest build number again, increment, rebuild and re-upload | Yes, once |
| `Connection reset by peer` or `NSURLErrorDomain` | Network timeout | Wait 30s, retry | Yes, up to 2x |
| `Could not find an ipa file` | Gym didn't produce output | Check gym output for errors, verify scheme and export method | No |
| `Unable to upload archive` or transporter error | Apple API issue | Wait 30s, retry | Yes, up to 2x |
| `Forbidden` or `403` from App Store Connect API | Invalid or expired API key | Guide user to check/regenerate API key | No (needs input) |
| `This bundle is invalid` | Missing required assets (icons, launch screen) | Stop — list what's missing from the error. User must fix their Xcode project | No |
| `The app references non-public selectors` | Private API usage | Stop — list the flagged APIs. User must remove private API calls | No |

### Authentication Errors

| Error Pattern | Cause | Fix | Retry? |
|---|---|---|---|
| `Your session has expired` or `Need to acknowledge` | Apple session expired | For API Key: should not happen. For Apple ID: re-authenticate | No (needs input) |
| `Please sign in with an app-specific password` | Missing app-specific password | Guide: account.apple.com → Sign-In and Security → App-Specific Passwords | No (needs input) |
| `Invalid credentials` | Wrong Apple ID or password | Verify credentials, re-enter | No (needs input) |
| `Insufficient permissions` | API key role too restrictive | Guide: API key needs "App Manager" or "Admin" role | No (needs input) |

## Recovery Procedure

1. Read the full error output from fastlane
2. Find the matching pattern in the tables above
3. If the fix is automatic:
   a. Apply the fix
   b. Re-run the failed command
   c. If it fails again with the same error, stop and report
4. If the fix needs user input:
   a. Explain what went wrong (plain language, not just the error text)
   b. Explain what the user needs to do
   c. Wait for them to fix it, then retry
5. If no pattern matches:
   a. Show the full error output
   b. Suggest checking fastlane's GitHub issues or documentation
   c. Stop
```

- [ ] **Step 3: Create deploy-steps.md**

```markdown
# Deploy Steps — Detailed Parameters

## Build Number Increment

The Fastfile templates handle build number increment automatically within the lane.
The flow is:

1. **Fetch current latest:**
   - TestFlight: `latest_testflight_build_number` returns the highest build number in TestFlight
   - App Store: `app_store_build_number` returns the highest build number on the App Store
2. **Increment:** `increment_build_number(build_number: current + 1)`
3. **Build** with the new number

If using the Fastfile templates from fastlane-setup, this is already built into
both the `beta` and `release` lanes. No manual step is needed.

## Building with Gym

The `build_app` (gym) action in the Fastfile templates uses these parameters:

| Parameter | Value | Why |
|-----------|-------|-----|
| `scheme` | Auto-detected scheme name | Must match an Xcode scheme |
| `export_method` | `"app-store"` | Required for TestFlight and App Store distribution |
| `clean` | `true` | Clean build to avoid stale artifacts |

### Platform-Specific Notes

**iOS:**
- Gym automatically detects the workspace/project
- Output: `.ipa` file in the fastlane output directory
- dSYM file is also generated for crash symbolication

**macOS:**
- Gym produces a `.pkg` file for App Store distribution
- The `platform: "macos"` is set in the Fastfile template via `default_platform(:mac)`
- Some macOS apps may need additional entitlements (e.g., App Sandbox)

## Uploading to TestFlight (pilot)

The `upload_to_testflight` (pilot) action parameters:

| Parameter | Value | Why |
|-----------|-------|-----|
| `skip_waiting_for_build_processing` | `false` | Wait for Apple to process the build so we can confirm success |
| `changelog` | Git commits or user-provided | Shown to testers in TestFlight |
| `distribute_external` | `false` | Internal testers only (external requires compliance review) |
| `app_platform` | `"osx"` for macOS, omit for iOS | Tells TestFlight which platform |

### Changelog Options

The lane accepts a `changelog` option. If not provided, it auto-generates from
the last 10 git commits. The skill should ask the user:

- "Use recent git commits as changelog?" (default, usually fine for internal testing)
- "Provide custom changelog text?"
- "Skip changelog?"

### Processing Time

After upload, Apple processes the build:
- Typical time: 5-30 minutes
- The command waits for processing by default
- If processing takes too long (>30 minutes), it may time out — this is not an error,
  the build is still processing. The user can check App Store Connect.

## Uploading to App Store (deliver)

The `upload_to_app_store` (deliver) action parameters:

| Parameter | Value | Why |
|-----------|-------|-----|
| `force` | `true` | Skip HTML preview of metadata |
| `submit_for_review` | `false` (default) | Do not auto-submit — let user review in App Store Connect |
| `automatic_release` | `false` | After approval, do not auto-release — let user control timing |
| `skip_metadata` | configurable | Skip metadata upload if user only wants to upload binary |
| `skip_screenshots` | `true` | Screenshots managed separately |

### Submit for Review

The Fastfile template defaults to NOT submitting for review. The skill should confirm
with the user before enabling this:

"The build has been uploaded. Would you like to submit it for Apple's review now?
(You can also do this manually in App Store Connect.)"

If yes, re-run with `submit:true`:
```bash
fastlane release submit:true
```

### Required Before First Submission

The very first App Store submission requires some metadata to be set in App Store Connect:
- App description
- Category
- Screenshots (at least for required device sizes)
- Privacy policy URL
- Age rating

If this is the first submission and deliver fails because of missing metadata, explain
this to the user and suggest they complete the listing in App Store Connect first.
```

- [ ] **Step 4: Verify all reference files exist**

Run: `ls -la skills/fastlane-deploy/references/`
Expected: Three files — `preflight-checks.md`, `error-diagnosis.md`, `deploy-steps.md`

- [ ] **Step 5: Commit**

```bash
git add skills/fastlane-deploy/references/
git commit -m "feat: add fastlane-deploy reference files (preflight, error diagnosis, deploy steps)"
```

---

## Task 5: Update plugin.json description

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: Read current plugin.json**

Current content:
```json
{
  "name": "aigent-skills",
  "version": "0.1.0",
  "description": "Personal collection of Claude Code skills for architectural analysis and learning",
  "author": {
    "name": "roaanv"
  }
}
```

- [ ] **Step 2: Update the description to reflect new skills**

```json
{
  "name": "aigent-skills",
  "version": "0.2.0",
  "description": "Personal collection of Claude Code skills for architectural analysis, learning, and iOS/macOS deployment",
  "author": {
    "name": "roaanv"
  }
}
```

- [ ] **Step 3: Update marketplace.json version to match**

```json
{
  "name": "aigent-skills-marketplace",
  "owner": {
    "name": "roaanv"
  },
  "plugins": [
    {
      "name": "aigent-skills",
      "version": "0.2.0",
      "description": "Personal collection of Claude Code skills for architectural analysis, learning, and iOS/macOS deployment",
      "source": "./"
    }
  ]
}
```

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to 0.2.0, update description for fastlane skills"
```

---

## Task 6: Verify skills are loadable

**Files:** None (verification only)

- [ ] **Step 1: Verify file structure**

Run: `find skills/fastlane-setup skills/fastlane-deploy -type f | sort`

Expected:
```
skills/fastlane-deploy/SKILL.md
skills/fastlane-deploy/references/deploy-steps.md
skills/fastlane-deploy/references/error-diagnosis.md
skills/fastlane-deploy/references/preflight-checks.md
skills/fastlane-setup/SKILL.md
skills/fastlane-setup/references/fastfile-templates.md
skills/fastlane-setup/references/prerequisites.md
skills/fastlane-setup/references/project-detection.md
skills/fastlane-setup/references/signing-setup.md
```

- [ ] **Step 2: Verify SKILL.md frontmatter is valid YAML**

Run: `head -15 skills/fastlane-setup/SKILL.md && echo "---" && head -15 skills/fastlane-deploy/SKILL.md`

Expected: Both files start with `---`, have `name`, `description`, and `allowed-tools` fields, and end with `---`.

- [ ] **Step 3: Verify no template placeholders remain in SKILL.md files**

Run: `grep -r '{{' skills/fastlane-setup/SKILL.md skills/fastlane-deploy/SKILL.md`

Expected: No matches. (Template placeholders like `{SCHEME}` in reference files are intentional — they're replaced during generation. But the SKILL.md files themselves should have no placeholders.)

- [ ] **Step 4: Test with Claude Code**

Run the plugin locally to verify skill discovery:
```bash
claude --plugin-dir /Users/roaanv/mycode/aigent-skills --print "list available skills"
```

Expected: Both `Fastlane Setup` and `Fastlane Deploy` appear in the skill list.

- [ ] **Step 5: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: address verification issues in fastlane skills"
```

Only run this if Step 4 revealed issues that needed fixing.
