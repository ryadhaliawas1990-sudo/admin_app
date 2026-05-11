import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 🔐 تحميل معلومات التوقيع
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(
        FileInputStream(keystorePropertiesFile)
    )
}

android {

    namespace = "com.example.test_app"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // =========================
    // 🔥 Java / Kotlin
    // =========================

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // =========================
    // 📦 التطبيق
    // =========================

    defaultConfig {

        applicationId = "com.example.test_app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 🚀 دعم التطبيقات الكبيرة
        multiDexEnabled = true
    }

    // =========================
    // 🔐 توقيع التطبيق الرسمي
    // =========================

    signingConfigs {

        create("release") {

            keyAlias =
                keystoreProperties["keyAlias"] as String

            keyPassword =
                keystoreProperties["keyPassword"] as String

            storeFile = file(
                keystoreProperties["storeFile"] as String
            )

            storePassword =
                keystoreProperties["storePassword"] as String
        }
    }

    // =========================
    // 🚀 BUILD TYPES
    // =========================

    buildTypes {

        release {

            // 🔐 توقيع Release
            signingConfig =
                signingConfigs.getByName("release")

            // ⚡ تحسين الأداء
            isDebuggable = false

            // 📦 تقليل مشاكل البناء
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // =========================
    // 🔥 Packaging Fixes
    // =========================

    packaging {

        resources {

            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/AL2.0",
                "META-INF/LGPL2.1"
            )
        }
    }
}

// =========================
// 🟦 Flutter
// =========================

flutter {
    source = "../.."
}
