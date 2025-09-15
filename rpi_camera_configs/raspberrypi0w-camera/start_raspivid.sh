#!/bin/sh

# HDMI出力設定を強制
tvservice -e "CEA 16 HDMI"

# 少し待機
sleep 2

# カメラからHDMIへの連続出力
# -f: フルスクリーン
# -t 0: 時間制限なし（連続実行）
# -p 0,0,1920,1080: プレビューウィンドウの位置とサイズ
# -fps 30: フレームレート
raspivid -f -t 0 -p 0,0,1920,1080 -fps 30