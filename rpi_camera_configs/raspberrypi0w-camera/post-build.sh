#!/bin/sh

set -e

BOARD_DIR=$(dirname "$0")
TARGET_DIR="$1"

# カメラモジュールを有効にするための設定を追加
echo "gpu_mem=128" >> "${TARGET_DIR}/boot/config.txt"
echo "start_x=1" >> "${TARGET_DIR}/boot/config.txt"
echo "disable_camera_led=1" >> "${TARGET_DIR}/boot/config.txt"

# 起動時にraspividを自動実行するスクリプトを配置
cp "${BOARD_DIR}/start_raspivid.sh" "${TARGET_DIR}/usr/local/bin/"
chmod +x "${TARGET_DIR}/usr/local/bin/start_raspivid.sh"

# 自動起動用のinittabエントリを追加
echo "::respawn:/usr/local/bin/start_raspivid.sh" >> "${TARGET_DIR}/etc/inittab"