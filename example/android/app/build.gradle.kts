import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.kqed.jwplayer.jwplayer_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kqed.jwplayer.jwplayer_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName

        minSdk = 26
        multiDexEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

extra["exoplayerVersion"] = "1.1.1"
val exoplayerVersion: String by extra

dependencies {
    // JWP SDK classes
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("jwplayer-core-x.x.x.aar"))))
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("jwplayer-common:x-x.x.x.aar"))))

    // ExoPlayer dependencies
    implementation("androidx.media3:media3-common:$exoplayerVersion")
    implementation("androidx.media3:media3-extractor:$exoplayerVersion")
    implementation("androidx.media3:media3-exoplayer:$exoplayerVersion")
    implementation("androidx.media3:media3-exoplayer-dash:$exoplayerVersion")
    implementation("androidx.media3:media3-exoplayer-hls:$exoplayerVersion")
    implementation("androidx.media3:media3-exoplayer-smoothstreaming:$exoplayerVersion")
    implementation("androidx.media3:media3-ui:$exoplayerVersion")

    // JWP Native UI dependencies
    implementation("com.squareup.picasso:picasso:2.71828")
    implementation("androidx.viewpager2:viewpager2:1.0.0")
    implementation("com.android.volley:volley:1.2.0")
    implementation("androidx.recyclerview:recyclerview:1.2.1")
    implementation("androidx.appcompat:appcompat:1.3.1")
    implementation("com.google.android.material:material:1.4.0")
    implementation("androidx.constraintlayout:constraintlayout:2.0.4")
}

flutter {
    source = "../.."
}

