import com.android.build.api.dsl.LibraryExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Paksa target JVM Kotlin di seluruh modul plugin ke Java 17.
//
// Plugin tflite_flutter 0.11.0 mengompilasi Java-nya ke 1.8, sementara
// Kotlin (mengikuti JDK yang dipakai Gradle) memakai target yang lebih baru
// (JDK 25 → target 25) sehingga build rilis gagal:
//   Inconsistent JVM-target compatibility ... (1.8) and ... (25)
// Kotlin dipaksa ke 17 agar bytecode-nya didukung D8/Android. Selisih
// dengan Java 1.8 milik plugin hanya memicu validasi Gradle, sehingga
// validasi tersebut dibuat "warning" di android/gradle.properties.
subprojects {
    afterEvaluate {
        // tflite_flutter 0.11.0 masih menetapkan compileSdk 31, sedangkan
        // dependensi AndroidX yang ikut ter-resolve (activity, lifecycle,
        // core, dsb.) membutuhkan API >= 34. Naikkan ke 36 (sama dengan :app).
        extensions.findByType(LibraryExtension::class.java)?.compileSdk = 36

        tasks.withType<KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(JvmTarget.JVM_17)
            }
        }
    }
}
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.tensorflow" && requested.name == "tensorflow-lite") {
                useVersion("2.16.1")
            }
        }
        // AGP 8+ menolak beberapa AAR yang memakai namespace sama. Kita hanya
        // butuh libtensorflowlite_jni.so dari tensorflow-lite; GPU delegate
        // dan Java API tidak dipakai aplikasi (inferensi via FFI Dart).
        exclude(group = "org.tensorflow", module = "tensorflow-lite-gpu")
        exclude(group = "org.tensorflow", module = "tensorflow-lite-api")
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
