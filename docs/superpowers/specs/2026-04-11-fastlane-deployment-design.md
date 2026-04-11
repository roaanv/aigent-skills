# Fastlane Deployment Skills — Design Specification

> Date: 2026-04-11
> Status: Draft
> Skills: `fastlane-setup`, `fastlane-deploy`

## Purpose

Two Claude Code skills that automate iOS and macOS app deployment using fastlane:

1. **`fastlane-setup`** — One-time project initialization: install fastlane, detect the project, configure code signing via `match`, and generate a Fastfile with beta/release lanes.
2. **`fastlane-deploy`** — Repeated build-and-deploy: build the app with `gym`, auto-increment the build number, and upload to TestFlight (beta) or App Store (release) via `pilot`/`deliver`.

## Non-Goals

- No Android builds — iOS and macOS only
- No CI/CD pipeline configuration — local execution only
- No screenshot automation (`snapshot`) — out of scope
- No App Store metadata management beyond what `deliver` handles inline
- No Swift Package Manager-only projects — requires `.xcodeproj` or `.xcworkspace`

## Platforms

Both iOS and macOS are supported. The skills auto-detect the platform from the Xcode project and adjust parameters accordingly (export method, build output format, destination).

| Aspect | iOS | macOS |
|--------|-----|-------|
| Build output | `.ipa` | `.pkg` or `.app` |
| Export method | `app-store` | `app-store` |
| TestFlight | Supported | Supported |
| Signing | Provisioning profiles required | Provisioning profiles required |

## Authentication

The skills support two Apple authentication methods, preferring the modern approach:

1. **App Store Connect API Key (preferred)** — A `.p8` file with Key ID and Issuer ID. No 2FA prompts, no session expiry. Detected via `APP_STORE_CONNECT_API_KEY_PATH` env var or a `.p8` file in the project.
2. **Apple ID + App-Specific Password (fallback)** — Traditional auth via `FASTLANE_USER` and `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` env vars.

The skills check for API Key first. If not found, check for Apple ID env vars. If neither exists, guide the user to create an API Key (preferred) with Apple ID as a fallback option.

## Automation Level

Both skills are **fully guided** — they execute commands directly via Bash. The user approves tool calls but does not need to type or run commands manually.

## Build Version Management

The deploy skill auto-increments `CFBundleVersion` before each build:

1. Fetch the latest build number from TestFlight (`latest_testflight_build_number`) or App Store (`app_store_build_number`)
2. Increment by 1
3. Set via `increment_build_number`
4. Report the change to the user

This prevents duplicate build number rejections.

---

## Skill 1: `fastlane-setup`

### Trigger

Used when the user asks to "set up fastlane", "configure fastlane", "initialize fastlane for deployment", "set up code signing", "configure TestFlight", or "prepare for App Store deployment".

### Allowed Tools

`Bash, Read, Write, Edit, Glob`

### Workflow

```
Detect project
    │
    ├── 1. Check prerequisites
    │   ├── Xcode and xcodebuild CLI installed?
    │   ├── Homebrew available?
    │   ├── fastlane installed? (brew install fastlane if not)
    │   └── Fail with explanation if Xcode is missing
    │
    ├── 2. Detect project type
    │   ├── Find .xcworkspace or .xcodeproj
    │   ├── Determine platform (iOS / macOS / both)
    │   ├── Extract available schemes (xcodebuild -list)
    │   ├── Extract bundle ID and team ID from project
    │   └── If ambiguous (multiple schemes/targets) → ask user to choose
    │
    ├── 3. Check for Apple credentials
    │   ├── Look for API Key (.p8 file or env vars)
    │   ├── If missing → check for Apple ID env vars
    │   ├── If nothing → guide user to create API Key
    │   │   (explain steps: App Store Connect → Users & Access → Keys)
    │   └── Verify credentials are set before proceeding
    │
    ├── 4. Initialize fastlane
    │   ├── Create fastlane/ directory
    │   ├── Generate Appfile (bundle ID, Apple ID/API key, team ID)
    │   └── Generate Fastfile with beta + release lanes
    │       ├── iOS template: match → gym → pilot/deliver
    │       └── macOS template: adjusted export method and destination
    │
    ├── 5. Configure code signing (match)
    │   ├── Ask user for certificate Git repo URL
    │   │   (or offer to create a new private repo)
    │   ├── Run match init (creates Matchfile)
    │   ├── Run match appstore (generate/download distribution certs + profiles)
    │   └── Run match development (for local testing profiles)
    │
    └── 6. Verify setup
        ├── Dry-run build to test signing configuration
        └── Report: setup complete, what was configured, next steps
```

### Error Handling

| Failure | Response |
|---------|----------|
| `fastlane/` directory already exists | Detect existing config, ask user: reconfigure or skip |
| `match` auth failure | Diagnose (expired key? wrong team?), guide credential fix |
| `match` Git repo access failure | Check SSH keys, suggest HTTPS alternative |
| Certificate generation failure | Check Apple Developer Program membership is active |
| Scheme/target detection failure | Fall back to asking user for values manually |

Retry cap: 2 attempts per step, then stop with explanation and actionable next steps.

### What This Skill Does NOT Do

- Does not build or deploy the app — that's `fastlane-deploy`
- Does not manage App Store metadata (screenshots, descriptions)
- Does not set up CI/CD pipelines

---

## Skill 2: `fastlane-deploy`

### Trigger

Used when the user asks to "deploy to TestFlight", "upload to TestFlight", "submit to App Store", "release the app", "push a beta build", "ship a build", or "deploy with fastlane".

### Allowed Tools

`Bash, Read, Glob`

### Workflow

