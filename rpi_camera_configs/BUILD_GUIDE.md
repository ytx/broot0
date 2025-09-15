# Raspberry Pi Zero W カメラ→HDMI出力イメージ ビルド&動作確認手順

## 概要
Raspberry Pi Zero Wに接続されたカメラの映像をHDMI出力するだけのシンプルなイメージをBuildRootで作成します。

## 必要なもの
- Raspberry Pi Zero W
- Raspberry Pi Camera Module (v1またはv2)
- microSDカード (4GB以上推奨)
- HDMIケーブル (miniHDMI → HDMI変換)
- 電源 (microUSB)

## ビルド手順

### 1. BuildRootのセットアップ
```bash
# BuildRootをクローン
git clone https://github.com/buildroot/buildroot.git
cd buildroot
```

### 2. カスタム設定の適用
```bash
# カスタム設定をロード
make raspberrypi0w_camera_defconfig
```

### 3. イメージのビルド
```bash
# ビルド実行（macOSの場合）
make -j$(sysctl -n hw.ncpu)

# Linuxの場合
make -j$(nproc)
```

ビルドには数十分から数時間かかります。完了すると以下のファイルが生成されます：
- `output/images/sdcard.img` - SDカード用のイメージファイル

### 4. SDカードへの書き込み
```bash
# SDカードのデバイス名を確認
lsblk  # Linux
diskutil list  # macOS

# イメージを書き込み（例: /dev/sdXまたは/dev/diskN）
sudo dd if=output/images/sdcard.img of=/dev/sdX bs=4M status=progress
# または
sudo dd if=output/images/sdcard.img of=/dev/diskN bs=4m
```

## 動作確認手順

### 1. ハードウェア接続
1. Raspberry Pi Zero WにカメラモジュールをCSIポートに接続
2. HDMIケーブルを接続（miniHDMI → HDMI変換）
3. microSDカードを挿入
4. 電源を接続して起動

### 2. 動作確認
- 電源投入後、約30秒～1分でカメラの映像がHDMI出力されます
- カメラのLEDは無効化されているため点灯しません
- フルスクリーンで1920x1080、30fpsで出力されます

### 3. トラブルシューティング

#### カメラが認識されない場合
1. カメラモジュールの接続を確認
2. カメラケーブルが正しい向きで接続されているか確認
3. `raspi-config`でカメラを有効化（手動起動の場合）

#### HDMI出力されない場合
1. HDMIケーブルの接続を確認
2. モニターがサポートする解像度を確認
3. `config.txt`のHDMI設定を調整

#### 映像が映らない場合
1. カメラのプライバシーシャッターが開いているか確認
2. カメラモジュールのレンズフォーカスを調整
3. 照明条件を改善

## カスタマイズ

### 解像度変更
`board/raspberrypi0w-camera/start_raspivid.sh`で以下を編集：
```bash
# 1280x720に変更
raspivid -f -t 0 -p 0,0,1280,720 -fps 30

# 640x480に変更
raspivid -f -t 0 -p 0,0,640,480 -fps 30
```

### フレームレート変更
```bash
# 60fps
raspivid -f -t 0 -p 0,0,1920,1080 -fps 60

# 15fps
raspivid -f -t 0 -p 0,0,1920,1080 -fps 15
```

### 録画オプション追加
```bash
# ファイルに保存も同時実行
raspivid -f -t 0 -p 0,0,1920,1080 -fps 30 -o /tmp/video.h264
```

## ファイル構成

```
buildroot/
├── configs/
│   └── raspberrypi0w_camera_defconfig    # カスタム設定
├── board/
│   └── raspberrypi0w-camera/
│       ├── config_0w.txt                 # Raspberry Pi設定
│       ├── genimage-raspberrypi0w-camera.cfg  # イメージ生成設定
│       ├── post-build.sh                 # ビルド後処理
│       ├── post-image.sh                 # イメージ後処理
│       └── start_raspivid.sh            # 起動スクリプト
└── output/
    └── images/
        └── sdcard.img                    # 最終イメージファイル
```

## 技術仕様
- ベース: BuildRoot 2025.08-rc3
- アーキテクチャ: ARMv6 (arm1176jzf-s)
- ツールチェーン: Bootlin External Toolchain
- Linux Kernel: Raspberry Pi カスタムカーネル
- ファイルシステム: ext4 (256MB)
- GPU メモリ: 128MB
- 起動時間: 約30秒～1分