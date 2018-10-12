# このソフトウェアについて

　Raspbian初期セットアップ自動化バッチ。

# 狙い

* SDカード書込上限による劣化の低減
* システム更新の高速化
* 日本語化

## セットアップ概要

* スワップ停止
* RAMディスク設定
* ログ出力の抑制
* aptのソースを日本サーバに設定
* システム更新
* 日本語フォント＋日本語入力のインストール

# 前提

1. Raspbian stretch 2018-06-27をSDカードやHDDに書き込む
1. 初回ブートする
1. ダイアログに従い、セットアップする（ただしシステム更新はスキップする）
1. 再起動する
1. 本バッチを1度だけ実行する

# 使い方

```bash
$ ./raspbian_first_setup.sh
```

# 課題

* ディスプレイ設定（解像度などディスプレイに応じて）
* 音声出力設定（本体 or HDMI）

　以下もできればオプションで。

* 自作ツール一式コピー
* フォント、もっといいのないか？　なぜかアンダーバーが見えない
* Chromiumのプロファイル
    * Chromiumの拡張機能を追加したい（stylus, authenticator）
    * stylusのユーザスタイルを追加したい
    * authenticatorにデータをインポートしたい

# ライセンス

このソフトウェアはCC0ライセンスである。

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.ja)
