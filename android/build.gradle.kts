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
// Several plugins we depend on still pin their modules to Java 8
// (flutter_local_notifications, webcrypto, unifiedpush_android,
// flutter_keyboard_visibility_temp_fork). javac already calls that "obsolete
// and will be removed in a future release", and it is the plugin authors'
// to fix, not ours — so raise every subproject to 17, matching :app.
//
// Kotlin's jvmTarget has to move with it: leaving a module on Kotlin 1.8 while
// its Java sources compile at 17 fails outright with "Inconsistent JVM-target
// compatibility", which is why both halves are set here.
//
// This must be registered BEFORE the evaluationDependsOn(":app") block below:
// that one evaluates :app, which evaluates every plugin module, and afterEvaluate
// on an already-evaluated project is a hard error.
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { android ->
            (android as com.android.build.gradle.BaseExtension).compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
            compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
