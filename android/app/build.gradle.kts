plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.test_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.test_app"

        minSdk = 21
        targetSdk = flutter.targetSdkVersion

        versionCode = 1
        versionName = "1.0"

        multiDexEnabled = true
    }

    buildTypes {
        release {
            // 🔥 أهم نقطة: بدون signing خارجي = تجنب الخطأ
            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false
        }
    }
}

flutter {
    source = "../.."
}
