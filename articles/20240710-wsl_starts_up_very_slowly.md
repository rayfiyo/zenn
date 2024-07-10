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

---

# 本論

## 問題の再確認

- WSL2（以降，WSL）の起動が遅い
- 魔法のコマンドをPowerShell（posh）で試す

```bash: posh
wsl.exe --shutdown
```

- 変わらず起動が遅い
  - １度起動すると再起動するまでは起動は早くなる

## 切り分け

- ハードディスクなどWSLが原因ではない可能性がある
- 以下を書き足して，セーフモードで起動する

```bash: ~/.wslconfig (posh)
[wsl2]
safeMode=true
```

- shutdown して再起動すると爆速で起動した

## 起動ログの取得

[1](#参考文献) によると，起動ログ（the start up logs）は `dmesg` コマンドで取得できる．
今回はファイルに保存したいので`>`でリダイレクトする．

### セーフモード

```bash: bash
dmesg > safeMode
```

実際に確認してみると，1.261612秒で起動していた．

また，

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

というログがあり，これがセーフモードであることも確認した．

### 通常モード

```bash: bash
dmesg > normalMode
```

実際に確認してみると，12.366470秒で起動していた．

また，`Failed to connect to bus: No such file or directory` で１秒程度の時間がかかり，これか複数行あった．

## 調査

起動ログの取得 の [セーフモード](#セーフモード) と [通常モード](#通常モード) を比較してみると，明らかに起動時間に差がある．
よって，WSLの設定（環境）によって起動が遅くなっていると考えた．
また，[セーフモード](セーフモード) で述べた通り，
セーフモードでは一部機能が無効化されている．

そこで，セーフモードで無効化された機能のうち，どの機能が起動時間に大きく関係があるかを調べる．
WSLの機能は，posh側の ` ~/.wslconfig` だけでなく，
wsl側の `/etc/wsl.conf` もある．[2](#参考文献)

例えば，

```bash: /etc/wsl.conf
[automount]
enabled = false
```

では，固定ドライブの自動マウント（/mnt/c など）が無効化される．
試しにこれを行い．shutdown してみたが，起動時間に有意的な変化は見受けられなかった．
なお，これはセーフモードの `automount.enabled disabled` に対応する．

その他の設定については[参考文献の2](#参考文献)である以下を参考してほしい．
（日本語版のURLは後述）

https://learn.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings

## 対処法

最終的に私がたどり着いた設定は，`systemd`を無効化する方法である．
これはセーフモードの `boot.systemd disabled` に対応する．

```bash: /etc/wsl.conf
[boot]
systemd = false
```

実際に起動ログを見てみると 2.077917秒で起動できていた．
また，私は（記憶が正しければ）systemdを使っていないので，systemdを無効化する方法で対処を終了する．

根本的な原因を考察すると，systemd を使って何か変なものが起動している可能性が考えられる．

---

# 参考文献

- 1: [Troubleshooting Windows Subsystem for Linux \_ Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/troubleshooting#cannot-access-wsl-files-from-windows) 2024-07-10
  - 日本語版: [Windows Subsystem for Linux のトラブルシューティング \_ Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/troubleshooting#cannot-access-wsl-files-from-windows) 2024-07-10
- 2: [Advanced settings configuration in WSL \_ Microsoft Learn](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings) 2024-07-10
  - 日本語版: [WSL での詳細設定の構成 \_ Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/wsl-config#automount-settings) 2024-07-10
