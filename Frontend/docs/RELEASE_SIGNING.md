# Android release signing

The release build no longer uses the Android debug keystore.

## Local configuration

Create `Frontend/android/key.properties` locally (this file is ignored by Git):

```properties
storeFile=/absolute/path/to/homefix-release.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=homefix
keyPassword=YOUR_KEY_PASSWORD
```

Then run:

```bash
cd Frontend
flutter pub get
flutter build apk --release
```

You can also provide the same values through environment variables instead of `key.properties`:

```text
HOMEFIX_KEYSTORE_PATH
HOMEFIX_KEYSTORE_PASSWORD
HOMEFIX_KEY_ALIAS
HOMEFIX_KEY_PASSWORD
```

Environment variables take precedence over `key.properties`.

## CI

Store the real keystore and passwords in the CI secret store. Do not commit the keystore or passwords to Git.

The release Gradle configuration requires all four signing values and fails closed when they are absent. CI may use a short-lived CI-only keystore generated during the workflow solely to validate that the release artifact is actually signed. A production/release deployment must use the real signing secrets.
