// Tệp: android/app/build.gradle

plugins {
     id("com.android.application")
     id("kotlin-android")
    
    // <<< THÊM DÒNG NÀY >>>
    id("com.google.gms.google-services")
    
 // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
     id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.doanflutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
    jvmTarget = JavaVersion.VERSION_11.toString()
    }

     defaultConfig {
     applicationId = "com.example.doanflutter"
     
        // <<< SỬA DÒNG NÀY (thay thế flutter.minSdkVersion bằng 21) >>>
        minSdk = flutter.minSdkVersion 
        
     targetSdk = flutter.targetSdkVersion
     versionCode = flutter.versionCode
     versionName = flutter.versionName

        // <<< THÊM DÒNG NÀY >>>
        multiDexEnabled = true
     }

     buildTypes {
    release {
    
     // TODO: Add your own signing config for the release build.
     // Signing with the debug keys for now, so `flutter run --release` works.
     signingConfig = signingConfigs.getByName("debug")
      }
    }
}

flutter {
    source = "../.."
}

// <<< THÊM TOÀN BỘ KHỐI NÀY VÀO CUỐI TỆP >>>
dependencies {
    // Import Firebase BoM (Bill of Materials) để quản lý phiên bản
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // Thêm các thư viện Firebase bạn cần (không cần ghi phiên bản)
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-messaging")

    // Thêm thư viện Multidex
    implementation("androidx.multidex:multidex:2.0.1")
}