```
Start
    │
    ├── 1. Preflight checks
    │   ├── fastlane installed?
    │   ├── fastlane/ directory exists with Appfile + Fastfile?
    │   │   └── If not → tell user to run fastlane-setup first
    │   ├── Signing configured? (Matchfile or manual profiles present)
    │   ├── Apple credentials available? (API key or Apple ID)
    │   └── Project compiles? (quick build check)
    │
    ├── 2. Determine deploy target
    │   ├── If user specified in their prompt → use that
    │   └── Otherwise → ask: "TestFlight (beta) or App Store (release)?"
    │
    ├── 3. Auto-increment build number
    │   ├── Fetch latest from TestFlight or App Store
    │   ├── Increment by 1
    │   ├── Set via increment_build_number
    │   └── Report: "Build number: N → N+1"
    │
    ├── 4. Sync code signing
    │   └── Run match appstore (both TestFlight and App Store use appstore type)
    │
    ├── 5. Build
    │   └── Run gym
    │       ├── Auto-detect workspace/project, scheme
    │       ├── export_method: "app-store"
    │       ├── Platform-specific destination
    │       └── Output: .ipa (iOS) or .pkg (macOS)
    │
    ├── 6. Upload
    │   ├── TestFlight path:
    │   │   ├── Run pilot (upload_to_testflight)
    │   │   ├── Wait for build processing
    │   │   ├── Set changelog (ask user, or default to recent git log summary)
    │   │   └── Distribute to internal testers (external groups require manual App Store Connect config)
    │   │
    │   └── App Store path:
    │       ├── Run deliver (upload_to_app_store)
    │       ├── Upload binary
    │       ├── Update metadata if user provides it
    │       └── Confirm with user before submitting for review
    │
    └── 7. Report
        ├── Success: build number, version, upload destination, link
        └── Failure: what went wrong, what was tried, next steps
```

### Error Handling (Diagnose-and-Retry)

The skill reads fastlane's error output and matches against known patterns:

| Error Pattern | Likely Cause | Auto-Fix | Retry? |
|---|---|---|---|
| `No matching provisioning profiles` | Stale profiles | Re-run `match --force` | Yes, once |
| `Duplicate build number` | Race condition or stale fetch | Fetch latest + increment again | Yes, once |
| `Could not find scheme` | Wrong scheme name | List schemes, ask user to pick | No (needs input) |
| `Code signing error` | Expired/revoked certificate | Offer `match nuke` + `match` (confirm first) | Yes, after confirm |
| `Connection reset / timeout` | Network issue | Wait 30s, retry | Yes, up to 2x |
| `App Store Connect API 403` | Invalid/expired API key | Guide user to regenerate | No (needs input) |
| `Invalid binary / Missing icons` | Project misconfiguration | Stop, explain what's missing | No |
| `Build failed` | Compilation error | Stop, show build errors | No (code problem) |

**Retry rules:**
- Transient errors (network, processing delays): auto-retry up to 2 times
- Fixable errors (stale profiles, duplicate build number): apply fix, retry once
- Code/config errors (build failure, missing icons): stop immediately, explain
- Destructive fixes (`match nuke`): always confirm with user before running

### What This Skill Does NOT Do

- Does not set up fastlane from scratch — directs user to `fastlane-setup`
- Does not automate screenshots via `snapshot`
- Does not handle Android builds
- Does not configure CI/CD pipelines

---

## File Structure

```
skills/
├── fastlane-setup/
│   ├── SKILL.md                    # Main workflow: detect → configure → verify
│   └── references/
│       ├── prerequisites.md        # Detection & installation checks
│       ├── project-detection.md    # Detecting platform, scheme, bundle ID from Xcode project
│       ├── fastfile-templates.md   # iOS + macOS Fastfile templates with beta/release lanes
│       └── signing-setup.md        # Match init, cert repo config, profile types
│
├── fastlane-deploy/
│   ├── SKILL.md                    # Main workflow: preflight → build → upload
│   └── references/
│       ├── preflight-checks.md     # Validation checklist before deploying
│       ├── error-diagnosis.md      # Error pattern → cause → fix mapping table
│       └── deploy-steps.md         # Detailed gym/pilot/deliver parameters
```

### Reference File Loading Strategy

- **`SKILL.md`** — Always loaded (the skill itself, ~150-200 lines)
- **Reference files** — Loaded at the relevant workflow step:
  - `prerequisites.md` → loaded during step 1 (prerequisite checks)
  - `project-detection.md` → loaded during step 2 (project detection)
  - `fastfile-templates.md` → loaded during step 4 (Fastfile generation)
  - `signing-setup.md` → loaded during step 5 (match configuration)
  - `preflight-checks.md` → loaded during step 1 (preflight)
  - `deploy-steps.md` → loaded during steps 4-6 (build and upload)
  - `error-diagnosis.md` → loaded only on failure (error recovery)

---

## Inspiration from greenstevester/fastlane-skill

The existing fastlane-skill plugin provided several useful patterns that informed this design:

- **Pre-flight checks** before running commands (prerequisite validation)
- **Platform detection** from `.pbxproj` files (improved here to use `xcodebuild -list`)
- **Fastfile templates** with configurable scheme/bundle ID (improved here with auto-detection instead of manual placeholders)
- **Separation of setup vs. execution** (kept as two skills)

Key improvements over the existing skill:
- Auto-detection of project values instead of manual template placeholders
- Fully guided execution (runs commands) instead of showing commands for the user to copy
- Structured error diagnosis with automatic retry for transient/fixable errors
- Build number auto-increment to prevent upload rejections
- API Key authentication as the preferred path (more reliable than Apple ID)
