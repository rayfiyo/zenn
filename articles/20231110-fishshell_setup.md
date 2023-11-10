---
title: "archにfishshellをneovimを使ってセットアップする" # 記事のタイトル
emoji: "🐟" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["fish", "shell", "fishshell", "setup"] # ["markdown", "rust", "aws"]のように５つまで
published: true # falseで下書き
published_at: 2023-11-10 12:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---
# 概要
ほぼ自分用に fish shell のセットアップ（on ArchLinux）を記述した．
configの設定を書くのに**neovimのインストール**もしている
TL;DR → [まとめ](#まとめ) にコードを全部記述

# インストール
~~~sh
sudo pacman -S fish
~~~

# デフォルトシェルの変更
~~~sh
sudo chsh -s /bin/fish
~~~

# Fisherのインストール
* Fisherはfishのプラグイン管理ツール
https://github.com/jorgebucaran/fisher
* bash ではなく fish で実行する
~~~sh
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
~~~

# プラグインのインストール
~~~sh
fisher install jorgebucaran/fisher
fisher install edc/bass
fisher install jethrokuan/fzf
fisher install 0rax/fish-bd
fisher install jethrokuan/z
~~~

# oh-my-poshのインストール
* 先に，unzipをインストールする
* その後，[Linux _ Oh My Posh](https://ohmyposh.dev/docs/installation/linux) を参考に curl でインストール
* 恐らく bash を sudo で実行しないと書き込みできないよ って言われる
~~~sh
sudo pacman -S unzip
curl -s https://ohmyposh.dev/install.sh | sudo bash -s
~~~

# FUSE2のインストール
* neovimのAppImageの展開に用いる
* **neovim使わないならいらない**
* [こちら](https://github.com/neovim/neovim/releases/tag/stable#:~:text=macos/bin/nvim-,Linux%20(x64),-AppImage)の通り，```--appimage-extract```オプションでも展開はできるがディレクトリが生成されて気に食わない
* メモ: オプション無しでは，https://github.com/AppImage/AppImageKit/wiki/FUSE のリンクがエラーメッセージとして表示されるが，FUSEDのインストール方法ではない
* 最終的に，[AppImages require FUSE to run _ archlinux](https://www.reddit.com/r/archlinux/comments/owy6g8/appimages_require_fuse_to_run/?rdt=50842)を参考にした
~~~sh
sudo pacman -S fuse2
~~~

# neovimのインストール
* neovim使わないならいらない
~~~
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage /usr/bin/nvim
~~~
## sha256sumも欲しい場合
~~~
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz.sha256sum
~~~

# .config/fish/config.fish
* 自分のプライベートリポジトリに保存してあるファイルを用いる

# まとめ
~~~sh
sudo pacman -S fish

sudo chsh -s /bin/fish

curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

fisher install jorgebucaran/fisher
fisher install edc/bass
fisher install jethrokuan/fzf
fisher install 0rax/fish-bd
fisher install jethrokuan/z

sudo pacman -S unzip
curl -s https://ohmyposh.dev/install.sh | sudo bash -s

sudo pacman -S fuse2

curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage /usr/bin/nvim
~~~

# 環境
Arch Linux on WSL2
~~~
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
~~~
~~~
$ wsl.exe -v
WSL バージョン: 1.2.5.0
カーネル バージョン: 5.15.90.1
WSLg バージョン: 1.0.51
MSRDC バージョン: 1.2.3770
Direct3D バージョン: 1.608.2-61064218
DXCore バージョン: 10.0.25131.1002-220531-1700.rs-onecore-base2-hyp
Windows バージョン: 10.0.22621.2283
~~~

# 参考文献
## いつもお世話になっている記事
* [fish shell を使いたい人生だった _ DevelopersIO](https://dev.classmethod.jp/articles/fish-shell-life/)
* [fish shellが結構良かった話 - Qiita](https://qiita.com/hennin/items/33758226a0de8c963ddf)
## 今回お世話になった記事
* [fish shell](https://fishshell.com)
* [fish - ArchWiki](https://wiki.archlinux.jp/index.php/Fish)
* [jorgebucaran_fisher_ A plugin manager for Fish](https://github.com/jorgebucaran/fisher)
* [Linux _ Oh My Posh](https://ohmyposh.dev/docs/installation/linux)
* [AppImages require FUSE to run _ archlinux](https://www.reddit.com/r/archlinux/comments/owy6g8/appimages_require_fuse_to_run/?rdt=50842)
