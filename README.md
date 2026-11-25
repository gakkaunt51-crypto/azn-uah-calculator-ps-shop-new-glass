# AZN → UAH Calculator for Android — 1.4.0

Исходный Flutter/Dart-проект приложения с палитрой из 50 тем: 20 однотонных и 30 градиентных. Выбор темы сохраняется между запусками.

## Что нужно для сборки

- Flutter SDK 3.50.0 (stable) или совместимая более новая версия;
- Java JDK 17;
- Android SDK Platform 36 и Android Build Tools 36;
- Git for Windows.

## Пересборка APK

1. Распакуйте архив и откройте терминал в папке `azn_flutter` — рядом с `pubspec.yaml`.
2. При первой настройке Android SDK выполните `flutter doctor --android-licenses` и примите лицензии.
3. Выполните:

   ```powershell
   flutter pub get
   flutter build apk --release
   ```

Готовый APK появится по пути `build\app\outputs\flutter-apk\app-release.apk`.

## Примечания

- `pubspec.lock` и `dependency_overrides` сохранены, чтобы разрешение зависимостей совпадало с APK.
- В `android/app/src/main/AndroidManifest.xml` объявлено разрешение `INTERNET`, необходимое приложению для сетевого запроса курса.
- Release-конфигурация использует отладочную подпись Flutter. Для распространения через Google Play настройте собственный ключ подписи.
