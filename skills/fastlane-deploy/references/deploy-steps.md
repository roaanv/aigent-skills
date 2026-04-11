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
