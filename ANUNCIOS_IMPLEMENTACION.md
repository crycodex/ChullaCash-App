# Implementación de Anuncios en ChullaCash App

## Descripción General

La aplicación ChullaCash ahora muestra anuncios intersticiales en los siguientes momentos:

1. Al iniciar la aplicación por primera vez
2. Cuando la aplicación vuelve al primer plano después de haber estado en segundo plano

## Componentes Principales

### 1. AdService (lib/services/ad_service.dart)

Este servicio maneja la carga y visualización de anuncios intersticiales. Características principales:

- Inicialización asíncrona de Google Mobile Ads con manejo de completado
- Espera activa a que AdMob esté inicializado antes de cargar o mostrar anuncios
- Carga de anuncios intersticiales
- Reintentos automáticos si falla la carga (hasta 3 intentos)
- Precarga automática de anuncios después de mostrar uno
- Manejo de errores y estados
- Timeouts para evitar bloqueos

### 2. AdHelper (lib/ad_helper.dart)

Proporciona los IDs de anuncios para diferentes plataformas y entornos:

- IDs de prueba para desarrollo (modo debug)
- IDs reales para producción
- Soporte para Android e iOS

### 3. Integración en MainApp (lib/main.dart)

La clase `_MainAppState` implementa:

- `WidgetsBindingObserver` para detectar cambios en el ciclo de vida de la aplicación
- Método `_initAds()` para inicializar anuncios al inicio
- Método `_showInterstitialAd()` asíncrono para mostrar anuncios
- Lógica para mostrar anuncios cuando la app vuelve al primer plano
- Retrasos adecuados para asegurar que la UI esté lista antes de mostrar anuncios

## Configuración

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<application
    ...>
    
    <!-- admob -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-6468767225905546~3919190018"/>
        
    ...
</application>
```

### iOS (ios/Runner/Info.plist)

```xml
<!-- AdMob Configuration -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-6468767225905546~1283581526</string>
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Más identificadores... -->
</array>
```

## Modo de Desarrollo vs. Producción

- En modo de desarrollo (debug), se utilizan IDs de prueba de Google AdMob
- En modo de producción (release), se utilizan los IDs reales de la cuenta de AdMob

## Mejores Prácticas Implementadas

1. **Inicialización asíncrona**: Se utiliza un Completer para manejar la inicialización asíncrona de AdMob
2. **Espera activa**: Se espera a que AdMob esté inicializado antes de cargar o mostrar anuncios
3. **Reintentos automáticos**: Si falla la carga de un anuncio, se reintenta hasta 3 veces
4. **Precarga de anuncios**: Después de mostrar un anuncio, se carga automáticamente el siguiente
5. **Manejo de errores**: Todos los errores son capturados y registrados
6. **Modo de desarrollo**: Uso de IDs de prueba para evitar infracciones de políticas durante el desarrollo
7. **Ciclo de vida de la aplicación**: Mostrar anuncios en momentos estratégicos
8. **Timeouts**: Se utilizan timeouts para evitar bloqueos si AdMob no se inicializa correctamente

## Personalización

Para ajustar cuándo se muestran los anuncios:

1. Modificar el método `didChangeAppLifecycleState` en `_MainAppState` para cambiar cuándo se muestran anuncios al volver al primer plano
2. Ajustar los retrasos en `_initAds` y `didChangeAppLifecycleState` para controlar el tiempo entre la carga y visualización
3. Implementar lógica adicional para mostrar anuncios en otros momentos de la aplicación

## Solución de Problemas

Si los anuncios no se muestran:

1. Verificar la conexión a Internet
2. Comprobar que los IDs de anuncios sean correctos
3. Revisar los registros de depuración para identificar errores
4. Asegurarse de que la cuenta de AdMob esté activa y aprobada
5. Verificar que no haya infracciones de políticas en la cuenta de AdMob
6. Aumentar los tiempos de espera en los métodos `loadInterstitialAd` y `showInterstitialAd`
7. Verificar que el emulador o dispositivo tenga Google Play Services actualizado

## Problemas conocidos en emuladores

En algunos emuladores, especialmente los que no tienen Google Play Services completos, pueden aparecer errores como:

```
E/libEGL: called unimplemented OpenGL ES API
```

Estos errores generalmente no afectan el funcionamiento en dispositivos reales y están relacionados con limitaciones del emulador. 