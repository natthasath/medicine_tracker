# 🎉 Demo Drug

Demo Flutter 100 Things is a showcase app featuring 100+ practical Flutter examples, components, and UI patterns. Ideal for developers, it demonstrates Flutter’s versatility in building beautiful, responsive, and functional cross-platform apps with clean code.

![version](https://img.shields.io/badge/version-1.0-blue)
![rating](https://img.shields.io/badge/rating-★★★★★-yellow)
![uptime](https://img.shields.io/badge/uptime-100%25-brightgreen)

### ✅ Requirements

- [ImageMagick](https://imagemagick.org/script/download.php)

### 📦 Package

- Install Global Rename

```shell
dart pub global activate rename
```

### 🏆 Run

- Get Dependencies

```shell
flutter pub get
flutter pub upgrade
```

- Convert SVG to PNG

```shell
magick convert -background transparent -size 1024x1024 input.svg output.png
```

- Generate Lanuacher Icons

```shell
flutter pub run flutter_launcher_icons
```

- Rename Global

```shell
dart pub global run rename setAppName --value "New Name"
```

- Build APK [./build/app/outputs/flutter-apk/](./build/app/outputs/flutter-apk/)

```shell
flutter clean
flutter analyze
flutter build apk --debug
flutter build apk --release
flutter build apk --split-per-abi
```

- Sig

```shell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 👉🏼 Try it out

```shell
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```