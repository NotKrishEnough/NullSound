# NullSound

<p align="center">
  <img src="assets/brand/nullsound_logo.svg" alt="NullSound logo" width="180" />
</p>

**Your music. Your flow.** A modern, Android-first Flutter music player.

## Features
- YouTube Music-style search and discovery powered by the DA-Tunes streaming reference approach
- Audio stream resolution with fallback, queue controls and background playback
- Material 3, dynamic color, artwork-derived player colors, light/dark/system themes
- Home, Search and Library; mini-player and expanded player
- Lyrics, downloads and sleep timer foundations

## Screenshots
_Add screenshots here._

## Tech stack
Flutter, Dart, Riverpod, just_audio, audio_service, youtube_explode_dart, dynamic_color, palette_generator, Hive, cached_network_image.

## Project structure
```
lib/
  app/                 # app shell and theme
  core/                # audio and streaming services
  features/
    home/ search/ library/ player/
  main.dart
```

## Getting started
```sh
git clone https://github.com/NotKrishEnough/NullSound.git
cd NullSound
flutter pub get
flutter run
```

## Release APK
```sh
flutter build apk --release
```

## Credits
- [DA-Tunes](https://github.com/VikrantRuhela/DA-Tunes) — streaming implementation reference. NullSound is an independent implementation and does not copy source files.

## Disclaimer
NullSound is unofficial and is not affiliated with YouTube or Google. Use for personal and educational purposes, and respect copyright and applicable terms.

## License
GNU General Public License v3.0. See [LICENSE](LICENSE).
