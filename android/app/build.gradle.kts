import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is opt-in: drop an android/key.properties (git-ignored) with
// storeFile/storePassword/keyAlias/keyPassword and release builds are signed
// with it. Without it we fall back to the debug key so `flutter run --release`
// still works for anyone building from source. See README > Signing a release.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null
// FCM has no baked-in google-services.json: Firebase is initialised at runtime
// with options the app fetches from the GLPI plugin, so a single published app
// works against each self-hosted instance's own Firebase project.

android {
    namespace = "com.tankerkiller125.glpi"
    // flutter_secure_storage 11 compiles against SDK 37 (flutter.compileSdkVersion is 36).
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications requires core library desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.tankerkiller125.glpi"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Debug key when no keystore is configured, so building from source
            // works out of the box; a debug-signed APK cannot be upgraded in
            // place from a properly signed one, so configure key.properties
            // before publishing anything users will update.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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

// The UnifiedPush/webcrypto stack pulls the JVM `tink` while other deps pull
// `tink-android`, causing duplicate classes. Keep the Android variant.
configurations.all {
    exclude(group = "com.google.crypto.tink", module = "tink")
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
