buildscript {
    // No need to define kotlin_version here since it's in settings.gradle.kts
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        // Don't define AGP or Kotlin plugin here - they're in settings.gradle.kts
        classpath("com.google.gms:google-services:4.3.15") // Keep if using Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}