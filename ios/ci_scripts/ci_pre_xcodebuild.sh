#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Runner
#
#  Created by JL on 8/14/25.
#  

set -e

echo "当前工作目录: $(pwd)"

# 发现是在ci_scripts目录下，返回上级目录在执行，这个太重要了，没有回到ios目录下，会找不到Generated.xcconfig
cd ..

echo "当前工作目录: $(pwd)"


# 检查 ios/Flutter 目录是否存在，不存在则创建并赋予权限
if [ ! -d "Flutter" ]; then
  echo "创建 Flutter 目录..."
  mkdir -p Flutter
  # 赋予读写权限（关键）
  chmod 777 ios/Flutter
fi

# 打印 ios/Flutter 目录的权限
echo "Flutter 目录权限: $(ls -ld Flutter)"

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

echo "📚 获取 Pod 依赖..."
pod install

echo "📚 Flutter 构建..."
# 构建一次 iOS 项目（触发 Generated.xcconfig 生成）
flutter build ios --config-only --no-codesign # 仅生成配置，不完整构建

echo "✅ Flutter SDK 下载与构建成功，交给 Xcode Cloud 继续 Archive & 签名"
