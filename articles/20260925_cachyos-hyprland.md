---
title: "Windows11 → CachyOS + Hyprland の移行メモ" # 記事のタイトル
emoji: "🦔" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["CachyOS", "Hyprland", "Arch", "環境構築"]
published: ture # falseで下書き
published_at: 2026-09-25 12:00 # 過去・未来の日時


# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

シルバーウィークも終盤、
普段使っていない Windows11 機を CachyOS へと移行した。

特徴は、dotfiles を導入してみた点。
環境構築が非常に楽（に今後なりそう）。

## 背景

Windows11 機はメモリが 8GB のため、カツカツ。
しかし、メモリ価格高騰の中、
普段使用していない筐体へ購入するのはためらう。

そこで、WSL2 を使うくらいなら、
Windows11 OS を消してインストールしてやろうという作戦。
普段使用していない筐体なので、
データが消えても困らない（だろう）と考えた。

## 対象読者

- Windows11 をやめたい人
- WSL に引きこもっている人
- CachyOS + Hyprland 環境に興味がある人
  - Arch Linux に興味はあるが、
    そこまで環境構築に時間を割きたくない人
  - タイル型のウィンドウマネージャが好きな人
  - Vim系のエディタを使っている人
  - 一から見た目を設定するのはコストに感じる人

## 環境

```fish
$ fastfetch --logo none
xxx@xxx
--------------
OS: CachyOS x86_64
Host: HP Laptop xxx
Kernel: Linux 7.2.7-1-cachyos
Uptime: 18 mins
Packages: 1143 (pacman)
Shell: fish 4.9.3
Display (CMN1538): 1920x1080 @ 1.5x in 15", 60 Hz [Built-in]
Window Manager: Hyprland 0.56.2 (Wayland)
Theme: Fusion [Qt], adw-gtk3 [GTK2/3/4]
Icons: breeze [Qt]
Cursor: Bibata-Modern-Ice (24px)
Terminal: WezTerm 20260716-195552-76b606ec
Terminal Font: UDEV Gothic 35NF
CPU: AMD Ryzen 5 5500U (12) @ 4.06 GHz
GPU: AMD Lucienne [Integrated]
Memory: 2.70 GiB / 7.08 GiB (38%)
Swap: 912.00 KiB / 7.08 GiB (0%)
Disk (/): 78.77 GiB / 472.94 GiB (17%) - btrfs
Local IP (wlan0): xxx
Battery (Primary): 100% [AC Connected]
Locale: en_US.UTF-8
```

```fish
cat /etc/os-release
NAME="CachyOS Linux"
PRETTY_NAME="CachyOS"
ID=cachyos
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://cachyos.org/"
DOCUMENTATION_URL="https://wiki.cachyos.org/"
SUPPORT_URL="https://discuss.cachyos.org/"
BUG_REPORT_URL="https://github.com/cachyos"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=cachyos
```

---

<!-- # 本論 -->

# インストール

公式より ISO ファイルをダウンロードし、
チェックサムを確認して Rufus でインストールメディアを作成した。
https://cachyos.org/download/

詳細な手順が欲しい場合は次を参照すると良さそう。
https://wiki.cachyos.org/ja/installation/installation_prepare/

基本、表示に沿ってインストールを行った。
変更箇所は次（覚えているもののみ）で、
Windows11 には別れを告げず
^[プロダクトキーを明示的に控えておけばよかったと後悔している。
きっと、過去に控えていると信じている。] フォーマットした。

- ブートマネージャ: Limine
- ファイルシステム: BTRFS
- デスクトップ環境: Hyprland
- キーボード: Generic 104 keyboard
  - 正しい名称は覚えていないが、
    ブランドPCではなかったので　Generic だった
  - US 配列を使うので 104 キーボードを選択した

# 設定

設定アプリが起動した。
おそらく Hyprland の GUI でできる設定じゃないだろうか。
タスクバーを中心に変更した。

