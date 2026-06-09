/*
* Ten plik jest częścią Vector.
*
* Vector jest wolnym oprogramowaniem: możesz je redystrybuować i/lub modyfikować
* zgodnie z warunkami Powszechnej Licencji Publicznej GNU, opublikowanej przez
* Fundację Wolnego Oprogramowania, w wersji 3 Licencji lub
* (według własnego wyboru) dowolnej późniejszej wersji.
*
* Vector jest rozpowszechniany z nadzieją, że okaże się użyteczny,
* ale BEZ ŻADNEJ GWARANCJI; nawet bez domniemanej gwarancji
* PRZYDATNOŚCI HANDLOWEJ lub PRZYDATNOŚCI DO OKREŚLONEGO CELU. Więcej informacji można znaleźć w
* Powszechnej Licencji Publicznej GNU.
*
* Powinieneś otrzymać kopię Powszechnej Licencji Publicznej GNU
* wraz z Vector. W przeciwnym razie zapoznaj się z informacjami na stronie <https://www.gnu.org/licenses/>.
*
* Prawo autorskie (C) 2026 współtwórcy Vector
 */

import java.time.Instant

plugins {
    alias(libs.plugins.agp.app)
    alias(libs.plugins.nav.safeargs)
    alias(libs.plugins.autoresconfig)
    alias(libs.plugins.materialthemebuilder)
    alias(libs.plugins.lsplugin.apksign)
}

apksign {
    storeFileProperty = "androidStoreFile"
    storePasswordProperty = "androidStorePassword"
    keyAliasProperty = "androidKeyAlias"
    keyPasswordProperty = "androidKeyPassword"
}

val defaultManagerPackageName: String by rootProject.extra

android {
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }

    defaultConfig {
        applicationId = defaultManagerPackageName
        buildConfigField("long", "BUILD_TIME", Instant.now().epochSecond.toString())
    }

    packaging {
        resources {
            excludes += "META-INF/**"
            excludes += "okhttp3/**"
            excludes += "kotlin/**"
            excludes += "org/**"
            excludes += "**.properties"
            excludes += "**.bin"
        }
    }

    dependenciesInfo.includeInApk = false

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles("proguard-rules.pro")
        }
    }

    sourceSets { named("main") { res { srcDirs("src/common/res") } } }
    namespace = defaultManagerPackageName
}

autoResConfig {
    generateClass = true
    generateRes = false
    generatedClassFullName = "org.lsposed.manager.util.LangList"
    generatedArrayFirstItem = "SYSTEM"
}

materialThemeBuilder {
    themes {
        for ((name, color) in
            listOf(
                "Red" to "FF0000",
                "Pink" to "FFC0CB",
                "Purple" to "800080",
                "DeepPurple" to "36013F",
                "Indigo" to "4B0082",
                "Blue" to "0000FF",
                "LightBlue" to "ADD8E6",
                "Cyan" to "00FFFF",
                "Teal" to "008080",
                "Green" to "008000",
                "LightGreen" to "90EE90",
                "Lime" to "00FF00",
                "Yellow" to "FFFF00",
                "Amber" to "FFBF00",
                "Orange" to "FFA500",
                "DeepOrange" to "FF8C00",
                "Brown" to "964B00",
                "BlueGrey" to "6A89A7",
                "Sakura" to "FCC9B9",
            )) {
            create("Material$name") {
                lightThemeFormat = "ThemeOverlay.Light.%s"
                darkThemeFormat = "ThemeOverlay.Dark.%s"
                primaryColor = "#$color"
            }
        }
    }
    // Dodaj 3 kolorowe tokeny Material Design (takie jak palettePrimary100) w wygenerowanym motywie
    // rikka.material:material >= 2.0.0 zapewnia takie atrybuty
    // Włącz tę opcję, jeśli używasz rikka.material:material
    generatePalette = true
}

dependencies {
    annotationProcessor(libs.glide.compiler)
    implementation(libs.androidx.activity)
    implementation(libs.androidx.browser)
    implementation(libs.androidx.constraintlayout)
    implementation(libs.androidx.core)
    implementation(libs.androidx.fragment)
    implementation(libs.androidx.navigation.fragment)
    implementation(libs.androidx.navigation.ui)
    implementation(libs.androidx.preference)
    implementation(libs.androidx.recyclerview)
    implementation(libs.androidx.swiperefreshlayout)
    implementation(libs.glide)
    implementation(libs.material)
    implementation(libs.gson)
    implementation(libs.okhttp)
    implementation(libs.okhttp.dnsoverhttps)
    implementation(libs.okhttp.logging.interceptor)
    implementation(libs.rikkax.appcompat)
    implementation(libs.rikkax.core)
    implementation(libs.rikkax.insets)
    implementation(libs.rikkax.material)
    implementation(libs.rikkax.material.preference)
    implementation(libs.rikkax.recyclerview)
    implementation(libs.rikkax.widget.borderview)
    implementation(libs.rikkax.widget.mainswitchbar)
    implementation(libs.rikkax.layoutinflater)
    implementation(libs.appiconloader)
    implementation(libs.hiddenapibypass)
    implementation(libs.kotlin.stdlib)
    implementation(libs.kotlinx.coroutines.core)
    implementation(projects.services.managerService)
}

configurations.all {
    exclude("org.jetbrains", "annotations")
    exclude("androidx.appcompat", "appcompat")
    exclude("org.jetbrains.kotlin", "kotlin-stdlib-jdk7")
    exclude("org.jetbrains.kotlin", "kotlin-stdlib-jdk8")
}
