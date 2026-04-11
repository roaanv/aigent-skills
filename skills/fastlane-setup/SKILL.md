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
