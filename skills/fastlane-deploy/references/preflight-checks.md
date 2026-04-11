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
