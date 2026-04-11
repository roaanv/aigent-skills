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
