---
title: "fishshellの汎用的なセットアップメモ" # 記事のタイトル
emoji: "🐟" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["fish", "shell", "fishshell", "setup"] # ["markdown", "rust", "aws"]のように５つまで
published: true # falseで下書き
published_at: 2023-11-10 12:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

- fish の自分なりの環境構築を１つの記事にした
- 付録を付けた
  - 実行するコマンドをまとめた [コマンドまとめ](#コマンドまとめ)
  - neovim の lazy 周りで必要な ssh-agentの永続化
  - neovim のインストールをまとめた [neovimインストール](#neovimインストール)
- 2024年8月28日 記事の大幅な修正をした

# 背景

- レンタルサーバーを利用したときなど，
  fish の環境を構築するたびに調べていたので１つの記事にまとめたかった

# 対象読者

- 未来の自分
- 私と同じような環境を作りたい人

# 環境

以下に完成後の環境を記す．

```text
Windows ターミナル
バージョン: 1.20.11781.0
```

```fish:terminal
$ fish -v
fish, version 3.7.1
```

:

```fish:terminal
$ fisher -v
fisher, version 4.4.4
```

```fish:terminal
$ fisher list
jorgebucaran/fisher
edc/bass
0rax/fish-bd
jethrokuan/z
jorgebucaran/fish-nvm
```

---

# 本論

## fish

### インストール

OSによって大きく異なるので公式を参照． [\*1](#1)
https://fishshell.com

:::details arch linux の例

```
sudo pacman -S fish
```

:::

:::details 管理者権限（sudo）について
fish のインストールは管理者権限がないと辛い．
管理者権限なしの自力でビルドなら，`cmake` が事実上必須．
`cmake` もビルドするなら，`gcc` と `build-essential` は必須．
（`cmake` もビルドする道は挫折したのでこれより先はわからない）．
:::

### デフォルトシェルの設定

デフォルトシェルを fish にする．
OSや環境によっては，POSIX非互換がネックになるので実行前に要調査．

```bash:bash
chsh -s $(which fish)
```

以降は `bash` ではなく fish で実行する．

## fisher

fish のプラグイン管理ツール．

### インストール

公式の GitHub を参照すると次のコマンドが書いてある． [\*2](#2)

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

### 設定

プラグインをインストールする．

```fish
fisher install \
edc/bass \
jethrokuan/z \
jorgebucaran/fish-nvm \
jorgebucaran/fisher \
h-matsuo/fish-color-scheme-switcher
```

:::details 各プラグインの説明

#### edc/bass

fish で bash スクリプトを `source` する．
利用例 は次．

```fish
bass source main.bash
```

https://github.com/edc/bass
https://qiita.com/eduidl/items/dc2f29cac7232a9a97d8#2-bass%E3%82%92%E4%BD%BF%E3%81%86

#### jethrokuan/z

履歴から探って直接移動できるすぐれもの．
奥深いプロジェクトとかにすぐ移動できる．

https://github.com/jethrokuan/z
https://qiita.com/hennin/items/33758226a0de8c963ddf#jethrokuanz

#### jorgebucaran/fish-nvm

fish で nvm を使うときは一工夫いる．

https://nodejs.org/ja/download
https://github.com/jorgebucaran/nvm.fish
https://dev.classmethod.jp/articles/fish-nvm/

#### jorgebucaran/fisher

プラグイン管理だっけ？必要であることは自明．

#### h-matsuo/fish-color-scheme-switcher

`fish_config` でブラウザを開けない（例: SSH先）で fish のカラーテーマを設定する．

https://github.com/h-matsuo/fish-color-scheme-switcher
https://zenn.dev/kawaxumax/articles/00afb9c0075a0b

:::

## oh-my-posh

最新のベストプラクティスは別にありそうだが，設定ファイルを引き継げるのでまだ現役．

### インストール

インストールする。

```fish
curl -s https://ohmyposh.dev/install.sh | bash -s
```

その後、`/usr/bin/` に移動する。

```fish
sudo mv ~/.local/bin/oh-my-posh /usr/bin/
```

:::details sudo できない場合（ユーザ直下のバイナリ置き場）
`~/.config/fish/config.fish` などに，次を記述する

```fish:fish
fish_add_path $HOME/.local/bin
```
:::

:::details unzipがない場合
unzip を使う箇所（テーマのインストール）を省略する．
まずはシェルスクリプトをDL．

```fish
curl -O https://ohmyposh.dev/install.sh
```

vi などのエディタで，以下の２つを行う．

- `validate_dependencies()` 内部の `validate_dependency unzip` を削除
- `install_themes()` をすべて削除（または呼び出し部分を削除）

その後実行権限を与え，実行して，削除．

```fish
chmod +x install.sh && ./install.sh && rm ./install.sh
```

:::

### 設定

自分のテーマを使う．

```fish
git clone https://github.com/rayfiyo/oh-my-posh.git ~/.config/oh-my-posh
```

## mvt コマンドの実装

`mvt` としてファイルを作る．
bash じゃないと動かないかも．特に`#!`は分割した方がいいかも．

```fish
echo "#!/bin/bash

if [ ! -e ~/.cache/trash ]; then
    mkdir ~/.cache/trash
fi
if expr \"$1\" : \"^-\" >/dev/null 2>&1; then
    echo \"This is rm_wrap: Do not use any options.\"
    return 1
fi
date=`date +%y%m%d-%R:%S`
mv -t ~/.cache/trash -f \"\$@\" --suffix \$date
" > mvt
```

:::details エディタで書き込む
```fish
touch mvt
```

mvt の中身は次．

```bash:mvt
#!/bin/bash

if [ ! -e ~/.cache/trash ]; then
    mkdir ~/.cache/trash
fi
if expr "$1" : "^-" >/dev/null 2>&1; then
    echo "This is rm_wrap: Do not use any options."
    return 1
fi
date=`date +%y%m%d-%R:%S`
mv -t ~/.cache/trash -f "$@" --suffix $date
```
:::

その後実行権限を与える．

```fish
chmod +x mvt
```

#### sudo できる場合

```fish
sudo mv mvt /usr/bin/
```

#### sudo できない場合

```fish
mkdir -p ~/.local/bin/ && mv mvt ~/.local/bin/
```

## fish の設定ファイルを適用

自分の設定（プライベートリポジトリ）を使う．
`~/.config/fish/config.fish`

### ssh の設定

次の自分の記事を参考にする．[\*3](#3)
https://zenn.dev/rayfiyo/articles/20231122-ssh_key_gen

GPG key は後で．

### clone

```
 rm -rf ~/.config/fish/ && git clone git@github.com:rayfiyo/fish-config.git ~/.config/fish
```

## `~/.local/` の生成

```
  mkdir -p ~/.local/src
  git clone git@github.com:rayfiyo/complete-notifier.git ~/.local/src/complete-notifier/
  git clone git@github.com:rayfiyo/git-subcommands.git ~/.local/src/git-subcommands/
```

---

# 付録

## コマンドまとめ

fish はインストール済みだとする

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

fisher install edc/bass jethrokuan/fzf 0rax/fish-bd jethrokuan/z

curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

git clone https://github.com/rayfiyo/oh-my-posh.git ~/.config/oh-my-posh
```

## ssh-agentの永続化

ssh-agent.service

## neovimインストール

```fish
curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage 0-o nvim
chmod u+x nvim
```

### libfuse.so.2 がないエラー

:::details エラーメッセージ

```
dlopen(): error loading libfuse.so.2

AppImages require FUSE to run.
You might still be able to extract the contents of this AppImage
if you run it with the --appimage-extract option.
See https://github.com/AppImage/AppImageKit/wiki/FUSE
for more information
```

:::

#### インストールする方法

neovim の AppImage の展開に FUSE2 が必要なのでインストールする．
インストール方法はOSによって大きく異なるので公式を参照．[\*4](#4)
https://github.com/AppImage/AppImageKit/wiki/FUSE
あるいは自分でソースからビルドする．
https://github.com/libfuse/libfuse?tab=readme-ov-file#installation

#### インストールしない方法

- `--appimage-extract` オプションを付ける

```fish
./nvim --appimage-extract
```

- 生成される`AppRun`みたいなやつを`nvim`に変えてパスを通すかシンボリックリンクを作成する

### path を通す

#### sudo ができる

```fish
sudo mv ./nvim /usr/bin/nvim
```

#### sudo ができない

[バイナリ置き場を作る](#バイナリ置き場を作る) を行う．

```fish
mv ./nvim ~/.ubin/
```

### 設定ファイル

```fish
git clone https://github.com/rayfiyo/nvim-configs.git ~/.config/nvim
```

---

# 参考文献

#### 1

- [fish shell](https://fishshell.com) 2024-08-28

#### 2

- [jorgebucaran_fisher\_ A plugin manager for Fish](https://github.com/jorgebucaran/fisher) 2024-08-28

#### 3

- [ssh key の作り方](https://zenn.dev/rayfiyo/articles/20231122-ssh_key_gen) 2024-08-28

#### 4

- [FUSE · AppImage_AppImageKit Wiki](https://github.com/AppImage/AppImageKit/wiki/FUSE)
