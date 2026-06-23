import com.android.build.gradle.BaseExtension

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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val configureProject = { proj: Project ->
        if (proj.plugins.hasPlugin("com.android.application") ||
            proj.plugins.hasPlugin("com.android.library")) {
            proj.extensions.configure<BaseExtension>("android") {
                compileSdkVersion(36)
            }
        }
    }
    if (project.state.executed) {
        configureProject(project)
    } else {
        project.afterEvaluate {
            configureProject(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
