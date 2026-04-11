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
