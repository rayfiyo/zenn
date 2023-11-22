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
```ssh-keygen``` で Ed25519 を使った鍵を，ユーザ名とホスト名の記述を変更して作成する
# 背景
```ssh-keygen``` で ssh の鍵を作る方法をいつも忘れているのでメモ
# 対象読者
ssh をよく使っていて，たまに ssh の鍵を作成する機会があるが毎回調べている人
# 本文
```cat hoge.pub``` をしたとき，末尾を ```userName@hostName``` にしたい場合
（ユーザ名 を userName，ホスト名 を hostNameにしたい場合）
~~~sh
ssh-keygen -t ed25519 -C "userName@hostName"
~~~
# 参考文献
ユーザ名とホスト名について:
https://dev.classmethod.jp/articles/ssh-keygen-tips/

Ed25519 について:
https://linuxfan.info/ssh-ed25519
