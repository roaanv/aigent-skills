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
