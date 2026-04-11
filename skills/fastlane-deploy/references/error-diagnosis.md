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
