plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {

    namespace = "com.example.test_app"

    compileSdk = 36

    ndkVersion = flutter.ndkVersion

    defaultConfig {

        applicationId = "com.example.test_app"

        minSdk = flutter.minSdkVersion

        targetSdk = 36

        versionCode = 1
        versionName = "1.0"

        multiDexEnabled = true
    }

    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {

        jvmTarget = "17"
    }

    buildTypes {

        release {

            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false
        }
    }

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

flutter {
    source = "../.."
}

dependencies {

    implementation("androidx.multidex:multidex:2.0.1")
}
