# Solución para compilar ChullaCash App en modo Release

## Problema

Al intentar compilar la aplicación en modo release, se producía el siguiente error:

```
Failed to transform '/Users/cristhianrecalde/.gradle/caches/modules-2/files-2.1/org.bouncycastle/bcprov-jdk18on/1.78.1/39e9e45359e20998eb79c1828751f94a818d25f8/bcprov-jdk18on-1.78.1.jar' using Jetifier. Reason: IllegalArgumentException, message: Unsupported class file major version 65.
```

Este error se debe a una incompatibilidad entre la versión de Java 21 (que es la que está utilizando Flutter) y algunas dependencias que están utilizando una versión anterior de Java.

## Solución

### 1. Deshabilitar Jetifier

Jetifier es una herramienta que convierte bibliotecas de soporte a AndroidX. En este caso, estaba causando problemas con Java 21. Para solucionarlo, se deshabilitó Jetifier en el archivo `android/gradle.properties`:

```properties
android.enableJetifier=false
```

### 2. Configurar Java Home

Se agregó la configuración de Java Home en el archivo `android/gradle.properties` para asegurarse de que Gradle utilice la misma versión de Java que Flutter:

```properties
org.gradle.java.home=/Applications/Android Studio.app/Contents/jbr/Contents/Home
```

### 3. Excluir dependencias problemáticas

Se agregó una configuración en el archivo `android/app/build.gradle` para excluir las dependencias problemáticas:

```gradle
configurations.all {
    resolutionStrategy {
        force 'org.bouncycastle:bcprov-jdk15on:1.70'
        exclude group: 'org.bouncycastle', module: 'bcprov-jdk18on'
    }
}
```

### 4. Configurar opciones de empaquetado

Se agregó una configuración en el archivo `android/app/build.gradle` para excluir archivos META-INF que podrían causar conflictos:

```gradle
packagingOptions {
    resources {
        excludes += ['META-INF/DEPENDENCIES', 'META-INF/LICENSE', 'META-INF/LICENSE.txt', 'META-INF/license.txt', 'META-INF/NOTICE', 'META-INF/NOTICE.txt', 'META-INF/notice.txt', 'META-INF/ASL2.0', 'META-INF/*.kotlin_module']
    }
}
```

### 5. Limpiar la caché de Gradle

Se limpió la caché de Gradle para asegurarse de que se utilicen las nuevas configuraciones:

```bash
cd android && ./gradlew clean && cd ..
```

## Resultado

Después de aplicar estas soluciones, la aplicación se compiló correctamente en modo release y se ejecutó sin problemas en el dispositivo.

## Notas adicionales

- Todavía hay algunas advertencias relacionadas con opciones obsoletas de Java, pero no afectan el funcionamiento de la aplicación.
- Si se actualiza Android Studio o Flutter en el futuro, es posible que sea necesario revisar estas configuraciones nuevamente.
- Los anuncios se están mostrando correctamente en la aplicación.

## Referencias

- [Documentación de Gradle sobre compatibilidad con Java](https://docs.gradle.org/current/userguide/compatibility.html#java)
- [Guía de migración de Flutter para incompatibilidad de Java/Gradle](https://flutter.dev/to/java-gradle-incompatibility)
- [Documentación de AndroidX](https://developer.android.com/jetpack/androidx) 