設定ファイルはエクスポートできたので、
あとで dotfiles とまとめて公開する。

# インストール

取り急ぎ、ブラウザとターミナルをインストールした。

- ブラウザ: Vivaldi
- ターミナル: WezTerm

```fish
shelly install standard vivaldi
shelly install standard wezterm
```

余談だが、デフォルトで fish が使えて嬉しかった。
また、shelly という aur に対応している
パッケージマネージャがデフォルトで入っていた。
これまた感動した。

# 日本語

## 入力

ド定番の fcitx5 + Mozc を使う。

```fish
shelly install standard fcitx5 fcitx5-configtool fcitx5-mozc
```

依存関係で勝手に Mozc も入れてくれそうな雰囲気だった。

## ユーザーディレクトリ

ホームディレクトリ直下が日本語になっていたので、
英語にした。root 直下ではないので sudo は不要。

```fish
LANG=C xdg-user-dirs-update --force
```

# SSH to GitHub

GitHub に SSH できるようにした。

[自身が過去に書いた記事](https://zenn.dev/rayfiyo/articles/20231122-ssh_key_gen) を参考に、SSH キーを作成した。

```fish
ssh-keygen -t ed25519 -C "git@github.com"
```

生成された鍵のディレクトリを変更し、
`~/.ssh/config` を作成し、中身は次を書いた。

```text
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github/rayfiyo
```

その後、公開鍵を次に登録した。

https://github.com/settings/keys

あとは、`ssh github.com` で正常に接続できたことを確認した。

# サスペンドの無効化

Linux（systemd）自体が一定時間でスリープするのを
強制的に禁止（マスク）した。

```fish
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

解除したい場合は、`mask` を `unmask` に変えて実行する。

# dotfiles

chezmoi を使って dotfiles を管理しているので導入した。

```fish
shelly install standard chezmoi
chezmoi init --ssh rayfiyo
```

# Commit to GitHub with GPG

## 鍵生成

インストールして、鍵生成した。
質問は基本デフォルトで良かった。

1. 鍵のアルゴリズム → Ed25519 を採用したい
   - `(9) ECC (sign and encrypt) *default*`
   - デフォルトなので、空で Enter
2. どの楕円曲線を使うか → Ed25519 を採用したい
   - `(1) Curve 25519 *default*`
   - デフォルトなので、空で Enter
3. 残りは表示を読んで従う

:::warning
メールアドレスは `git config --global user.email`
と同じものを指定しないと、未認証 (`Unverified`) になります。
:::

```fish
shelly install standard gnupg
gpg --full-generate-key
```

鍵が生成できたら、公開鍵のエクスポートをクリップボードへ行った。

```
gpg --armor --export $(gpg --list-secret-keys --keyid-format=long | grep -A1 "sec" | tail -n1 | awk '{print $1}') | wl-copy
```

:::details 鍵が複数ある場合など、手動で行う場合。
次を実行し、sec 行にある長いフィンガープリントを控える。

```fish
gpg --list-secret-keys --keyid-format=long
```

`XXXXXXXXXXXXXXXX` だった場合は次を実行すればよい。

```
gpg --armor --export XXXXXXXXXXXXXXXX
```

あるいは、fish であれば Tab 補完が効く。

表示された `-----BEGIN PGP PUBLIC KEY BLOCK-----` から
`-----END PGP PUBLIC KEY BLOCK-----` までの文字列をすべてコピーする。
:::

## GitHub へ登録と、Git への設定（署名有効化）

[GitHub の Add new GPG key](https://github.com/settings/gpg/new)
から追加した。

その後、署名を有効化した。

```fish
# キーIDを設定
git config --global user.signingkey  $(gpg --list-secret-keys --keyid-format=long | grep -A1 "sec" | tail -n1 | awk '{print $1}')

# 自動的にすべてのコミットに署名をつける設定
git config --global commit.gpgsign true
```

場合によっては、`gpg` コマンドのパス設定
`git config --global gpg.program gpg` が必要らしい。
