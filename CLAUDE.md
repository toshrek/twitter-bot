# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stickies は SwiftUI + SwiftData で実装されたマルチプラットフォーム（iOS / macOS / visionOS）メモアプリ。  
Bundle ID: `SummerBananaStudio.Stickies` / Swift 5.0 / 最小デプロイターゲット: iOS 26.4, macOS 26.4

## Build & Run

```bash
# Xcode で開く
open Stickies.xcodeproj

# CLI ビルド（iOS Simulator）
xcodebuild -project Stickies.xcodeproj -scheme Stickies \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# CLI ビルド（macOS）
xcodebuild -project Stickies.xcodeproj -scheme Stickies \
  -destination 'platform=macOS' build
```

テストターゲットは現時点では存在しない。

## Architecture

### データ層: SwiftData

- `Item.swift` — `@Model` アノテーション付きの唯一のエンティティ。現在は `timestamp: Date` のみ持つ。
- `StickiesApp.swift` — `ModelContainer` を生成してシーン全体に `.modelContainer()` で注入する。スキーマは `Schema([Item.self])` で定義。
- ビューは `@Query` で SwiftData から直接データを取得し、`modelContext.insert` / `modelContext.delete` で変更する。

### プラットフォーム分岐

`#if os(macOS)` / `#if os(iOS)` によるコンパイル時分岐を使用。  
`ContentView.swift` 内の `NavigationViewWrapper` が macOS では `NavigationSplitView`、iOS では素の `content()` を返すことでナビゲーション構造の差異を吸収している。

### インフラ設定

- **CloudKit**: Entitlements で `CloudKit` サービスが有効（コンテナ ID は未設定）
- **APNs**: `development` 環境が有効（`Info.plist` の `UIBackgroundModes: remote-notification`）

いずれもまだ実装されていないが、SwiftData の CloudKit 同期追加時は `ModelConfiguration` に `cloudKitDatabase` オプションを渡す形になる。
