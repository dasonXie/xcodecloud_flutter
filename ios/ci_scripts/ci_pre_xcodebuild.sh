#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Runner
#
#  Created by JL on 8/14/25.
#  

set -e

# 目标 Flutter 版本
FLUTTER_VERSION="3.22.2"  # 你要的版本
ARCH=$(uname -m)  # 获取当前机器架构（arm64 或 x86_64）

# 根据架构选择下载的 Flutter SDK zip 文件
if [ "$ARCH" = "arm64" ]; then
  FLUTTER_FILE="flutter_macos_arm64_${FLUTTER_VERSION}-stable.zip"
else
  FLUTTER_FILE="flutter_macos_${FLUTTER_VERSION}-stable.zip"
fi

# 下载 Flutter SDK（如果是私有源，可以换成私有源 URL）
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/$FLUTTER_FILE"

# 下载并解压 Flutter SDK
echo "🚀 [1/4] 下载 Flutter SDK $FLUTTER_VERSION..."
curl -O "$FLUTTER_URL"

echo "📦 [2/4] 解压 Flutter SDK..."
unzip -q "$FLUTTER_FILE"
export PATH="$PATH:$(pwd)/flutter/bin"  # 将 Flutter SDK 加入 PATH

# 检查 Flutter 环境
echo "🩺 [3/4] 检查 Flutter 环境..."
flutter doctor

# 获取 Flutter 依赖
echo "📚 [4/4] 获取 Flutter 依赖..."
flutter pub get

# 构建 iOS Release（不签名）
flutter build ios --release --no-codesign

echo "✅ Flutter SDK 下载与构建成功，交给 Xcode Cloud 继续 Archive & 签名"
