import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.homefix"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.homefix"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val signingProperties = Properties()
    val signingPropertiesFile = rootProject.file("key.properties")
    if (signingPropertiesFile.exists()) {
        signingPropertiesFile.inputStream().use { signingProperties.load(it) }
    }

    fun signingValue(propertyName: String, environmentName: String): String? =
        System.getenv(environmentName)?.takeIf { it.isNotBlank() }
            ?: signingProperties.getProperty(propertyName)?.takeIf { it.isNotBlank() }

    val releaseStoreFile = signingValue("storeFile", "HOMEFIX_KEYSTORE_PATH")
    val releaseStorePassword = signingValue("storePassword", "HOMEFIX_KEYSTORE_PASSWORD")
    val releaseKeyAlias = signingValue("keyAlias", "HOMEFIX_KEY_ALIAS")
    val releaseKeyPassword = signingValue("keyPassword", "HOMEFIX_KEY_PASSWORD")

    signingConfigs {
        create("release") {
            if (releaseStoreFile != null && releaseStorePassword != null &&
                releaseKeyAlias != null && releaseKeyPassword != null) {
                storeFile = file(releaseStoreFile)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (releaseStoreFile == null || releaseStorePassword == null ||
                releaseKeyAlias == null || releaseKeyPassword == null) {
                throw GradleException(
                    "Release signing is not configured. Set HOMEFIX_KEYSTORE_PATH, " +
                        "HOMEFIX_KEYSTORE_PASSWORD, HOMEFIX_KEY_ALIAS and HOMEFIX_KEY_PASSWORD, " +
                        "or provide android/key.properties locally."
                )
            }
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
