---
title: "ssh key の作り方" # 記事のタイトル
emoji: "🔑" # 1文字
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["ssh", "key", "ed25519", "ssh-keygen"] # ["markdown", "rust", "aws"]のように５つまで
published: true # falseで下書き
published_at: 2023-11-22 18:00 # 過去・未来の日時

# https://zenn.dev/zenn/articles/zenn-cli-guide
# https://zenn.dev/zenn/articles/markdown-guide
---

# 概要

`ssh-keygen` で Ed25519 アルゴリズムで生成した鍵の，ユーザ名とホスト名の記述を変更して作成する．

# 背景

`ssh-keygen` で ssh の鍵を作る方法をいつも忘れているのでメモした．

# 対象読者

稀に ssh の鍵を作成する機会があるので毎回調べている人．

# 本文

## 鍵の生成

`cat hoge.pub` をしたとき，末尾を `user-name@host-name` にしたい場合
（ユーザ名 を user-name，ホスト名 を host-nameにしたい場合）

```sh
ssh-keygen -t ed25519 -C "user-name@host-name"
```

## 登録

sshした先で先にファイルを準備しておく．

```
mkdir $HOME/.ssh
touch $HOME/.ssh/authorized_keys
```

`exit` したら公開鍵を登録する．

```
cat ~/.ssh/id_ed25519.pub | ssh hoge-user@example.hoge 'cat >> .ssh/authorized_keys'
```

# 参考文献

ユーザ名とホスト名について:
https://dev.classmethod.jp/articles/ssh-keygen-tips/

Ed25519 について:
https://linuxfan.info/ssh-ed25519
