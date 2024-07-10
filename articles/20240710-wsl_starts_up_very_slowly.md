---
title: "WSLの起動が遅い(12秒)" # 記事のタイトル
emoji: "🦕" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["wsl", "wsl2", "systemd"] # ["markdown", "rust", "aws"]のように５つまで
published: true # falseで下書き
published_at: 2024-07-10 18:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

- WSL2 の起動が遅いので，調査を行った．
- 原因が `systemd` であると突き止め，対処した．
- 根本的解決方法は未調査である．

# 背景

私はよく WSL （厳密には WSL2）を利用している．
そして，最近，起動が遅いと感じていた．
更新などをしてみても改善せず，
そもそも neovim のように起動時間やログを見る方法が
わからなかったのでこの際に調べてみた．

# 対象読者

- WSL2 で，`systemd` を利用していないが，`systemd` をONにしている（デフォルトの設定）の人
- WSL2 で，起動が遅いと感じている人
- WSL2 で，起動時間を計測する方法を知りたい人
- WSL2 で，起動時のログを確認する方法を知りたい人

## 非対象読者

- WSL2 で，`systemd` を利用していて，起動が遅いと感じている人
  - （弊記事は根本的解決を行わないので参考程度にしかならないため）

## 環境

今回の環境は次である．

```
$ wsl.exe --version
WSL バージョン: 2.2.4.0
カーネル バージョン: 5.15.153.1-2
WSLg バージョン: 1.0.61
MSRDC バージョン: 1.2.5326
Direct3D バージョン: 1.611.1-81528511
DXCore バージョン: 10.0.26091.1-240325-1447.ge-release
Windows バージョン: 10.0.22631.3810
```

また，ディストーションは Arch Linux である．

```
$ cat /etc/os-release
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
VERSION_ID=20231001.0.182270
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://bugs.archlinux.org/"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
```

---

# 本論

## 問題の再確認

WSL2（以降，WSL）の起動が遅いことを確認するため、以下の PowerShell（以降,
posh） コマンドを実行した．

```bash: posh
wsl.exe --shutdown
```

### 結果

- 変わらず起動が遅かった
- 一度起動すると再起動までは起動時間が遅くならなかった

## 切り分け

ハードディスクなど WSL が原因ではない可能性を検討するために，セーフモードで起動してみる．
具体的には，以下の設定を追加して再起動（`wsl.exe --shutdown`）した．

```bash: ~/.wslconfig (posh)
[wsl2]
safeMode=true
```

### 結果

- 起動が非常に速くなった

## 起動ログの取得

[1](#参考文献) によると，起動ログ（the start up logs）は `dmesg` コマンドで取得できる．

このコマンドはWSLに限定せず，Linux でカーネルログを確認するために使用される．
通常は `grep` や `-l`オプションで影響レベルの絞り込みなど をするが，今回は調査である点と興味がある点を考慮して，全ログをファイルに保存して確認する．

（保存は`>`でリダイレクトすれば良い）

### セーフモード

```bash: bash
dmesg > safeMode
```

実際に確認してみると，`1.261612`秒で起動していた．

また，以下のログからセーフモードであること と 無効化されている機能を確認した．

```
[    0.616728] WSL (1) WARNING: SAFE MODE ENABLED - automount.enabled disabled
[    0.616737] WSL (1) WARNING: SAFE MODE ENABLED - automount.ldconfig disabled
[    0.616740] WSL (1) WARNING: SAFE MODE ENABLED - automount.mountFsTab disabled
[    0.616744] WSL (1) WARNING: SAFE MODE ENABLED - boot.systemd disabled
[    0.616747] WSL (1) WARNING: SAFE MODE ENABLED - network.generateHosts disabled
[    0.616750] WSL (1) WARNING: SAFE MODE ENABLED - network.generateResolvConf disabled
[    0.616753] WSL (1) WARNING: SAFE MODE ENABLED - fileServer.enabled disabled
[    0.616756] WSL (1) WARNING: SAFE MODE ENABLED - gpu.appendLibPath disabled
[    0.616759] WSL (1) WARNING: SAFE MODE ENABLED - gpu.enabled disabled
[    0.616762] WSL (1) WARNING: SAFE MODE ENABLED - interop.appendWindowsPath disabled
[    0.616765] WSL (1) WARNING: SAFE MODE ENABLED - interop.enabled disabled
[    0.616768] WSL (1) WARNING: SAFE MODE ENABLED - time.useWindowsTimezone disabled
[    0.775571] WSL (1) WARNING: /etc/resolv.conf updating disabled in /etc/wsl.conf
[    0.777006] WSL (1) WARNING: /etc/hosts updating disabled in /etc/wsl.conf
[    0.787295] WSL (1) WARNING: /etc/resolv.conf updating disabled in /etc/wsl.conf
```

### 通常モード

```bash: bash
dmesg > normalMode
```

実際に確認してみると，`12.366470`秒で起動していた．

また，以下のエラーメッセージが複数行あり、経過時間を確認すると，これが遅延の原因であった．

```bash: dmesg
Failed to connect to bus: No such file or directory
```

## 調査

起動ログの取得 の [セーフモード](#セーフモード) と [通常モード](#通常モード) を比較してみると，明らかに起動時間に差がので，WSL の設定が起動時間に影響していると言える．
セーフモードでは一部機能が無効化されている．

そこで，セーフモードで無効化された機能のうち，どの機能が起動時間に大きく関係があるかを調べる．
WSL の設定は `~/.wslconfig` と `/etc/wsl.conf` がある．[2](#参考文献)
これらの設定を調整することで，起動時間を改善できる可能性がある．

これら設定については[参考文献の2](#参考文献)である以下を参考してほしい．
（日本語版のURLは後述）

https://learn.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings

### 自動マウント

例えば，以下の設定で固定ドライブの自動マウント（/mnt/c など）を無効化できる．
なお，これはセーフモードの `automount.enabled disabled` に対応する．

```bash: /etc/wsl.conf
[automount]
enabled = false
```

### systemd

初回起動時のみに影響があり，
ファイルアクセスやネットワーク，GUIに問題がないことから，
`systemd` が原因であると考えた．
そこで`systemd`を無効化してみる．

なお，これはセーフモードの `boot.systemd disabled` に対応する．

## 対処法

```bash: /etc/wsl.conf
[boot]
systemd = false
```

実際に起動ログを見てみると 2.077917秒で起動できていた．
また，私は（記憶が正しければ）systemdを使っていないので，systemdを無効化する方法で対処を終了する．

根本的な原因を考察すると，systemd を使って何か変なものが起動している可能性が考えられる．

## 考察

[通常モード](#通常モード) で述べたエラーを日本語に訳すと次になる．

```
バスへの接続に失敗しました: そのようなファイルまたはディレクトリがありません
```

これは一見`systemd`よりも，
マウントといったファイル関係の設定が関係しそうである．



---

# 参考文献

- 1: [Troubleshooting Windows Subsystem for Linux \_ Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting#cannot-access-wsl-files-from-windows) 2024-07-10
  - 日本語版: [Windows Subsystem for Linux のトラブルシューティング \_ Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/troubleshooting#cannot-access-wsl-files-from-windows) 2024-07-10
- 2: [Advanced settings configuration in WSL \_ Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings) 2024-07-10
  - 日本語版: [WSL での詳細設定の構成 \_ Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/wsl-config#automount-settings) 2024-07-10
